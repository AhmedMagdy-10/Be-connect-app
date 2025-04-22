// import 'dart:io';
// import 'dart:math';
// import 'dart:typed_data';
// import 'package:flutter/services.dart';
// import 'package:image/image.dart' as img;
// import 'package:image/image.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';

// class FashionMNISTClassifier {
//   // Configuration Constants
//   static const _modelPath = 'assets/models/fashion_mnist.tflite';
//   static const _inputSize = 28;
//   static const _categories = [
//     'T-shirt/top',
//     'Trouser',
//     'Pullover',
//     'Dress',
//     'Coat',
//     'Sandal',
//     'Shirt',
//     'Sneaker',
//     'Bag',
//     'Ankle boot',
//   ];
//   static const _confidenceThreshold = 0.7;

//   // Model Instance
//   static Interpreter? _interpreter;

//   // Initialization
//   static Future<void> initialize() async {
//     final modelData = await rootBundle.load(_modelPath);
//     final modelBytes = modelData.buffer.asUint8List(
//       modelData.offsetInBytes,
//       modelData.lengthInBytes,
//     );
//     _interpreter = await Interpreter.fromBuffer(modelBytes);

//     print('Model loaded. Input details: ${_interpreter!.getInputTensors()}');
//     print('Output details: ${_interpreter!.getOutputTensors()}');
//   }

//   // Classification Pipeline
//   static Future<ClassificationResult> classifyImage(String imagePath) async {
//     // 1. Load and preprocess image
//     final imageBytes = await File(imagePath).readAsBytes();
//     final processed = preprocessImage(img.decodeImage(imageBytes)!);

//     // 2. Prepare input tensor
//     final inputTensor = _interpreter!.getInputTensors().first;
//     final inputBuffer = _prepareInput(processed, inputTensor);

//     // 3. Run inference
//     final outputBuffer = _prepareOutputBuffer();
//     _interpreter!.run([inputBuffer], outputBuffer);

//     // 4. Process results
//     return _interpretOutput(outputBuffer);
//   }

//   // Image Preprocessing
//   static Uint8List preprocessImage(img.Image original) {
//     final oriented = img.bakeOrientation(original);
//     final resized = img.copyResize(
//       img.grayscale(oriented),
//       width: _inputSize,
//       height: _inputSize,
//     );

//     final bytes = Uint8List(_inputSize * _inputSize);
//     int lightPixels = 0;

//     // Background analysis
//     for (int i = 0; i < bytes.length; i++) {
//       final luminance =
//           img
//               .getLuminance(resized.getPixel(i % _inputSize, i ~/ _inputSize))
//               .toInt();
//       if (luminance > 200) lightPixels++;
//     }

//     final invert = lightPixels > bytes.length ~/ 2;

//     // Pixel processing
//     for (int i = 0; i < bytes.length; i++) {
//       final luminance =
//           img
//               .getLuminance(resized.getPixel(i % _inputSize, i ~/ _inputSize))
//               .toInt();

//       bytes[i] = (invert ? 255 - luminance : luminance).clamp(0, 255);
//     }

//     return bytes;
//   }

//   static Float32List normalizeForFloat(Uint8List bytes) {
//     return Float32List.fromList(bytes.map((b) => b / 255.0).toList());
//   }

//   // Input Preparation
//   static dynamic _prepareInput(Uint8List bytes, Tensor inputTensor) {
//     final isQuantized = inputTensor.type == TensorType.uint8;
//     final shape = inputTensor.shape;

//     if (isQuantized) {
//       return bytes.buffer.asUint8List();
//     } else {
//       return Float32List.fromList(
//         bytes.map((b) => b / 255.0).toList(),
//       ).reshape(shape);
//     }
//   }

//   // Output Handling
//   static List<Object> _prepareOutputBuffer() {
//     final outputTensor = _interpreter!.getOutputTensors().first;
//     final length = outputTensor.shape.reduce((a, b) => a * b);

//     return outputTensor.type == TensorType.uint8
//         ? [Uint8List(length)]
//         : [Float32List(length)];
//   }

//   static ClassificationResult _interpretOutput(List<Object> output) {
//     final rawOutput = output.first;
//     final probabilities =
//         rawOutput is Float32List
//             ? _softmax(rawOutput)
//             : _dequantizeManual(output[0] as Uint8List);

//     final maxProb = probabilities.reduce(max);
//     final maxIndex = probabilities.indexOf(maxProb);

//     return ClassificationResult(
//       label:
//           maxProb >= _confidenceThreshold ? _categories[maxIndex] : 'Uncertain',
//       confidence: maxProb,
//       probabilities: probabilities,
//     );
//   }

//   // Helper Methods
//   static List<double> _softmax(Float32List logits) {
//     final expValues = logits.map(exp).toList();
//     final sum = expValues.reduce((a, b) => a + b);
//     return expValues.map((v) => v / sum).toList();
//   }

//   static List<double> _dequantizeManual(Uint8List quantized) {
//     // Get these from model training/export
//     const scale = 0.007843;
//     const zeroPoint = 127;

//     return quantized.map((q) => (q - zeroPoint) * scale).toList();
//   }

//   static void _debugSaveImage(Uint8List bytes) async {
//     final image = img.Image.fromBytes(
//       width: _inputSize,
//       height: _inputSize,
//       bytes: bytes.buffer,
//       format: img.Format.uint8,
//     );

//     final png = img.encodePng(image);
//     await File('debug.png').writeAsBytes(png);
//   }

//   static void dispose() {
//     _interpreter?.close();
//     _interpreter = null;
//   }
// }

// // Result Model
// class ClassificationResult {
//   final String label;
//   final double confidence;
//   final List<double> probabilities;

//   ClassificationResult({
//     required this.label,
//     required this.confidence,
//     required this.probabilities,
//   });
// }

// // Usage Example
// void main() async {
//   await FashionMNISTClassifier.initialize();

//   final result = await FashionMNISTClassifier.classifyImage(
//     'path/to/image.jpg',
//   );

//   print('''
//   Classification Result:
//   Label: ${result.label}
//   Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%
//   ''');

//   FashionMNISTClassifier.dispose();
// }
