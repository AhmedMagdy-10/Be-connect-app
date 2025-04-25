import 'package:flutter/material.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorite Outfits')),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return;
        },
      ),
    );
  }
}
