import 'package:flutter/material.dart';
import 'package:animated_custom_appbar/animated_custom_appbar.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ExamplePage(),
    );
  }
}

class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedCustomAppBar(
      maxHeight: 180,
      minHeight: 76,
      fadingBackgroundShadow: [],
      centerWidget: const Text("Hello Appbar!", style: TextStyle(fontSize: 18)),
      slivers: [
        SliverList.builder(
          itemCount: 20,
          itemBuilder: (_, i) => ListTile(title: Text("Item $i")),
        ),
      ],
    );
  }
}
