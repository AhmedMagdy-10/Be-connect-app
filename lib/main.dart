import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qoute_app/logic/cubit/home_cubit.dart';
import 'package:qoute_app/screens/splash/splash_screen.dart';
import 'package:qoute_app/screens/SugeestionClothes/dataModal/clothes_data_model.dart';
import 'package:qoute_app/core/functions/outfits_helper.dart';
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
        debugShowCheckedModeBanner: false,
        title: 'My Clothes App',
        theme: ThemeData(
          fontFamily: 'Poppins',
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),

          useMaterial3: true,
        ),
        home: const SplashView(),
      ),
    );
  }
}

// Widget _buildTypeDebugView(List<ClothingItem> items) {
//   return ExpansionTile(
//     title: Text('Debug Info', style: TextStyle(color: Colors.grey)),
//     children: [
//       Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Total Items: ${items.length}'),
//             const SizedBox(height: 10),
//             Text(
//               'Detected Types:',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             ...items.map(
//               (item) => Text('- ${item.type} (Colors: ${item.colors.length})'),
//             ),
//           ],
//         ),
//       ),
//     ],
//   );
// }

// class _OutfitItem extends StatelessWidget {
//   final String imageUrl;

//   const _OutfitItem({required this.imageUrl});
//   String getImageUrl(String baseUrl) {
//     return '$baseUrl?cache=${DateTime.now().millisecondsSinceEpoch}';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: AspectRatio(
//         aspectRatio: 1,
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(12),
//           child: Image.network(
//             getImageUrl(imageUrl),
//             fit: BoxFit.cover,
//             width: double.infinity,
//             errorBuilder: (context, error, stackTrace) {
//               return Container(
//                 color: Colors.grey[200],
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(Icons.error, size: 40),
//                     Text(
//                       'Image not found\n$imageUrl',
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(fontSize: 12),
//                     ),
//                   ],
//                 ),
//               );
//             },
//             loadingBuilder: (context, child, loadingProgress) {
//               if (loadingProgress == null) return child;
//               return Center(
//                 child: CircularProgressIndicator(
//                   value:
//                       loadingProgress.expectedTotalBytes != null
//                           ? loadingProgress.cumulativeBytesLoaded /
//                               loadingProgress.expectedTotalBytes!
//                           : null,
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ResultScreen extends StatelessWidget {
//   final String title;
//   final List<String> results;

//   const ResultScreen({Key? key, required this.title, required this.results})
//     : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(title)),
//       body: ListView.builder(
//         itemCount: results.length,
//         itemBuilder: (context, index) {
//           return ListTile(title: Text(results[index]));
//         },
//       ),
//     );
//   }
// }
