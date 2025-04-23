import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:qoute_app/constant/colors.dart';
import 'package:qoute_app/logic/cubit/home_cubit.dart';
import 'package:qoute_app/logic/cubit/home_states_cubit.dart';

import 'package:qoute_app/core/functions/outfits_helper.dart';

class HomePageBody extends StatelessWidget {
  const HomePageBody({super.key});

  /// Extract a palette of dominant colors using PaletteGenerator
  Future<List<Color>> extractDominantColors(String imagePath) async {
    final image = FileImage(File(imagePath));
    final paletteGenerator = await PaletteGenerator.fromImageProvider(image);

    final colors = <Color>[
      paletteGenerator.dominantColor?.color ?? Colors.white,
      paletteGenerator.mutedColor?.color ?? Colors.white,
      paletteGenerator.lightVibrantColor?.color ?? Colors.white,
      paletteGenerator.darkMutedColor?.color ?? Colors.white,
    ];

    // Remove duplicates and limit to 3 colors
    final uniqueColors = colors.toSet().take(3).toList();
    return uniqueColors;
  }

  /// Upload an image: pick from gallery, run classification, extract colors, and save to Supabase.
  //////////////////////////////////////////////////////////////////////
  /// Delete an item both from the Supabase database and storage.

  /// Build error widget for stream errors.
  Widget buildErrorWidget(Object error) {
    return Center(
      child: Text('Error: $error', style: const TextStyle(color: Colors.red)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeStatesCubit>(
      builder:
          (context, state) => Scaffold(
            extendBody: true,
            appBar: AppBar(
              title: const Text('Fashion Assistant'),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.view_agenda_outlined,
                    size: 20,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),

            // floatingActionButtonLocation:
            //     FloatingActionButtonLocation.centerDocked,
            // floatingActionButton: FloatingActionButton(
            //   backgroundColor: Colors.blue,
            //   shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(50),
            //   ),
            //   onPressed: () {},
            //   child: Icon(
            //     Icons.camera_alt_outlined,
            //     color: Colors.white,
            //     size: 28,
            //   ),
            // ),
            body: Center(
              child: Column(
                children: [
                  ElevatedButton.icon(
                    // style: ButtonStyle(
                    //   iconColor: WidgetStatePropertyAll(Colors.white),
                    //   backgroundColor: WidgetStatePropertyAll(
                    //     Color(0xff1c1c1c),
                    //   ),
                    // ),
                    label: Text(
                      'Upload Image',
                      // style: TextStyle(color: Colors.white),
                    ),
                    icon: Icon(Icons.photo_library_rounded),
                    onPressed: () {},
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 24,
                        bottom: 16,
                      ),
                      child: StreamBuilder<List<Map<String, dynamic>>>(
                        stream: BlocProvider.of<HomeCubit>(context).supabase
                            .from('clothes')
                            .stream(primaryKey: ['id'])
                            .order('created_at', ascending: false),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return LottieBuilder.asset(
                              'assets/Animation - 1744956893461.json',
                              width: 170,
                              height: 170,
                            );
                          }
                          if (snapshot.hasError) {
                            return buildErrorWidget(snapshot.error!);
                          }
                          if (!snapshot.hasData) {
                            return Center(
                              child: LottieBuilder.asset(
                                'assets/Animation - 1744956893461.json',
                                width: 70,
                                height: 70,
                              ),
                            );
                          }

                          final items =
                              snapshot.data!
                                  .map(
                                    (doc) => ClothingItem(
                                      id: doc['id'].toString(),
                                      imageUrl: doc['image_url'],
                                      type: doc['type'],
                                      colors:
                                          (doc['colors'] as List)
                                              .map((c) => Color(c as int))
                                              .toList(),
                                      timestamp: DateTime.parse(
                                        doc['created_at'],
                                      ),
                                    ),
                                  )
                                  .toList();

                          return GridView.builder(
                            // padding: EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 0.8,
                                ),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return Dismissible(
                                key: Key(item.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Icon(Icons.delete),
                                ),
                                confirmDismiss: (direction) async {
                                  return await showDialog(
                                    context: context,

                                    builder:
                                        (ctx) => AlertDialog(
                                          title: const Text('Confirm Delete'),
                                          content: const Text(
                                            'Delete this item permanently?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () =>
                                                      Navigator.pop(ctx, false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed:
                                                  () =>
                                                      Navigator.pop(ctx, true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                  );
                                },
                                onDismissed:
                                    (direction) => BlocProvider.of<HomeCubit>(
                                      context,
                                    ).deleteItem(item, context),
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(16),
                                              ),
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                '${item.imageUrl}?cache=${DateTime.now().millisecondsSinceEpoch}',
                                            fit: BoxFit.contain,
                                            width: double.infinity,
                                            placeholder:
                                                (context, url) => Center(
                                                  child: LottieBuilder.asset(
                                                    'assets/Animation - 1744956893461.json',
                                                    width: 70,
                                                    height: 70,
                                                  ),
                                                ),
                                            errorWidget:
                                                (
                                                  context,
                                                  url,
                                                  error,
                                                ) => Container(
                                                  color: Colors.grey[200],
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Icon(
                                                        Icons.error,
                                                        size: 40,
                                                      ),
                                                      Text(
                                                        'Image not found\n${item.type}',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.type.toUpperCase(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children:
                                                  item.colors
                                                      .map(
                                                        (color) => Container(
                                                          width: 20,
                                                          height: 20,
                                                          margin:
                                                              const EdgeInsets.only(
                                                                right: 4,
                                                              ),
                                                          decoration:
                                                              BoxDecoration(
                                                                color: color,
                                                                shape:
                                                                    BoxShape
                                                                        .circle,
                                                                border: Border.all(
                                                                  color:
                                                                      Colors
                                                                          .grey,
                                                                  width: 1,
                                                                ),
                                                              ),
                                                        ),
                                                      )
                                                      .toList(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
