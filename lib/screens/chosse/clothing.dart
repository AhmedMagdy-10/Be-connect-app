import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import './display.dart';

List<List<Color>> allColors = [[], [], []];

class DressingType extends StatelessWidget {
  const DressingType({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[100]!, Colors.white],
          ),
        ),
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "How would you like to dress?",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TabBar(
                  labelStyle: TextStyle(fontSize: 20, color: Colors.black),
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [Colors.blue[800]!, Colors.blue[400]!],
                    ),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[600],

                  tabs: const [Tab(text: 'Formal'), Tab(text: 'Casual')],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildStyleCard(context, true),
                    _buildStyleCard(context, false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyleCard(BuildContext context, bool isFormal) {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              child: DressUpPage(isFormal: isFormal),
            ),
          ),
      child: Container(
        margin: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 15, spreadRadius: 5),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                isFormal ? "assets/shirt2.png" : "assets/shirt1.png",
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isFormal ? "FORMAL" : "CASUAL",
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Text(
                      "Get Started",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DressUpPage extends StatefulWidget {
  final bool isFormal;

  const DressUpPage({super.key, required this.isFormal});

  @override
  _DressUpPageState createState() => _DressUpPageState();
}

class _DressUpPageState extends State<DressUpPage> {
  List<Map<String, dynamic>> items = [
    {'color': 'Black', 'check': false, 'colorcode': Color(0xff000000)},
    {'color': 'Grey', 'check': false, 'colorcode': Color(0xff71757a)},
    {'color': 'Navy Blue', 'check': false, 'colorcode': Color(0xff010b35)},
    {'color': 'Dark Brown', 'check': false, 'colorcode': Color(0xff40321e)},
    {'color': 'Brown', 'check': false, 'colorcode': Color(0xff988A75)},
    {'color': 'Blue', 'check': false, 'colorcode': Color(0xff2A3C8A)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[800]),
        title: Text(
          widget.isFormal ? "Formal Style Setup" : "Casual Style Setup",
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            child: Text(
              "What color ${widget.isFormal ? 'pants' : 'items'} do you have?",
              style: TextStyle(
                fontSize: 22,
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _buildColorItem(index),
            ),
          ),
          _buildContinueButton(context),
        ],
      ),
    );
  }

  Widget _buildColorItem(int index) {
    return Material(
      borderRadius: BorderRadius.circular(15),
      elevation: items[index]['check'] ? 3 : 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient:
              items[index]['check']
                  ? LinearGradient(
                    colors: [Colors.blue[100]!, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                  : null,
          border: Border.all(
            color:
                items[index]['check'] ? Colors.blue[300]! : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: items[index]['colorcode'],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
          ),
          title: Text(
            items[index]['color'],
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          trailing: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color:
                  items[index]['check'] ? Colors.blue[400]! : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child:
                items[index]['check']
                    ? Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
          ),
          onTap: () => _toggleSelection(index),
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        elevation: 5,
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.blue[600]!, Colors.blue[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap:
                () => Navigator.push(
                  context,
                  PageTransition(
                    child: DressUpPage2(isFormal: widget.isFormal),
                    type: PageTransitionType.rightToLeft,
                  ),
                ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 10),
                Icon(Icons.arrow_forward_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleSelection(int index) {
    setState(() {
      items[index]['check'] = !items[index]['check'];
      if (items[index]['check']) {
        allColors[0].add(items[index]['colorcode']);
      } else {
        allColors[0].remove(items[index]['colorcode']);
      }
    });
  }
}

class DressUpPage2 extends StatefulWidget {
  final bool isFormal;

  const DressUpPage2({super.key, required this.isFormal});

  @override
  _DressUpPage2State createState() => _DressUpPage2State();
}

class _DressUpPage2State extends State<DressUpPage2> {
  List<Map<String, dynamic>> items = [
    {'color': 'Black', 'check': false, 'colorcode': Color(0xff000000)},
    {'color': 'Grey', 'check': false, 'colorcode': Color(0xff71757a)},
    {'color': 'Navy Blue', 'check': false, 'colorcode': Color(0xff010b35)},
    {'color': 'Dark Brown', 'check': false, 'colorcode': Color(0xff40321e)},
    {'color': 'Brown', 'check': false, 'colorcode': Color(0xff988A75)},
    {'color': 'Blue', 'check': false, 'colorcode': Color(0xff2A3C8A)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[800]),
        title: Text(
          widget.isFormal ? "Formal Shirts" : "Casual Tops",
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            child: Text(
              "Select your ${widget.isFormal ? 'formal shirts' : 'casual tops'}",
              style: TextStyle(
                fontSize: 22,
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _buildColorItem(index),
            ),
          ),
          _buildContinueButton(context),
        ],
      ),
    );
  }

  Widget _buildColorItem(int index) {
    return Material(
      borderRadius: BorderRadius.circular(15),
      elevation: items[index]['check'] ? 3 : 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient:
              items[index]['check']
                  ? LinearGradient(
                    colors: [Colors.blue[100]!, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                  : null,
          border: Border.all(
            color:
                items[index]['check'] ? Colors.blue[300]! : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: items[index]['colorcode'],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
          ),
          title: Text(
            items[index]['color'],
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          trailing: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color:
                  items[index]['check'] ? Colors.blue[400]! : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child:
                items[index]['check']
                    ? Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
          ),
          onTap: () => _toggleSelection(index),
        ),
      ),
    );
  }

  void _toggleSelection(int index) {
    setState(() {
      items[index]['check'] = !items[index]['check'];
      if (items[index]['check']) {
        allColors[0].add(items[index]['colorcode']);
      } else {
        allColors[0].remove(items[index]['colorcode']);
      }
    });
  }

  Widget _buildContinueButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        elevation: 5,
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.blue[600]!, Colors.blue[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap:
                () => Navigator.push(
                  context,
                  PageTransition(
                    child: DressUpPage3(isFormal: widget.isFormal),
                    type: PageTransitionType.rightToLeft,
                  ),
                ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 10),
                Icon(Icons.arrow_forward_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DressUpPage3 extends StatefulWidget {
  final bool isFormal;

  const DressUpPage3({super.key, required this.isFormal});

  @override
  _DressUpPage3State createState() => _DressUpPage3State();
}

class _DressUpPage3State extends State<DressUpPage3> {
  List<Map<String, dynamic>> items = [
    {'color': 'Black', 'check': false, 'colorcode': Color(0xff000000)},
    {'color': 'Grey', 'check': false, 'colorcode': Color(0xff71757a)},
    {'color': 'Navy Blue', 'check': false, 'colorcode': Color(0xff010b35)},
    {'color': 'Dark Brown', 'check': false, 'colorcode': Color(0xff40321e)},
    {'color': 'Brown', 'check': false, 'colorcode': Color(0xff988A75)},
    {'color': 'Blue', 'check': false, 'colorcode': Color(0xff2A3C8A)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[800]),
        title: Text(
          widget.isFormal ? "Formal Shoes" : "Casual Footwear",
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            child: Text(
              "Select your ${widget.isFormal ? 'formal shoes' : 'casual footwear'}",
              style: TextStyle(
                fontSize: 22,
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _buildColorItem(index),
            ),
          ),
          _buildFinalButton(context),
        ],
      ),
    );
  }

  Widget _buildFinalButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        elevation: 5,
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.green[600]!, Colors.green[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DisplayPage(allColors, widget.isFormal),
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'View Outfits',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 10),
                Icon(Icons.arrow_forward_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorItem(int index) {
    return Material(
      borderRadius: BorderRadius.circular(15),
      elevation: items[index]['check'] ? 3 : 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient:
              items[index]['check']
                  ? LinearGradient(
                    colors: [Colors.blue[100]!, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                  : null,
          border: Border.all(
            color:
                items[index]['check'] ? Colors.blue[300]! : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: items[index]['colorcode'],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
          ),
          title: Text(
            items[index]['color'],
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          trailing: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color:
                  items[index]['check'] ? Colors.blue[400]! : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child:
                items[index]['check']
                    ? Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
          ),
          onTap: () => _toggleSelection(index),
        ),
      ),
    );
  }

  void _toggleSelection(int index) {
    setState(() {
      items[index]['check'] = !items[index]['check'];
      if (items[index]['check']) {
        allColors[0].add(items[index]['colorcode']);
      } else {
        allColors[0].remove(items[index]['colorcode']);
      }
    });
  }
}
