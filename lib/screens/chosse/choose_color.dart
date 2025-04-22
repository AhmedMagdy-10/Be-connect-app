import 'package:flutter/material.dart';

import 'package:page_transition/page_transition.dart';
import 'package:qoute_app/screens/chosse/clothing.dart';

class DressingType extends StatefulWidget {
  @override
  _DressingTypeState createState() => _DressingTypeState();
}

class _DressingTypeState extends State<DressingType> {
  final scrollController = new ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        controller: scrollController,
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "How do you want to dress up?",
              style: TextStyle(
                color: Color(0xff000000),
                fontSize: MediaQuery.of(context).size.height * 0.04,
              ),
            ),
          ),
          Container(
            margin: EdgeInsetsDirectional.symmetric(horizontal: 16),
            color: Colors.grey,
            width: double.infinity,
            height: 2,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap:
                  () => Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      child: DressUpPage(isFormal: true),
                    ),
                  ),
              child: Stack(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      child: Image.asset(
                        "assets/shirt2.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Formal",
                      style: TextStyle(color: Colors.black, fontSize: 26.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsetsDirectional.symmetric(horizontal: 16),
            color: Colors.grey,
            width: double.infinity,
            height: 2,
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap:
                  () => Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      child: DressUpPage(isFormal: false),
                    ),
                  ),
              child: Stack(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      child: Image.asset(
                        "assets/shirt1.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      "Casual",
                      style: TextStyle(color: Colors.black, fontSize: 26.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
