import 'package:flutter/material.dart';

class FamilyTreeWidget extends StatelessWidget {
  const FamilyTreeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Family Tree',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // TODO: Implement actual family tree visualization
          // This is a placeholder for the family tree
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              children: [
                // Current User
                CircleAvatar(
                  radius: 30,
                  child: Icon(Icons.person, size: 30),
                ),
                SizedBox(height: 10),
                Text('You'),
                SizedBox(height: 30),
                // Parents
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          child: Icon(Icons.person, size: 25),
                        ),
                        Text('Parent 1'),
                      ],
                    ),
                    SizedBox(width: 20),
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          child: Icon(Icons.person, size: 25),
                        ),
                        Text('Parent 2'),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 30),
                // Siblings
                Text('Siblings', style: TextStyle(fontStyle: FontStyle.italic)),
                // TODO: Add siblings list
              ],
            ),
          ),
        ],
      ),
    );
  }
}
