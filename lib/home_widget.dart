import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class HomeWidget extends StatelessWidget {
  const HomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Title')),
      body: Expanded(
        child: ListView.builder(
          itemCount: 5,
          itemBuilder:
              (context, index) => AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: SizedBox(
                      height: 300,
                      child: ListView.builder(
                        itemCount: 10,
                        itemBuilder:
                            (context, index) =>
                                AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 375),
                                  child: SlideAnimation(
                                    verticalOffset: 50.0,
                                    child: FadeInAnimation(child: carddd()),
                                  ),
                                ),
                      ),
                    ),
                  ),
                ),
              ),
        ),
      ),
    );
  }
}

class carddd extends StatelessWidget {
  const carddd({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"Be the change you wish to see in the world"',
              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage('assets/coffee-cup.png'),
                ),
                SizedBox(width: 8),
                Text("- Mahatma Gandhi"),
                Spacer(),
                IconButton(icon: Icon(Icons.share), onPressed: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
