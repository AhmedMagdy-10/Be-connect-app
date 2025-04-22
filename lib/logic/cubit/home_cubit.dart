import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:qoute_app/logic/cubit/home_states_cubit.dart';
import 'package:qoute_app/screens/SugeestionClothes/dataModal/clothes_data_model.dart';
import 'package:qoute_app/screens/SugeestionClothes/outfit_suggestion_screen.dart';
import 'package:qoute_app/screens/chosse/choose_color.dart';
import 'package:qoute_app/screens/home/widgets/home_screen_body.dart';
import 'package:qoute_app/testing/outfits_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeCubit extends Cubit<HomeStatesCubit> {
  HomeCubit() : super(HomeStatesInitial());

  // Home
  // suggestion
  // create
  // favourit
  int currentIndexPage = 0;
  List pages = [
    HomePageBody(),
    OutfitSuggestionScreen(),
    // create
    DressingType(),
    // favourit
  ];

  void togglePages(int currentIndex) {
    currentIndexPage = currentIndex;
    emit(CahngePages());
  }

  final _picker = ImagePicker();
  final supabase = Supabase.instance.client;

  Future<List<Color>> detectColors(String imagePath) async {
    final image = FileImage(File(imagePath));
    final paletteGenerator = await PaletteGenerator.fromImageProvider(image);

    return [
      paletteGenerator.dominantColor?.color ?? Colors.white,
      paletteGenerator.lightVibrantColor?.color ?? Colors.white,
      paletteGenerator.darkMutedColor?.color ?? Colors.white,
    ];
  }

  bool areColorsCompatible(List<Color> colors1, List<Color> colors2) {
    // Implement color theory logic here
    // Compare HSL values, complementary colors, etc.
    return true;
  }

  Future<void> uploadImage(BuildContext context) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No internet connection')));
      return;
    }

    if (pickedFile != null) {
      try {
        // Run model inference in an isolate using the top-level function.
        final clothingType = await compute(classifyClothingIsolate, {
          'imagePath': pickedFile.path,
          'modelBytes': modelBytes,
        });

        // Continue with file upload, color extraction, etc.
        final file = File(pickedFile.path);
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

        await supabase.storage.from('clothes').upload(fileName, file);

        final imageUrl = supabase.storage
            .from('clothes')
            .getPublicUrl(fileName)
            .replaceAllMapped(RegExp(r'%([0-9A-Fa-f]{2})'), (match) {
              return String.fromCharCode(int.parse(match[1]!, radix: 16));
            });

        final colors = await detectColors(pickedFile.path);

        await supabase.from('clothes').insert({
          'image_url': imageUrl,
          'type': clothingType,
          'colors': colors.map((c) => c.value).toList(),
          'created_at': DateTime.now().toIso8601String(),
        });

        print(
          'Upload successful - Type: $clothingType, Colors extracted: ${colors.length}',
        );
      } on PostgrestException catch (e) {
        print('Database error: ${e.message}');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Database error: ${e.message}')));
      } catch (e, stackTrace) {
        print('Upload failed: $e');
        print(stackTrace);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to upload item: $e')));
      }
    }
  }

  Future<void> deleteItem(ClothingItem item, BuildContext context) async {
    try {
      // Delete record from database.
      await supabase.from('clothes').delete().eq('id', item.id);
      // Delete the file from storage.
      final fileName = item.imageUrl.split('/').last;
      await supabase.storage.from('clothes').remove([fileName]);
      emit(HomeStatesSuccess());
    } catch (e) {
      print('Delete error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete: ${e.toString()}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
