import 'package:flutter/material.dart';
import 'package:qoute_app/core/functions/outfits_helper.dart';

class OutfitCard extends StatelessWidget {
  final Outfit outfit;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final bool isInFavoritesScreen;

  const OutfitCard({
    super.key,
    required this.outfit,
    required this.isFavorite,
    required this.onFavoriteToggle,
    this.isInFavoritesScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasBlack =
        _containsBlack(outfit.tops.first.colors) ||
        _containsBlack(outfit.bottoms.first.colors);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isInFavoritesScreen ? 6 : (hasBlack ? 4 : 2),
      color: isInFavoritesScreen ? Colors.grey[50] : null,
      shape:
          isInFavoritesScreen
              ? RoundedRectangleBorder(
                side: BorderSide(
                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(12),
              )
              : hasBlack
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasBlack && !isInFavoritesScreen)
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

                if (isInFavoritesScreen)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(Icons.favorite, color: Colors.red[400], size: 18),
                        const SizedBox(width: 4),
                        Text(
                          'Saved Outfit',
                          style: TextStyle(
                            color: Colors.red[400],
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
              right: 0,
              top: 0,
              child: IconButton(
                onPressed: onFavoriteToggle,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    key: ValueKey<bool>(isFavorite),
                    color: isFavorite ? Colors.red : Colors.grey,
                    size: 28,
                  ),
                ),
                splashRadius: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsRow(Outfit outfit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: outfit.tops.map((item) => _buildItemImage(item)).toList(),
        ),
        Column(
          children:
              outfit.bottoms.map((item) => _buildItemImage(item)).toList(),
        ),
      ],
    );
  }

  Widget _buildItemImage(ClothingItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: NetworkImage(item.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildColorPalette(Outfit outfit) {
    final allColors =
        [
          ...outfit.tops.expand((item) => item.colors),
          ...outfit.bottoms.expand((item) => item.colors),
        ].toSet().toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          allColors.map((color) {
            return Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300),
              ),
            );
          }).toList(),
    );
  }

  bool _containsBlack(List<Color> colors) {
    return OutfitGenerator.containsBlack(colors);
  }
}
