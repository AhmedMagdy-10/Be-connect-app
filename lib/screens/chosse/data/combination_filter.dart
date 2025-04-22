import 'package:flutter/material.dart';
import 'formal_combination.dart';

class CombinationFilter {
  // Get shirts that match selected pants OR all shirts if no pants selected
  static List<Color> getSuggestedShirts(List<Color> selectedPants) {
    if (selectedPants.isEmpty) return [];

    final pantsValues = selectedPants.map((c) => c.value).toList();
    return formalCombinations
        .where((comb) => pantsValues.contains((comb['pants'] as Color).value))
        .map((comb) => comb['shirt'] as Color)
        .toSet()
        .toList();
  }

  // Get shoes that match pants OR shirts (whichever is selected)
  static List<Color> getSuggestedShoes(
    List<Color> selectedPants,
    List<Color> selectedShirts,
  ) {
    final combinations = <Map<String, dynamic>>[];

    if (selectedPants.isNotEmpty) {
      final pantsValues = selectedPants.map((c) => c.value).toList();
      combinations.addAll(
        formalCombinations.where(
          (c) => pantsValues.contains((c['pants'] as Color).value),
        ),
      );
    }

    if (selectedShirts.isNotEmpty) {
      final shirtValues = selectedShirts.map((c) => c.value).toList();
      combinations.addAll(
        formalCombinations.where(
          (c) => shirtValues.contains((c['shirt'] as Color).value),
        ),
      );
    }

    return combinations.map((c) => c['shoes'] as Color).toSet().toList();
  }

  // Get complete matching combinations
  static List<Map<String, dynamic>> getFilteredCombinations(
    List<List<Color>> allColors,
  ) {
    final pantsValues = allColors[0].map((c) => c.value).toList();
    final shirtValues = allColors[1].map((c) => c.value).toList();
    final shoeValues = allColors[2].map((c) => c.value).toList();

    print('Matching combinations for:');
    print('Pants: ${pantsValues.map((v) => v.toRadixString(16))}');
    print('Shirts: ${shirtValues.map((v) => v.toRadixString(16))}');
    print('Shoes: ${shoeValues.map((v) => v.toRadixString(16))}');

    return formalCombinations.where((comb) {
      final combPants = (comb['pants'] as Color).value;
      final combShirt = (comb['shirt'] as Color).value;
      final combShoes = (comb['shoes'] as Color).value;

      final match =
          pantsValues.contains(combPants) &&
          shirtValues.contains(combShirt) &&
          shoeValues.contains(combShoes);

      if (match) print('Match found: ${comb['description']}');

      return match;
    }).toList();
  }
}
