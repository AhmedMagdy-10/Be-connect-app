import 'package:flutter/material.dart';

class ClothingItem {
  final String id;
  final String imageUrl;
  final String type;
  final List<Color> colors;
  final DateTime timestamp;

  ClothingItem({
    required this.id,
    required this.imageUrl,
    required this.type,
    required List<dynamic> colors,
    required this.timestamp,
  }) : colors =
           colors.map((c) {
             if (c is Color) return c;
             if (c is int) return Color(c);
             if (c is String) {
               try {
                 return Color(int.parse(c.replaceFirst('#', ''), radix: 16));
               } catch (e) {
                 return Colors.grey;
               }
             }
             return Colors.grey;
           }).toList();
}

class Outfit {
  final List<ClothingItem> tops;
  final List<ClothingItem> bottoms;
  final List<ClothingItem> outerwear;
  final double compatibilityScore;
  final String id;

  Outfit({
    required this.tops,
    required this.bottoms,
    this.outerwear = const [],
    required this.compatibilityScore,
  }) : id =
           '${tops.map((t) => t.id).join()}-${bottoms.map((b) => b.id).join()}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Outfit &&
          runtimeType == other.runtimeType &&
          tops == other.tops &&
          bottoms == other.bottoms &&
          id == other.id;

  @override
  int get hashCode => tops.hashCode ^ bottoms.hashCode;
}

class OutfitGenerator {
  static const double _minimumCompatibilityScore = 0.6;
  static const double _classicCombinationThreshold = 0.8;

  // Color detection
  static bool isBlack(Color color) {
    return color.red < 50 && color.green < 50 && color.blue < 50;
  }

  static bool containsBlack(List<Color> colors) {
    return colors.any(isBlack);
  }

  static bool isTeal(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.hue >= 160 && hsl.hue <= 200 && hsl.saturation > 0.4;
  }

  static bool isNeutral(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.saturation < 0.2 ||
        (hsl.lightness > 0.8 && hsl.saturation < 0.3);
  }

  // Combination detection
  static bool isClassicCombination(Color c1, Color c2) {
    return _isTealBlackPair(c1, c2) || _isBlackNeutralPair(c1, c2);
  }

  static bool _isTealBlackPair(Color c1, Color c2) {
    return (isTeal(c1) && isBlack(c2)) || (isTeal(c2) && isBlack(c1));
  }

  static bool _isBlackNeutralPair(Color c1, Color c2) {
    return (isBlack(c1) && isNeutral(c2)) || (isBlack(c2) && isNeutral(c1));
  }

  // Item filtering
  static List<ClothingItem> filterItems(
    List<ClothingItem> items,
    List<String> types,
  ) {
    return items
        .where(
          (item) => types.any((type) => item.type.toLowerCase().contains(type)),
        )
        .toList();
  }

  // Enhanced outfit generation
  static List<Outfit> generateOutfits(List<ClothingItem> items) {
    final tops = filterItems(items, [
      'shirt',
      't-shirt',
      'top',
      'blouse',
      'pullover',
    ]);
    final bottoms = filterItems(items, ['pant', 'jean', 'trouser', 'skirt']);
    final outerwear = filterItems(items, ['jacket', 'coat', 'cardigan']);

    final Set<Outfit> suggestions = {};

    // Generate all possible combinations
    for (final top in tops) {
      for (final bottom in bottoms) {
        final score = calculateCompatibilityScore(top, bottom);

        if (score >= _minimumCompatibilityScore) {
          suggestions.add(
            Outfit(
              tops: [top],
              bottoms: [bottom],
              outerwear: _findMatchingOuterwear(top, bottom, outerwear),
              compatibilityScore: score,
            ),
          );
        }
      }
    }

    // Return sorted list
    return suggestions.toList()
      ..sort((a, b) => b.compatibilityScore.compareTo(a.compatibilityScore));
  }

  static double calculateCompatibilityScore(
    ClothingItem top,
    ClothingItem bottom,
  ) {
    if (top.colors.isEmpty || bottom.colors.isEmpty) return 0.0;

    final colorScore = _calculateColorScore(
      top.colors.first,
      bottom.colors.first,
    );
    final styleScore = _calculateStyleScore(top.type, bottom.type);

    return (colorScore * 0.7 + styleScore * 0.3).clamp(0.0, 1.0);
  }

  static double _calculateColorScore(Color c1, Color c2) {
    if (isBlack(c1) || isBlack(c2)) return 1.0;
    if (isClassicCombination(c1, c2)) return _classicCombinationThreshold;

    final hsl1 = HSLColor.fromColor(c1);
    final hsl2 = HSLColor.fromColor(c2);
    final hueDiff = (hsl1.hue - hsl2.hue).abs() % 360;
    final normalizedDiff = hueDiff > 180 ? 360 - hueDiff : hueDiff;

    // Penalize clashing color combinations
    if (normalizedDiff > 90 && normalizedDiff < 150) return 0.3;
    if (normalizedDiff > 210 && normalizedDiff < 270) return 0.2;

    // Calculate base score
    double score = 1.0 - (normalizedDiff / 180);

    // Adjust for saturation difference
    final satDiff = (hsl1.saturation - hsl2.saturation).abs();
    score *= 1.0 - (satDiff * 0.5);

    // Adjust for lightness difference
    final lightnessDiff = (hsl1.lightness - hsl2.lightness).abs();
    score *= 1.0 - (lightnessDiff * 0.3);

    return score.clamp(0.0, 1.0);
  }

  static double _calculateStyleScore(String topType, String bottomType) {
    final formalCombos = ['blouse', 'shirt', 'dress'];
    final casualCombos = ['t-shirt', 'jeans', 'skirt'];

    final isFormal =
        formalCombos.any((s) => topType.contains(s)) &&
        formalCombos.any((s) => bottomType.contains(s));
    final isCasual =
        casualCombos.any((s) => topType.contains(s)) &&
        casualCombos.any((s) => bottomType.contains(s));

    return isFormal || isCasual ? 1.0 : 0.7;
  }

  static List<ClothingItem> _findMatchingOuterwear(
    ClothingItem top,
    ClothingItem bottom,
    List<ClothingItem> outerwear,
  ) {
    return outerwear.where((item) {
      final topScore = _calculateColorScore(
        top.colors.first,
        item.colors.first,
      );
      final bottomScore = _calculateColorScore(
        bottom.colors.first,
        item.colors.first,
      );
      return (topScore + bottomScore) / 2 > 0.5;
    }).toList();
  }

  // UI Helpers
  static String getHarmonyType(Color c1, Color c2) {
    if (isBlack(c1) || isBlack(c2)) return 'Universal Match';
    if (isClassicCombination(c1, c2)) return 'Classic Combo';

    final hsl1 = HSLColor.fromColor(c1);
    final hsl2 = HSLColor.fromColor(c2);
    final hueDiff = (hsl1.hue - hsl2.hue).abs() % 360;
    final normalizedDiff = hueDiff > 180 ? 360 - hueDiff : hueDiff;

    if (normalizedDiff < 15) return 'Monochromatic';
    if (normalizedDiff < 45) return 'Analogous';
    if (normalizedDiff > 150 && normalizedDiff < 210) return 'Complementary';
    return 'Fashion Contrast';
  }

  static Color getHarmonyColor(BuildContext context, String harmonyType) {
    final theme = Theme.of(context);
    switch (harmonyType) {
      case 'Universal Match':
        return Colors.black;
      case 'Classic Combo':
        return Colors.teal;
      case 'Monochromatic':
        return theme.colorScheme.primaryContainer;
      case 'Analogous':
        return theme.colorScheme.secondaryContainer;
      case 'Complementary':
        return theme.colorScheme.tertiaryContainer;
      default:
        return theme.colorScheme.surface;
    }
  }
}
