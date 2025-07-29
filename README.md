# Animated Custom AppBar

A customizable and animated AppBar for Flutter apps. Perfect for dynamic scroll-based UIs with
smooth transitions.

## ANIMATED CUSTOM APPBAR

<p  align="center">
<img  src="https://raw.githubusercontent.com/asseries/animated_custom_appbar/main/doc/demo.gif?raw=true"  width="350"/>
<br>
</p>

## Features

- Scroll-aware animation
- Flexible center widget
- Optional left and right icons
- Custom fading background and radius
- Beautiful transitions
- Supports pull-to-refresh via the `onRefresh` callback.


## Getting Started

## Use
```dart
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

  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _onRefresh() async {
      
  }
}


@override
Widget build(BuildContext context) {
  return Scaffold(
      key: scaffoldKey,
      drawer: const Drawer(),
      body: AnimatedCustomAppBar(
        maxHeight: 180,
        minHeight: 76,
        onRefresh: () => _onRefresh(),
        fadingBackgroundShadow: [],
        centerWidget: const Text("Hello Appbar!", style: TextStyle(fontSize: 18)),
        leftWidgetPressed: () => scaffoldKey.currentState?.openDrawer(),
        children: [
          ListView.builder(
            itemCount: 20,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (_, i) => ListTile(title: Text("Item $i")),
          ),
        ],
      )
  );
}


```


```yaml
dependencies:
  animated_custom_appbar: ^1.0.2
# animated_custom_appbar
```



