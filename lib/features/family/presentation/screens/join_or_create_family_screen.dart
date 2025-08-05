import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:family_tree_firebase/core/constants/app_constants.dart';
import 'package:family_tree_firebase/features/family/presentation/bloc/family_bloc.dart';
import 'package:family_tree_firebase/features/family/presentation/bloc/family_event.dart';
import 'package:family_tree_firebase/features/family/presentation/bloc/family_state.dart';

class JoinOrCreateFamilyScreen extends StatefulWidget {
  const JoinOrCreateFamilyScreen({super.key});

  @override
  State<JoinOrCreateFamilyScreen> createState() => _JoinOrCreateFamilyScreenState();
}

class _JoinOrCreateFamilyScreenState extends State<JoinOrCreateFamilyScreen> {
  bool _isLoading = false;

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

  @override
  void initState() {
    super.initState();
    // Reset any previous state when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FamilyBloc>().add(const ResetFamilyStateEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FamilyBloc, FamilyState>(
      listener: (context, state) {
        if (state is FamilyError) {
          _showErrorSnackBar(state.message);
          setState(() => _isLoading = false);
        } else if (state is FamilyLoading) {
          setState(() => _isLoading = true);
        } else {
          setState(() => _isLoading = false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Family Setup'),
          centerTitle: true,
          automaticallyImplyLeading: !_isLoading,
        ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Welcome text
                  const Text(
                    'Welcome to Family Connect!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  const Text(
                    'Get started by joining an existing family or creating a new one',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 48),
            
                  // Join Family Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16.0),
                      onTap: _isLoading
                          ? null
                          : () {
                              Navigator.pushNamed(context, AppConstants.joinFamilyRoute);
                            },
                      child: Opacity(
                        opacity: _isLoading ? 0.6 : 1.0,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.group_add,
                                size: 48,
                                color: Colors.blue,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Join a Family',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Join an existing family group using an invite code',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              if (_isLoading) ...[
                                const SizedBox(height: 16),
                                const CircularProgressIndicator(),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Create Family Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16.0),
                      onTap: _isLoading
                          ? null
                          : () {
                              Navigator.pushNamed(context, AppConstants.createFamilyRoute);
                            },
                      child: Opacity(
                        opacity: _isLoading ? 0.6 : 1.0,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                size: 48,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Create a Family',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start a new family group and invite members',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              if (_isLoading) ...[
                                const SizedBox(height: 16),
                                const CircularProgressIndicator(),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
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
