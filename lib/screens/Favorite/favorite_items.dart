import 'package:flutter/material.dart';
import 'package:qoute_app/core/functions/cache_helper.dart';
import 'package:qoute_app/core/functions/outfits_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoriteOutfitsScreen extends StatefulWidget {
  const FavoriteOutfitsScreen({super.key});

  @override
  State<FavoriteOutfitsScreen> createState() => _FavoriteOutfitsScreenState();
}

class _FavoriteOutfitsScreenState extends State<FavoriteOutfitsScreen> {
  final supabase = Supabase.instance.client;
  List<int> _favoriteIndexes = [];
  late Stream<List<ClothingItem>> _clothingStream;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _clothingStream = getClothingStream();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final saved = await CacheHelper.getSaveData(key: 'favorites') ?? [];
    if (mounted) {
      setState(() {
        _favoriteIndexes =
            (saved as List<dynamic>)
                .map((e) => int.parse(e.toString()))
                .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Outfits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFavorites,
            tooltip: 'Refresh favorites',
          ),
        ],
      ),
      body: StreamBuilder<List<ClothingItem>>(
        stream: _clothingStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No clothing items found'));
          }

          final allOutfits = OutfitGenerator.generateOutfits(snapshot.data!);
          final validFavorites =
              _favoriteIndexes
                  .where((index) => index < allOutfits.length)
                  .toList();

          if (validFavorites.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 50, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No favorite outfits yet!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: validFavorites.length,
            itemBuilder: (context, index) {
              final outfitIndex = validFavorites[index];
              final outfit = allOutfits[outfitIndex];

              return _buildFavoriteCard(outfit, outfitIndex);
            },
          );
        },
      ),
    );
  }

  Widget _buildFavoriteCard(Outfit outfit, int originalIndex) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.red, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Saved Outfit',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.grey),
                  onPressed: () => _removeFavorite(originalIndex),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildClothingPreview(outfit),
            const SizedBox(height: 12),
            _buildColorPalette(outfit),
          ],
        ),
      ),
    );
  }

  Widget _buildClothingPreview(Outfit outfit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            Text(
              'Top',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(outfit.tops.first.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Text(outfit.tops.first.type, style: const TextStyle(fontSize: 12)),
          ],
        ),
        Column(
          children: [
            Text(
              'Bottom',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(outfit.bottoms.first.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Text(
              outfit.bottoms.first.type,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildColorPalette(Outfit outfit) {
    final colors = [
      ...outfit.tops.first.colors,
      ...outfit.bottoms.first.colors,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color Palette',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((color) => _buildColorCircle(color)).toList(),
        ),
      ],
    );
  }

  Widget _buildColorCircle(Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  Future<void> _removeFavorite(int index) async {
    setState(() => _favoriteIndexes.remove(index));
    await CacheHelper.saveData(key: 'favorites', value: _favoriteIndexes);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Removed from favorites'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Stream<List<ClothingItem>> getClothingStream() {
    return supabase
        .from('clothes')
        .stream(primaryKey: ['id'])
        .map((List<Map<String, dynamic>> items) {
          return items
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
                    timestamp: DateTime.parse(item['created_at'].toString()),
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
              .toList();
        })
        .handleError((error) {
          print('Stream error: $error');
          return <ClothingItem>[];
        });
  }
}
