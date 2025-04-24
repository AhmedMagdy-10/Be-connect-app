import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:page_transition/page_transition.dart';
import 'package:qoute_app/screens/chosse/clothing.dart';

class DressingType extends StatefulWidget {
  const DressingType({super.key});

  @override
  _DressingTypeState createState() => _DressingTypeState();
}

class _DressingTypeState extends State<DressingType> {
  final scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "How do you want to dress up?",

            style: TextStyle(color: Color(0xff000000)),
          ),
          bottom: TabBar(
            labelStyle: TextStyle(fontSize: 22),
            tabs: [Tab(text: 'Formal'), Tab(text: 'Casual')],
          ),
        ),
        body: TabBarView(children: [FormalView(), CasualView()]),
      ),
    );
  }
}

class CasualView extends StatelessWidget {
  const CasualView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
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
                  child: Image.asset("assets/shirt1.png", fit: BoxFit.contain),
                ),
              ),

              Text(
                "Casual",
                style: TextStyle(color: Colors.black, fontSize: 26.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FormalView extends StatelessWidget {
  const FormalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
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
                  child: Image.asset("assets/shirt2.png", fit: BoxFit.contain),
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
    );
  }
}

//  StreamBuilder<List<Map<String, dynamic>>>(
//                             stream: supabase
//                                 .from('clothes')
//                                 .stream(primaryKey: ['id'])
//                                 .order('created_at'),
//                             builder: (context, snapshot) {
//                               if (!snapshot.hasData) {
//                                 return Center(child: CircularProgressIndicator());
//                               }

//                               final items =
//                                   snapshot.data!
//                                       .map(
//                                         (doc) => ClothingItem(
//                                           id: doc['id'].toString(),
//                                           imageUrl: doc['image_url'],
//                                           type: doc['type'],
//                                           colors: doc['colors'],
//                                           timestamp: DateTime.parse(
//                                             doc['created_at'],
//                                           ),
//                                         ),
//                                       )
//                                       .toList();

//                               final outfits = generateOutfits(items);

//                               if (outfits.isEmpty) {
//                                 return Center(
//                                   child: Text('No outfit suggestions available'),
//                                 );
//                               }

//                               return ListView.separated(
//                                 padding: const EdgeInsets.all(16),
//                                 itemCount: outfits.length,
//                                 separatorBuilder:
//                                     (_, __) => const SizedBox(height: 16),
//                                 itemBuilder: (context, index) {
//                                   final outfit = outfits[index];
//                                   return Card(
//                                     elevation: 4,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(16),
//                                     ),
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(16),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           const Text(
//                                             'Outfit Suggestion',
//                                             style: TextStyle(
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                           const SizedBox(height: 8),
//                                           Text(
//                                             'Compatibility: ${(outfit.compatibilityScore * 100).toStringAsFixed(1)}%',
//                                             style: TextStyle(
//                                               color: Colors.grey[600],
//                                             ),
//                                           ),
//                                           const SizedBox(height: 16),
//                                           Row(
//                                             children: [
//                                               _OutfitItem(
//                                                 imageUrl:
//                                                     outfit.tops.first.imageUrl,
//                                               ),
//                                               const SizedBox(width: 16),
//                                               _OutfitItem(
//                                                 imageUrl:
//                                                     outfit.bottoms.first.imageUrl,
//                                               ),
//                                               if (outfit
//                                                   .outerwear
//                                                   .isNotEmpty) ...[
//                                                 const SizedBox(width: 16),
//                                                 _OutfitItem(
//                                                   imageUrl:
//                                                       outfit
//                                                           .outerwear
//                                                           .first
//                                                           .imageUrl,
//                                                 ),
//                                               ],
//                                             ],
//                                           ),
//                                           const SizedBox(height: 16),
//                                           ElevatedButton(
//                                             onPressed: () {},
//                                             child: const Text('Save Outfit'),
//                                             style: ElevatedButton.styleFrom(
//                                               minimumSize: const Size(
//                                                 double.infinity,
//                                                 40,
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     )
//                                   );
//                                 }
//                               );

//                             }
//   )
