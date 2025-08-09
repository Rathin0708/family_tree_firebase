// lib/features/family/presentation/screens/family_tree_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'join_family_screen.dart';

class FamilyTreeScreen extends StatefulWidget {
  const FamilyTreeScreen({Key? key}) : super(key: key);

  @override
  _FamilyTreeScreenState createState() => _FamilyTreeScreenState();
}

class _FamilyTreeScreenState extends State<FamilyTreeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Family Tree',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          tabs: const [
            Tab(text: 'My Tree'),
            Tab(text: 'Family Tree'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          // My Tree Tab
          Center(child: Text('My Family Tree View')),
          // Family Tree Tab
          Center(child: Text('Extended Family Tree View')),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _showAddMemberOptions,
      backgroundColor: const Color(0xFF6A11CB),
      child: const Icon(Icons.group_add, color: Colors.white),
    );
  }

  void _showAddMemberOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person_add, color: Color(0xFF6A11CB)),
                title: const Text('Add Family Member'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddMemberDialog();
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.person_remove, color: Colors.red),
                title: const Text('Remove Family Member'),
                onTap: () {
                  Navigator.pop(context);
                  _showRemoveMemberDialog();
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.group_add, color: Color(0xFFFF6B35)),
                title: const Text('Join a Family'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToJoinFamilyScreen();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _navigateToJoinFamilyScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const JoinFamilyScreen(),
      ),
    );
  }

  void _showAddMemberDialog() {
    final _formKey = GlobalKey<FormState>();
    final _userIdController = TextEditingController();
    String? _selectedRelation;

    final relations = [
      'Spouse',
      'Parent',
      'Child',
      'Sibling',
      'Grandparent',
      'Grandchild',
      'Aunt/Uncle',
      'Cousin',
      'Other'
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Family Member'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _userIdController,
                    decoration: const InputDecoration(
                      labelText: 'User ID or Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter user ID or email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Relationship',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedRelation,
                    items: relations.map((relation) {
                      return DropdownMenuItem(
                        value: relation,
                        child: Text(relation),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRelation = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a relationship';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // TODO: Implement add family member logic
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Family member added successfully!'),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A11CB),
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showRemoveMemberDialog() {
    // TODO: Implement remove member dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Family Member'),
          content: const Text('Select a family member to remove:'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            // TODO: Add list of family members to remove
          ],
        );
      },
    );
  }
}