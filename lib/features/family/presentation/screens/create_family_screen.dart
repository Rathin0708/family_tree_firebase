import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:family_tree_firebase/core/constants/app_constants.dart';
import 'package:family_tree_firebase/features/family/presentation/bloc/family_bloc.dart';
import 'package:family_tree_firebase/features/family/presentation/bloc/family_event.dart';
import 'package:family_tree_firebase/features/family/presentation/bloc/family_state.dart';
import 'package:family_tree_firebase/features/home/presentation/screens/home_screen.dart';

class CreateFamilyScreen extends StatefulWidget {
  const CreateFamilyScreen({super.key});

  @override
  State<CreateFamilyScreen> createState() => _CreateFamilyScreenState();
}

class _CreateFamilyScreenState extends State<CreateFamilyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _familyNameController = TextEditingController();
  bool _isLoading = false;
  String? _generatedCode;

  @override
  void initState() {
    super.initState();
    // Reset any previous state when the screen is first loaded
    context.read<FamilyBloc>().add(const ResetFamilyStateEvent());
  }

  @override
  void dispose() {
    _familyNameController.dispose();
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

  void _createFamily() {
    if (!_formKey.currentState!.validate()) return;
    
    // Dismiss keyboard
    FocusScope.of(context).unfocus();
    
    // Dispatch the CreateFamilyEvent
    context.read<FamilyBloc>().add(
          CreateFamilyEvent(_familyNameController.text.trim()),
        );
  }

  void _copyToClipboard() {
    if (_generatedCode == null) return;
    
    // TODO: Implement copy to clipboard
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invite code copied to clipboard'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _continueToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FamilyBloc, FamilyState>(
      listener: (context, state) {
        if (state is FamilyError) {
          _showErrorSnackBar(state.message);
          setState(() => _isLoading = false);
        } else if (state is FamilyLoadSuccess && state.isNewlyCreated) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Family created successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
          
          // Set the generated code
          if (state.family.currentInviteCode != null) {
            setState(() {
              _generatedCode = state.family.currentInviteCode;
              _isLoading = false;
            });
          }
        } else if (state is FamilyLoading) {
          setState(() => _isLoading = true);
        } else {
          setState(() => _isLoading = false);
        }
      },
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: const Text('Create Family'),
          leading: _isLoading
              ? const SizedBox.shrink()
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _generatedCode == null 
                      ? () => Navigator.pop(context)
                      : null,
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
                  Icons.family_restroom,
                  size: 120,
                  color: Theme.of(context).primaryColor.withOpacity(0.8),
                ),
                
                const SizedBox(height: 32),
                
                // Title
                Text(
                  _generatedCode == null 
                      ? 'Create a New Family'
                      : 'Family Created!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                if (_generatedCode == null) ...[
                  // Family name input
                  TextFormField(
                    controller: _familyNameController,
                    decoration: InputDecoration(
                      labelText: 'Family Name',
                      hintText: 'e.g., The Smiths',
                      prefixIcon: const Icon(Icons.house_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a family name';
                      }
                      if (value.length < 3) {
                        return 'Name must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Create button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _createFamily,
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
                            'Create Family',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ] else ...[
                  // Success message
                  Text(
                    'Share this invite code with your family members to connect with them:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Invite code card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          const Text(
                            'Your Invite Code',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _generatedCode!,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Expires in 7 days',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Copy button
                  OutlinedButton.icon(
                    onPressed: _copyToClipboard,
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Invite Code'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Share button
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement share functionality
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share Invite'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Continue button
                  TextButton(
                    onPressed: _continueToHome,
                    child: const Text('Continue to Home'),
                  ),
                ],
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
    );
  }
}
