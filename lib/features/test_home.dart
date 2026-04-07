import 'package:flutter/material.dart';

class TestHome extends StatefulWidget {
  const TestHome({super.key});

  @override
  State<TestHome> createState() => _TestHomeState();
}

class _TestHomeState extends State<TestHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: Center(
         child: IconButton(onPressed: (){
          Navigator.pushNamed(context, '/test');
         }, icon: const Icon(Icons.bug_report))
       ),
    );
  }
}
