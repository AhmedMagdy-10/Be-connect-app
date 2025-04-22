import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qoute_app/logic/cubit/home_cubit.dart';
import 'package:qoute_app/screens/splash/splash_screen.dart';
import 'package:qoute_app/screens/SugeestionClothes/dataModal/clothes_data_model.dart';
import 'package:qoute_app/testing/outfits_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://dgxylvvwydrkcvhcouzt.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRneHlsdnZ3eWRya2N2aGNvdXp0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI3ODYwNDksImV4cCI6MjA1ODM2MjA0OX0.Ccx_84jOz3muAb6VzEkHCetON4VLhK7fdDjVR9SdCyI',
    realtimeClientOptions: const RealtimeClientOptions(
      timeout: Duration(minutes: 2),
      logLevel: RealtimeLogLevel.info,
    ),
  );

  await loadModelBytes();

  try {
    final interpreter = Interpreter.fromBuffer(
      modelBytes,
      options: InterpreterOptions()..threads = 4,
    );
    final inputTensor = interpreter.getInputTensors()[0];
    print(
      'Input Tensor: ${inputTensor.name}, shape: ${inputTensor.shape}, type: ${inputTensor.type}',
    );
    print('Input Tensors: ${interpreter.getInputTensors()}');
    print('Output Tensors: ${interpreter.getOutputTensors()}');
    interpreter.close();
  } catch (e) {
    print('Model validation failed: $e');
  }
  runApp(const MyClothesApp());
}

class MyClothesApp extends StatelessWidget {
  const MyClothesApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeCubit>(
      create: (context) => HomeCubit(),
      child: MaterialApp(
        title: 'My Clothes App',
        theme: ThemeData(
          fontFamily: 'Cairo',
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),

          useMaterial3: true,
        ),
        home: const SplashView(),
      ),
    );
  }
}
