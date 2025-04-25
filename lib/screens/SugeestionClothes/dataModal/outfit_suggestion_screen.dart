import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:qoute_app/core/functions/cache_helper.dart';
import 'package:qoute_app/core/helper/icon_broken.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:qoute_app/core/functions/outfits_helper.dart';

class OutfitSuggestionScreen extends StatefulWidget {
  const OutfitSuggestionScreen({super.key});

  @override
  State<OutfitSuggestionScreen> createState() => _OutfitSuggestionScreenState();
}

class _OutfitSuggestionScreenState extends State<OutfitSuggestionScreen> {
  final supabase = Supabase.instance.client;
  late final Stream<List<ClothingItem>> _clothingStream;

  @override
  void initState() {
    super.initState();
    _clothingStream = _getClothingStream();
  }

  bool _isGreen(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.hue >= 80 && hsl.hue <= 160 && hsl.saturation > 0.4;
  }

  bool _containsGreen(List<Color> colors) => colors.any(_isGreen);

  bool _isGreenBlackCombo(Outfit outfit) {
    return _containsGreen(outfit.tops.first.colors) &&
        _containsBlack(outfit.bottoms.first.colors);
  }

  final bool? isFavorite = CacheHelper.getSaveData(key: 'isFavorite');
  List favoriteList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Outfit Suggestion'),
        scrolledUnderElevation: 0,
      ),

      body: StreamBuilder<List<ClothingItem>>(
        stream: _clothingStream,
        builder: (context, snapshot) {
          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LottieBuilder.asset(
                'assets/Animation - 1744956893461.json',
                width: 170,
                height: 170,
              ),
            );
          }

          // Handle errors
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Handle empty data
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No clothing items found. Add some items first!'),
            );
          }

          final outfits = OutfitGenerator.generateOutfits(snapshot.data!);
          // In your build method before generating outfits
          print('Top colors: ${snapshot.data?.first.colors}');
          print(
            'Is green: ${_isGreen(snapshot.data?.first.colors.first ?? Colors.white)}',
          );

          // In _buildOutfitCard

          print('Is green+black combo: $_isGreenBlackCombo(outfit)');
          // Handle no outfit suggestions
          if (outfits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.warning, size: 50, color: Colors.amber),
                  const SizedBox(height: 16),
                  const Text(
                    'No outfit suggestions available',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Need at least 1 top and 1 bottom',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: outfits.length,
            itemBuilder: (context, index) {
              print(index);
              final outfit = outfits[index];
              return _buildOutfitCard(context, outfit, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildOutfitCard(BuildContext context, Outfit outfit, int index) {
    final hasBlack =
        _containsBlack(outfit.tops.first.colors) ||
        _containsBlack(outfit.bottoms.first.colors);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: hasBlack ? 4 : 2,
      shape:
          hasBlack
              ? RoundedRectangleBorder(
                side: const BorderSide(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(12),
              )
              : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Column(
              children: [
                if (hasBlack)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.black, size: 18),
                        SizedBox(width: 4),
                        Text(
                          'Universal Matching',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                _buildItemsRow(outfit),
                const SizedBox(height: 12),
                _buildColorPalette(outfit),
              ],
            ),
            Positioned(
              right: 1,
              child: InkWell(
                onTap: () {},

                child: Icon(IconBroken.Heart, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add these helper methods to your screen class

  bool _containsBlack(List<Color> colors) {
    return OutfitGenerator.containsBlack(colors);
  }

  Widget _buildItemsRow(Outfit outfit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildClothingItemWithLabel(outfit.tops.first, 'Top'),
        const Icon(Icons.arrow_forward, color: Colors.grey),
        _buildClothingItemWithLabel(outfit.bottoms.first, 'Bottom'),
      ],
    );
  }

  Widget _buildClothingItemWithLabel(ClothingItem item, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(item.imageUrl),
          backgroundColor: Colors.grey[200],
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(
          item.type,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildColorPalette(Outfit outfit) {
    final colors = [
      ...outfit.tops.first.colors,
      ...outfit.bottoms.first.colors,
      ...outfit.outerwear.expand((item) => item.colors),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color Palette:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              colors
                  .map(
                    (color) => Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  Stream<List<ClothingItem>> _getClothingStream() {
    return supabase
        .from('clothes')
        .stream(primaryKey: ['id'])
        .map(
          (items) =>
              items
                  .map((item) {
                    try {
                      return ClothingItem(
                        id: item['id'].toString(),
                        imageUrl: item['image_url'].toString(),
                        type: item['type'].toString(),
                        colors:
                            (item['colors'] as List<dynamic>).map((c) {
                              if (c is int) return Color(c);
                              if (c is String) return Color(int.parse(c));
                              return Colors.grey;
                            }).toList(),
                        timestamp: DateTime.parse(
                          item['created_at'].toString(),
                        ),
                      );
                    } catch (e) {
                      print('Error parsing item: $e');
                      return ClothingItem(
                        id: 'error',
                        imageUrl: '',
                        type: 'Error',
                        colors: [Colors.grey],
                        timestamp: DateTime.now(),
                      );
                    }
                  })
                  .where((item) => item.id != 'error')
                  .toList(),
        )
        .handleError((error) {
          print('Stream error: $error');
          return <ClothingItem>[];
        });
  }
}
