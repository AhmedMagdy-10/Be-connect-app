import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:qoute_app/logic/cubit/home_cubit.dart';
import 'package:qoute_app/logic/cubit/home_states_cubit.dart';
import 'package:qoute_app/testing/home_widget.dart';
import 'package:qoute_app/testing/outfits_helper.dart';

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
            appBar: AppBar(title: const Text('Fashion Assistant')),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Add Clothing Item'),
                    onPressed:
                        () => BlocProvider.of<HomeCubit>(
                          context,
                        ).uploadImage(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        const TabBar(
                          tabs: [
                            Tab(
                              icon: Icon(Icons.photo_library),
                              text: 'My Wardrobe',
                            ),
                            Tab(icon: Icon(Icons.style), text: 'Suggestions'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              // Wardrobe Tab: Display uploaded clothing items.
                              StreamBuilder<List<Map<String, dynamic>>>(
                                stream: BlocProvider.of<HomeCubit>(context)
                                    .supabase
                                    .from('clothes')
                                    .stream(primaryKey: ['id'])
                                    .order('created_at', ascending: false),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return LottieBuilder.asset(
                                      'assets/Animation - 1744956893461.json',
                                      width: 20,
                                      height: 20,
                                    );
                                  }
                                  if (snapshot.hasError) {
                                    return buildErrorWidget(snapshot.error!);
                                  }
                                  if (!snapshot.hasData) {
                                    return Center(
                                      child: LottieBuilder.asset(
                                        'assets/Animation - 1744956893461.json',
                                        width: 20,
                                        height: 20,
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
                                                      .map(
                                                        (c) => Color(c as int),
                                                      )
                                                      .toList(),
                                              timestamp: DateTime.parse(
                                                doc['created_at'],
                                              ),
                                            ),
                                          )
                                          .toList();

                                  return GridView.builder(
                                    padding: const EdgeInsets.all(16),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 16,
                                          mainAxisSpacing: 16,
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
                                          padding: const EdgeInsets.only(
                                            right: 20,
                                          ),
                                          child: FaIcon(
                                            FontAwesomeIcons.deleteLeft,
                                          ),
                                        ),
                                        confirmDismiss: (direction) async {
                                          return await showDialog(
                                            context: context,

                                            builder:
                                                (ctx) => AlertDialog(
                                                  title: const Text(
                                                    'Confirm Delete',
                                                  ),
                                                  content: const Text(
                                                    'Delete this item permanently?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed:
                                                          () => Navigator.pop(
                                                            ctx,
                                                            false,
                                                          ),
                                                      child: const Text(
                                                        'Cancel',
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed:
                                                          () => Navigator.pop(
                                                            ctx,
                                                            true,
                                                          ),
                                                      child: const Text(
                                                        'Delete',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          );
                                        },
                                        onDismissed:
                                            (direction) =>
                                                BlocProvider.of<HomeCubit>(
                                                  context,
                                                ).deleteItem(item, context),
                                        child: Card(
                                          elevation: 4,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.vertical(
                                                        top: Radius.circular(
                                                          16,
                                                        ),
                                                      ),
                                                  child: CachedNetworkImage(
                                                    imageUrl:
                                                        '${item.imageUrl}?cache=${DateTime.now().millisecondsSinceEpoch}',
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    placeholder:
                                                        (
                                                          context,
                                                          url,
                                                        ) => Center(
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
                                                          color:
                                                              Colors.grey[200],
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
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item.type.toUpperCase(),
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      children:
                                                          item.colors
                                                              .map(
                                                                (
                                                                  color,
                                                                ) => Container(
                                                                  width: 20,
                                                                  height: 20,
                                                                  margin:
                                                                      const EdgeInsets.only(
                                                                        right:
                                                                            4,
                                                                      ),
                                                                  decoration: BoxDecoration(
                                                                    color:
                                                                        color,
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

                              // Recommendations Tab
                              //   StreamBuilder<List<Map<String, dynamic>>>(
                              //     stream: supabase
                              //         .from('clothes')
                              //         .stream(primaryKey: ['id'])
                              //         .order('created_at'),
                              //     builder: (context, snapshot) {
                              //       if (!snapshot.hasData) {
                              //         return Center(child: CircularProgressIndicator());
                              //       }

                              //       final items =
                              //           snapshot.data!.map((doc) {
                              //             print(
                              //               'Item type: ${doc['type']}, Colors: ${doc['colors']}',
                              //             );
                              //             return ClothingItem(
                              //               id: doc['id'].toString(),
                              //               imageUrl: doc['image_url'],
                              //               type: doc['type'],
                              //               colors: doc['colors'],
                              //               timestamp: DateTime.parse(
                              //                 doc['created_at'],
                              //               ),
                              //             );
                              //           }).toList();

                              //       final outfits = OutfitGenerator.generateOutfits(
                              //         items,
                              //       );

                              //       if (outfits.isEmpty) {
                              //         return Column(
                              //           mainAxisAlignment: MainAxisAlignment.center,
                              //           children: [
                              //             Icon(
                              //               Icons.warning,
                              //               size: 50,
                              //               color: Colors.amber,
                              //             ),
                              //             const SizedBox(height: 20),
                              //             Text(
                              //               items.isEmpty
                              //                   ? 'No clothing items found\nStart by adding items to your wardrobe!'
                              //                   : 'Need at least 1 top and 1 bottom\nto generate outfit suggestions',
                              //               textAlign: TextAlign.center,
                              //               style: TextStyle(fontSize: 18),
                              //             ),
                              //             if (items.isNotEmpty) ...[
                              //               const SizedBox(height: 20),
                              //               _buildTypeDebugView(
                              //                 items,
                              //               ), // Add debug view
                              //             ],
                              //           ],
                              //         );
                              //       }
                              //       return ListView.separated(
                              //         padding: const EdgeInsets.all(16),
                              //         itemCount: outfits.length,
                              //         separatorBuilder:
                              //             (_, __) => const SizedBox(height: 16),
                              //         itemBuilder: (context, index) {
                              //           final outfit = outfits[index];
                              //           return Card(
                              //             elevation: 4,
                              //             shape: RoundedRectangleBorder(
                              //               borderRadius: BorderRadius.circular(16),
                              //             ),
                              //             child: Padding(
                              //               padding: const EdgeInsets.all(16),
                              //               child: Column(
                              //                 crossAxisAlignment:
                              //                     CrossAxisAlignment.start,
                              //                 children: [
                              //                   const Text(
                              //                     'Outfit Suggestion',
                              //                     style: TextStyle(
                              //                       fontSize: 16,
                              //                       fontWeight: FontWeight.bold,
                              //                     ),
                              //                   ),
                              //                   const SizedBox(height: 8),
                              //                   Text(
                              //                     'Compatibility: ${(outfit.compatibilityScore * 100).toStringAsFixed(1)}%',
                              //                     style: TextStyle(
                              //                       color: Colors.grey[600],
                              //                     ),
                              //                   ),
                              //                   const SizedBox(height: 16),
                              //                   Row(
                              //                     children: [
                              //                       _OutfitItem(
                              //                         imageUrl:
                              //                             outfit.tops.first.imageUrl,
                              //                       ),
                              //                       const SizedBox(width: 16),
                              //                       _OutfitItem(
                              //                         imageUrl:
                              //                             outfit.bottoms.first.imageUrl,
                              //                       ),
                              //                       if (outfit
                              //                           .outerwear
                              //                           .isNotEmpty) ...[
                              //                         const SizedBox(width: 16),
                              //                         _OutfitItem(
                              //                           imageUrl:
                              //                               outfit
                              //                                   .outerwear
                              //                                   .first
                              //                                   .imageUrl,
                              //                         ),
                              //                       ],
                              //                     ],
                              //                   ),
                              //                   const SizedBox(height: 16),
                              //                   ElevatedButton(
                              //                     onPressed: () {},
                              //                     child: const Text('Save Outfit'),
                              //                     style: ElevatedButton.styleFrom(
                              //                       minimumSize: const Size(
                              //                         double.infinity,
                              //                         40,
                              //                       ),
                              //                     ),
                              //                   ),
                              //                 ],
                              //               ),
                              //             ),
                              //           );
                              //         },
                              //       );
                              //     },
                              //   ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => OutfitSuggestionScreen(),
                  ),
                );
              },
              child: Icon(Icons.table_rows_rounded),
            ),
          ),
    );
  }
}
