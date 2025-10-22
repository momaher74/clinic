import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LayoutScrren extends StatelessWidget {
  const LayoutScrren({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Layout Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('This is the Layout Screen'),
          ],
        ),
      ),
      );
  }
}