import 'package:flutter/material.dart';
import 'package:qoute_app/main.dart';
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

  // final bottoms = filterItems(items, ['pant', 'jean', 'trouser', 'skirt']);
  // final outerwear = filterItems(items, ['jacket', 'coat', 'cardigan']);

  // static List<Outfit> generateOutfits(List<ClothingItem> items) {
  //   final tops = filterItems(items, [
  //     'shirt',
  //     't-shirt',
  //     'top',
  //     'blouse',
  //     'pullover',
  //   ]);
  // }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Outfit Suggestion')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase
            .from('clothes')
            .stream(primaryKey: ['id'])
            .order('created_at'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final items =
              snapshot.data!
                  .map(
                    (doc) => ClothingItem(
                      id: doc['id'].toString(),
                      imageUrl: doc['image_url'],
                      type: doc['type'],
                      colors: doc['colors'],
                      timestamp: DateTime.parse(doc['created_at']),
                    ),
                  )
                  .toList();

          final outfits = OutfitGenerator.generateOutfits(items);

          if (outfits.isEmpty) {
            return Center(child: Text('No outfit suggestions available'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: outfits.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final outfit = outfits[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Outfit Suggestion',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Compatibility: ${(outfit.compatibilityScore * 100).toStringAsFixed(1)}%',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          OutfitItem(imageUrl: outfit.tops.first.imageUrl),
                          const SizedBox(width: 16),
                          OutfitItem(imageUrl: outfit.bottoms.first.imageUrl),
                          if (outfit.outerwear.isNotEmpty) ...[
                            const SizedBox(width: 16),
                            OutfitItem(
                              imageUrl: outfit.outerwear.first.imageUrl,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Save Outfit'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 40),
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
    );
  }

  Widget _buildOutfitCard(BuildContext context, Outfit outfit) {
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
        child: Column(
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
