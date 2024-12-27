import 'package:flutter/material.dart';

import '../../../utils/back_ground.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/post_card.dart';
import '../widgets/stories_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BackGround(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          toolbarHeight: 0,
          scrolledUnderElevation: 0,
        ),
        body: CustomScrollView(
          slivers: [
            const CustomAppBar(),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    const Text("Tin"),
                    const SizedBox(
                      height: 110,
                      child: Stories(),
                    ),
                    const SizedBox(height: 20),
                    const Text("Bài viết gần đây"),
                    Post(),
                ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
