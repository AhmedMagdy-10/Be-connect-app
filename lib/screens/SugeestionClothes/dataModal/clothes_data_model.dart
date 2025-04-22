import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:qoute_app/testing/outfits_helper.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

late Uint8List modelBytes;

//
Future<void> loadModelBytes() async {
  final byteData = await rootBundle.load('assets/models/fashion_mnist.tflite');
  modelBytes = byteData.buffer.asUint8List();
  print("Model Loaded Successfully");
}

// Top-level function to preprocess the image.
Uint8List preprocessImage(img.Image original) {
  // 1. Convert to grayscale
  final grayscaleImage = img.grayscale(original);

  // 2. Apply adaptive thresholding to enhance contrast
  final thresholded = img.copyResize(grayscaleImage, width: 28, height: 28);

  // 3. Calculate mean luminance for adaptive threshold
  int sum = 0;
  for (int y = 0; y < 28; y++) {
    for (int x = 0; x < 28; x++) {
      sum += img.getLuminance(thresholded.getPixel(x, y)).toInt();
    }
  }
  final meanLuminance = sum ~/ (28 * 28);
  final threshold = max(meanLuminance - 30, 10); // Adjust threshold

  // 4. Apply threshold and invert (MNIST-style)
  final bytes = Uint8List(28 * 28);
  for (int y = 0; y < 28; y++) {
    for (int x = 0; x < 28; x++) {
      int luminance = img.getLuminance(thresholded.getPixel(x, y)).toInt();
      bytes[y * 28 + x] = luminance > threshold ? 0 : 255 - luminance;
    }
  }

  return bytes;
}

List<double> normalizePixels(Uint8List bytes, {bool scale0to1 = true}) {
  if (scale0to1) {
    return bytes.map((b) => b / 255.0).toList();
  } else {
    // Alternative normalization if model expects different range
    return bytes.map((b) => (b - 127.5) / 127.5).toList();
  }
}

// Top-level helper to reshape a flat list into a 3D list [1, 28, 28].
List<List<List<double>>> reshapeTo3D(List<double> flatList) {
  List<List<List<double>>> reshaped = [];
  for (int i = 0; i < 28; i++) {
    List<List<double>> row = [];
    for (int j = 0; j < 28; j++) {
      row.add([flatList[i * 28 + j]]);
    }
    reshaped.add(row);
  }
  return reshaped;
}

// Then in classifyClothingIsolate:
List<List<List<List<double>>>> reshapeTo4D(
  List<double> flatList,
  List<int> shape,
) {
  int batch = shape[0]; // 1
  int height = shape[1]; // 28
  int width = shape[2]; // 28
  int channels = shape.length > 3 ? shape[3] : 1; // Ensure channel is 1

  int index = 0;
  List<List<List<List<double>>>> reshaped = [];
  for (int b = 0; b < batch; b++) {
    List<List<List<double>>> batchList = [];
    for (int i = 0; i < height; i++) {
      List<List<double>> row = [];
      for (int j = 0; j < width; j++) {
        row.add([flatList[index++]]); // Wrap in a list to add a channel
      }
      batchList.add(row);
    }
    reshaped.add(batchList);
  }
  return reshaped;
}

void debugPrintImage(Uint8List bytes) {
  print("Image preview:");
  for (int y = 0; y < 28; y++) {
    String row = "";
    for (int x = 0; x < 28; x++) {
      int val = bytes[y * 28 + x];
      row +=
          val > 200
              ? "##"
              : val > 150
              ? ".."
              : val > 100
              ? "::"
              : "  ";
    }
    print(row);
  }
}

// Top-level helper to create output buffer.
List<Object> createOutputBuffer(Tensor outputTensor) {
  final int bufferSize = outputTensor.shape.reduce((a, b) => a * b);
  print("Creating output buffer with size: $bufferSize");
  return [Float32List(bufferSize)];
}

// Top-level helper to convert output buffer to list of probabilities.
List<double> convertOutput(List<Object> outputBuffer, Tensor outputTensor) {
  final outputData = outputBuffer[0];
  print("Output data runtime type: ${outputData.runtimeType}");
  if (outputData is Float32List) {
    return outputData.toList();
  } else if (outputData is List<double>) {
    return outputData;
  } else {
    throw Exception('Unsupported output type: ${outputData.runtimeType}');
  }
}

// Top-level helper to interpret results.
List<double> convertLogitsToProbabilities(List<double> logits) {
  // Apply softmax to convert logits to probabilities
  final expValues = logits.map((x) => exp(x)).toList();
  final sumExp = expValues.reduce((a, b) => a + b);
  return expValues.map((x) => x / sumExp).toList();
}

String interpretResults(List<double> logits) {
  const categories = [
    'T-shirt/top',
    'Trouser',
    'Pullover',
    'Dress',
    'Coat',
    'Sandal',
    'Shirt',
    'Sneaker',
    'Bag',
    'Ankle boot',
  ];

  final probabilities = convertLogitsToProbabilities(logits);

  // Print all probabilities for debugging
  for (int i = 0; i < probabilities.length; i++) {
    print(
      "Class: ${categories[i]}, Probability: ${probabilities[i].toStringAsFixed(4)}",
    );
  }

  final maxIndex = probabilities.indexOf(
    probabilities.reduce((a, b) => a > b ? a : b),
  );
  return categories[maxIndex];
}

// This function must be top-level.
Future<String> classifyClothingIsolate(Map<String, dynamic> params) async {
  final String imagePath = params['imagePath'];
  final Uint8List modelBytes = params['modelBytes'];

  final interpreter = Interpreter.fromBuffer(
    modelBytes,
    options: InterpreterOptions()..threads = 4,
  );

  try {
    final imageBytes = await File(imagePath).readAsBytes();
    final originalImage = img.decodeImage(imageBytes)!;
    final processedBytes = preprocessImage(originalImage);
    debugPrintImage(processedBytes); // Add debug visualization

    final inputTensor = interpreter.getInputTensors()[0];
    final outputTensor = interpreter.getOutputTensors()[0];

    print("Input Tensor Shape: ${inputTensor.shape}");
    print("Input Tensor Type: ${inputTensor.type}");

    // Normalize and reshape input
    List<double> normalized = processedBytes.map((b) => b / 255.0).toList();
    print("First 10 normalized values: ${normalized.sublist(0, 10)}");

    // Choose the correct reshape function based on model input shape
    dynamic input;
    if (inputTensor.shape.length == 3) {
      input = [reshapeTo3D(normalized)];
    } else {
      input = [reshapeTo4D(normalized, inputTensor.shape)];
    }

    final output = createOutputBuffer(outputTensor);
    interpreter.run(input, output);
    final results = convertOutput(output, outputTensor);

    print("Raw Model Output: $results");
    return interpretResults(results);
  } finally {
    interpreter.close();
  }
}

// Top-level function to run model inference in an isolate.
// This function accepts only sendable arguments (here, just the image path).
