import 'package:flutter/material.dart';

import '../data/users.dart';

class Stories extends StatelessWidget {
  const Stories({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        StoryBackGround(
          bottomText: "Tin của bạn",
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.deepOrange.shade400,
              image: const DecorationImage(
                image: AssetImage('assets/sontung.png'),
                fit: BoxFit.cover,
                opacity: .75,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.add_box_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
        ...stories
            .map((story) => StoryBackGround(
                bottomText: story.userName,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    story.assetName,
                    fit: BoxFit.cover,
                  ),
                ),
              ))
            .toList(),
      ],
    );
  }
}

class StoryBackGround extends StatelessWidget {
  const StoryBackGround({
    super.key,
    required this.child,
    required this.bottomText,
  });

  final Widget child;
  final String bottomText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(2),
            margin: const EdgeInsets.all(6),
            width: 80,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.deepOrange.shade300,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: child,
          ),
        ),
        Text(
          bottomText,
          style: const TextStyle(
            fontSize: 10,
          ),
        )
      ],
    );
  }
}
