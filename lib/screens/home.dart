import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final void Function() onInit;
  const HomeScreen(this.onInit, {Key? key}) : super(key: key);
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    widget.onInit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scarborough'),
      ),
      body: const Center(
        child: Text('home'),
      ),
    );
  }
}
