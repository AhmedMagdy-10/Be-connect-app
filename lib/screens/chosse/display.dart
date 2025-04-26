import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flip_card/flip_card.dart';
import 'package:qoute_app/screens/chosse/data/formal_combination.dart';

class DisplayPage extends StatefulWidget {
  const DisplayPage(this.allColors, this.isFormal, {super.key});
  final List<List<Color>> allColors;
  final bool isFormal;

  @override
  _DisplayPageState createState() => _DisplayPageState(allColors);
}

class _DisplayPageState extends State<DisplayPage> {
  _DisplayPageState(this.allColors);
  List<List<Color>> allColors;
  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isFormal ? 'Formal Combinations' : 'Casual Outfits',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,

        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          Expanded(
            child: CarouselSlider(
              carouselController: _controller,
              options: CarouselOptions(
                height: MediaQuery.of(context).size.height * 0.8,
                viewportFraction: 0.8,
                enlargeCenterPage: true,
                enableInfiniteScroll: false,
                onPageChanged: (index, reason) {
                  setState(() => _current = index);
                },
              ),
              items:
                  formalCombinations.asMap().entries.map((entry) {
                    final i = entry.key;
                    final combination = entry.value;

                    return Builder(
                      builder: (BuildContext context) {
                        return FlipCard(
                          flipOnTouch: true,
                          direction: FlipDirection.HORIZONTAL,
                          front: _buildFrontCard(combination, context),
                          back: _buildBackCard(combination, context),
                        );
                      },
                    );
                  }).toList(),
            ),
          ),
          _buildIndicator(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFrontCard(
    Map<String, dynamic> combination,
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[100]!, Colors.grey[200]!],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Outfit ${_current + 1}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildClothingItem(
                    context,
                    widget.isFormal ? "assets/shirt2.png" : "assets/shirt1.png",
                    combination['shirt'],
                    "Shirt",
                    size: 120,
                  ),
                  if (widget.isFormal)
                    _buildClothingItem(
                      context,
                      "assets/belt.png",
                      combination['belt'],
                      "Belt",
                      size: 80,
                    ),
                  _buildClothingItem(
                    context,
                    widget.isFormal
                        ? "assets/pant1.png"
                        : "assets/images__3_-removebg-preview.png",
                    combination['pants'],
                    "Pants",
                    size: 150,
                  ),
                  _buildClothingItem(
                    context,
                    widget.isFormal
                        ? "assets/shoes (1).png"
                        : "assets/amazon__1_-removebg-preview.png",
                    combination['shoes'],
                    "Shoes",
                    size: 80,
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Tap to view details',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClothingItem(
    BuildContext context,
    String asset,
    Color color,
    String label, {
    double size = 100,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                colors: [color, color],
                stops: const [0.0, 0.5],
              ).createShader(bounds);
            },
            child: Image.asset(asset, width: size, height: size),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildBackCard(
    Map<String, dynamic> combination,
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blueGrey[50]!, Colors.blueGrey[100]!],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Style Tips',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  combination['description'],
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              children: [
                _buildColorChip(combination['shirt'], 'Shirt'),
                if (widget.isFormal)
                  _buildColorChip(combination['belt'], 'Belt'),
                _buildColorChip(combination['pants'], 'Pants'),
                _buildColorChip(combination['shoes'], 'Shoes'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorChip(Color color, String label) {
    return Chip(
      backgroundColor: color.withOpacity(0.2),
      label: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
      avatar: CircleAvatar(backgroundColor: color, radius: 10),
    );
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          formalCombinations.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _controller.animateToPage(entry.key),
              child: Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      _current == entry.key
                          ? Colors.blueGrey
                          : Colors.grey[300],
                ),
              ),
            );
          }).toList(),
    );
  }
}
