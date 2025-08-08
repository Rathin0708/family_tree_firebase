import 'package:flutter/material.dart';
import 'package:family_tree_firebase/features/family/presentation/widgets/family_tree_widget.dart';

class FamilyHomeScreen extends StatelessWidget {
  const FamilyHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family'),
      ),
      body: const FamilyTreeWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add family member screen
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
