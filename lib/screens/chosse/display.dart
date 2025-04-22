import 'package:flutter/material.dart';
import 'package:qoute_app/screens/chosse/data/formal_combination.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flip_card/flip_card.dart';

class DisplayPage extends StatefulWidget {
  const DisplayPage(this.allColors, this.isFormal);
  final List<List<Color>> allColors;
  final bool isFormal;
  @override
  _DisplayPageState createState() => _DisplayPageState(allColors);
}

class _DisplayPageState extends State<DisplayPage> {
  _DisplayPageState(this.allColors);
  List<List<Color>> allColors;
  var listForCarousel =
      Iterable<int>.generate(formalCombinations.length).toList();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CarouselSlider(
          options: CarouselOptions(
            height: MediaQuery.of(context).size.height * 0.8,
          ),
          items:
              listForCarousel.map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return FlipCard(
                      direction: FlipDirection.HORIZONTAL, // default
                      front: Container(
                        child: Card(
                          elevation: 15.0,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(color: Colors.white),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 30.0),
                                child: ListView(
                                  physics: BouncingScrollPhysics(),
                                  children: <Widget>[
                                    ShaderMask(
                                      child:
                                          widget.isFormal
                                              ? Image(
                                                image: AssetImage(
                                                  "assets/shirt2.png",
                                                ),
                                                width: 150.0,
                                                height: 150.0,
                                              )
                                              : Image(
                                                image: AssetImage(
                                                  "assets/shirt1.png",
                                                ),
                                                width: 150.0,
                                                height: 150.0,
                                              ),
                                      blendMode: BlendMode.srcATop,
                                      shaderCallback: (Rect bounds) {
                                        return LinearGradient(
                                          colors: [
                                            formalCombinations[i]['shirt'],
                                            formalCombinations[i]['shirt'],
                                          ],
                                          stops: [0.0, 0.5],
                                        ).createShader(bounds);
                                      },
                                    ),
                                    if (widget.isFormal != false)
                                      ShaderMask(
                                        child: Image(
                                          image: AssetImage("assets/belt.png"),
                                          width: 60.0,
                                          height: 60.0,
                                        ),
                                        blendMode: BlendMode.srcATop,
                                        shaderCallback: (Rect bounds) {
                                          return LinearGradient(
                                            colors: [
                                              formalCombinations[i]['belt'],
                                              formalCombinations[i]['belt'],
                                            ],
                                            stops: [0.0, 0.5],
                                          ).createShader(bounds);
                                        },
                                      ),

                                    ShaderMask(
                                      child:
                                          widget.isFormal
                                              ? Image(
                                                image: AssetImage(
                                                  "assets/pant1.png",
                                                ),
                                                width: 190.0,
                                                height: 190.0,
                                              )
                                              : Image(
                                                image: AssetImage(
                                                  "assets/images__3_-removebg-preview.png",
                                                ),
                                                width: 190.0,
                                                height: 190.0,
                                              ),
                                      blendMode: BlendMode.srcATop,
                                      shaderCallback: (Rect bounds) {
                                        return LinearGradient(
                                          colors: [
                                            formalCombinations[i]['pants'],
                                            formalCombinations[i]['pants'],
                                          ],
                                          stops: [0.0, 0.5],
                                        ).createShader(bounds);
                                      },
                                    ),

                                    ShaderMask(
                                      child:
                                          widget.isFormal
                                              ? Image(
                                                image: AssetImage(
                                                  "assets/shoes (1).png",
                                                ),
                                                width: 60.0,
                                                height: 60.0,
                                              )
                                              : Image(
                                                image: AssetImage(
                                                  "assets/amazon__1_-removebg-preview.png",
                                                ),
                                                width: 60.0,
                                                height: 60.0,
                                              ),
                                      blendMode: BlendMode.srcATop,
                                      shaderCallback: (Rect bounds) {
                                        return LinearGradient(
                                          colors: [
                                            formalCombinations[i]['shoes'],
                                            formalCombinations[i]['shoes'],
                                          ],
                                          stops: [0.0, 0.5],
                                        ).createShader(bounds);
                                      },
                                    ),

                                    Text(
                                      "\nTap to View more info",
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      back: Container(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 40.0,
                              horizontal: 20.0,
                            ),
                            child: Text(
                              formalCombinations[i]['description'],
                              style: TextStyle(fontFamily: "Marker"),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
        ),
      ),
    );
  }
}
