import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:family_tree_firebase/core/constants/app_constants.dart';
import 'package:family_tree_firebase/features/family/presentation/bloc/family_bloc.dart';
import 'package:family_tree_firebase/features/family/presentation/bloc/family_event.dart';
import 'package:family_tree_firebase/features/family/presentation/bloc/family_state.dart';
import 'package:family_tree_firebase/features/home/presentation/screens/home_screen.dart';

class JoinFamilyScreen extends StatefulWidget {
  const JoinFamilyScreen({super.key});

  @override
  State<JoinFamilyScreen> createState() => _JoinFamilyScreenState();
}

class _JoinFamilyScreenState extends State<JoinFamilyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _inviteCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Reset any previous state when the screen is first loaded
    context.read<FamilyBloc>().add(const ResetFamilyStateEvent());
  }

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  bool _isLoading = false;

  void _joinFamily() {
    if (!_formKey.currentState!.validate()) return;
    
    // Dismiss keyboard
    FocusScope.of(context).unfocus();
    
    // Dispatch the JoinFamilyEvent
    context.read<FamilyBloc>().add(
          JoinFamilyEvent(_inviteCodeController.text.trim()),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FamilyBloc, FamilyState>(
      listener: (context, state) {
        if (state is FamilyError) {
          _showErrorSnackBar(state.message);
          setState(() => _isLoading = false);
        } else if (state is FamilyLoadSuccess) {
          // Navigate to home screen on successful join
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else if (state is FamilyLoading) {
          setState(() => _isLoading = true);
        } else {
          setState(() => _isLoading = false);
        }
      },
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: const Text('Join Family'),
          leading: _isLoading
              ? const SizedBox.shrink()
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
        ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                const SizedBox(height: 40),
                
                // Illustration
                Icon(
                  Icons.group_add,
                  size: 120,
                  color: Theme.of(context).primaryColor.withOpacity(0.8),
                ),
                
                const SizedBox(height: 32),
                
                // Title
                const Text(
                  'Join a Family Group',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // Description
                Text(
                  'Enter the invite code provided by your family member to join their family group.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                // Invite code field
                TextFormField(
                  controller: _inviteCodeController,
                  decoration: InputDecoration(
                    labelText: 'Invite Code',
                    hintText: 'e.g., ABC123',
                    prefixIcon: const Icon(Icons.vpn_key_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                    ),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an invite code';
                    }
                    if (value.length < 6) {
                      return 'Invite code must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
                    // Join button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _joinFamily,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Join Family',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                
                    const SizedBox(height: 20),
                    
                    // Don't have a code? Create a family instead
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.pushReplacementNamed(
                                context,
                                AppConstants.createFamilyRoute,
                              );
                            },
                      child: const Text('Create a new family instead'),
                    ),
                  ],
                ),
              ),
            ),
            
            // Loading overlay
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }
}
