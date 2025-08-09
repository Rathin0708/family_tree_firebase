import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:family_tree_firebase/features/family/data/services/family_service.dart';

class JoinFamilyScreen extends StatefulWidget {
  const JoinFamilyScreen({Key? key}) : super(key: key);

  @override
  State<JoinFamilyScreen> createState() => _JoinFamilyScreenState();
}

class _JoinFamilyScreenState extends State<JoinFamilyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _inviteCodeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _joinFamily() async {
    if (!_formKey.currentState!.validate()) return;

    // Dismiss keyboard
    FocusScope.of(context).unfocus();
    
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Please sign in to join a family');
      }
      
      final familyService = Provider.of<FamilyService>(context, listen: false);
      final inviteCode = _inviteCodeController.text.trim().toUpperCase();
      
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF6B35),
          ),
        ),
      );
      
      // Join the family
      await familyService.joinFamily(
        inviteCode: inviteCode,
        userId: user.uid,
        userName: user.displayName ?? 'New Member',
      );
      
      if (mounted) {
        // Close loading dialog
        Navigator.of(context).pop();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Successfully joined family!',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    // Navigate to family screen
                    Navigator.pushReplacementNamed(context, '/family');
                  },
                  child: const Text(
                    'VIEW FAMILY',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.fixed,
            duration: const Duration(seconds: 5),
          ),
        );
        
        // Navigate back to home screen
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/home',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        // Close loading dialog if still open
        Navigator.of(context).pop();
        
        // Default error message
        String errorMessage = 'Failed to join family. Please try again.';
        String errorDetails = e.toString();
        
        // Map specific error messages
        if (errorDetails.contains('already a member of a family')) {
          errorMessage = 'You are already a member of another family. Leave your current family to join a new one.';
        } else if (errorDetails.contains('Invalid invite code') || 
                  errorDetails.contains('not found')) {
          errorMessage = 'Invalid invite code. Please check and try again.';
        } else if (errorDetails.contains('network') || 
                  errorDetails.contains('unavailable')) {
          errorMessage = 'Network error. Please check your connection and try again.';
        } else if (errorDetails.contains('permission-denied')) {
          errorMessage = 'You do not have permission to join this family.';
        }
        
        // Show error dialog with retry option
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Could Not Join Family'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
              if (errorDetails.contains('already a member of a family'))
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to family settings to leave current family
                    Navigator.pushNamed(context, '/settings/family');
                  },
                  child: const Text('MANAGE FAMILY'),
                ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Family'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF333333)),
      ),
      extendBodyBehindAppBar: true,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Icon(
                Icons.group_add,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                'Join a Family',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Enter the invite code provided by your family member to join their family group.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _inviteCodeController,
                decoration: InputDecoration(
                  labelText: 'Invite Code',
                  labelStyle: GoogleFonts.poppins(
                    color: const Color(0xFF666666),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFF6B35)),
                  ),
                  prefixIcon: const Icon(Icons.vpn_key, color: Color(0xFFFF6B35)),
                  hintText: 'Enter 6-digit code',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey[400],
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: GoogleFonts.poppins(
                  color: const Color(0xFF333333),
                ),
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an invite code';
                  }
                  if (value.length != 6) {
                    return 'Invite code must be 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _joinFamily,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
                    : const Text('Join Family'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.pop(context);
                      },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFF6B35),
                  textStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
