import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: Container(
              color: Colors.blue,
              child: const Center(child: Text('Top Area')),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width:228,
                  child: Container(
                    color: Colors.green,
                    child: const Center(child: Text('Left Content')),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.yellow,
                    child: const Center(child: Text('Right Content')),
                  ),
                ),
                SizedBox(
                  width: 228,
                  child: Container(
                    color: Colors.redAccent,
                    child: const Center(child: Text('Right Content')),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: Container(
              color: Colors.red,
              child: const Center(child: Text('Bottom Area')),
            ),
          ),
        ],
      ),
    );
  }
}
