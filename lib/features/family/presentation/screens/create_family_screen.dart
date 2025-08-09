import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:family_tree_firebase/core/services/firebase_auth_service.dart';
import 'package:family_tree_firebase/features/family/data/services/family_service.dart';
import 'package:family_tree_firebase/core/service_locator.dart';
import 'package:family_tree_firebase/features/family/presentation/screens/family_created_success_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateFamilyScreen extends StatefulWidget {
  const CreateFamilyScreen({Key? key}) : super(key: key);

  @override
  _CreateFamilyScreenState createState() => _CreateFamilyScreenState();
}

class _CreateFamilyScreenState extends State<CreateFamilyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _familyNameController = TextEditingController();
  late String _inviteCode;
  bool _isLoading = false;
  
  late final FirebaseAuthService _authService;
  late final FamilyService _familyService;

  @override
  void initState() {
    super.initState();
    _authService = sl<FirebaseAuthService>();
    _familyService = sl<FamilyService>();
    _generateInviteCode();
  }

  void _generateInviteCode() {
    // Generate a unique 6-character alphanumeric code using user's UID and timestamp
    final user = _authService.getCurrentUser();
    if (user != null) {
      setState(() {
        _inviteCode = _generateUniqueCode(user.uid, 6);
      });
    } else {
      // Fallback to random code if user is not available
      setState(() {
        _inviteCode = _generateRandomString(6);
      });
    }
  }

  String _generateUniqueCode(String userId, int length) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Removed similar looking characters
    
    // Create a code that's consistent for this user but hard to guess
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uniqueSeed = '${userId}_$timestamp';
    final hash = _generateHash(uniqueSeed);
    
    // Convert hash to base32-like string
    final code = StringBuffer();
    for (var i = 0; i < length; i++) {
      code.write(chars[hash[i] % chars.length]);
    }
    
    return code.toString();
  }
  
  List<int> _generateHash(String input) {
    // Simple hash function that produces consistent results
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.bytes.sublist(0, 6); // Take first 6 bytes for our code
  }
  
  String _generateRandomString(int length) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Removed similar looking characters
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  Future<void> _createFamily() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final user = _authService.getCurrentUser();
      if (user == null) throw Exception('User not logged in');

      // Create family
      await _familyService.createFamily(
        name: _familyNameController.text.trim(),
        adminId: user.uid,
      );

      if (mounted) {
        // Navigate to success screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FamilyCreatedSuccessScreen(
              familyName: _familyNameController.text.trim(),
              inviteCode: _inviteCode,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating family: ${e.toString()}')),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Create New Family',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Family Name Field
              TextFormField(
                controller: _familyNameController,
                style: GoogleFonts.poppins(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Family Name',
                  labelStyle: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF6A11CB)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a family name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              // Invite Code Section
              Text(
                'Invite Code',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _inviteCode,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Color(0xFF6A11CB)),
                      onPressed: _generateInviteCode,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Share this code with family members to join your family',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              const Spacer(),
              
              // Create Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _createFamily,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A11CB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Create Family',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _familyNameController.dispose();
    super.dispose();
  }
}
