// ignore_for_file: await_only_futures, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'admin_home_screen.dart';
import 'admin_game_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _showOtpField = false;
  final _prefs = SharedPreferences.getInstance();

  // Demo OTP for testing
  static const String demoOtp = '123456';

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    final phoneNumber = _phoneController.text.trim();
    
    if (!_showOtpField) {
      // Request OTP
      setState(() {
        _showOtpField = true;
        _isLoading = false;
      });
      return;
    }

    // Verify OTP and login
    if (_otpController.text != demoOtp) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid OTP. Please try again.')),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    // Find user and handle login
    final user = User.findByPhone(phoneNumber);
    
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found')),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    // Save user session
    final prefs = await _prefs;
    await prefs.setString('auth_token', user.authToken ?? '');
    await prefs.setString('user_phone', user.phoneNumber);
    await prefs.setBool('is_admin', user.isAdmin);

    if (mounted) {
      // Navigate based on user type
      if (user.isAdmin) {
        // Check if this admin has an active room
        final roomId = await prefs.getString('admin_room_id');
        
        if (roomId != null && roomId.isNotEmpty) {
          // Admin has an active room, show game dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AdminGameDashboard(
                roomId: roomId,
              ),
            ),
          );
        } else {
          // No active room, show admin home
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
          );
        }
      } else {
        // Regular user flow
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Logo
                Icon(
                  Icons.games,
                  size: 100,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 20),
                // Title
                Text(
                  'Welcome Back!',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Phone Number Field
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixText: '+91 ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (value.length != 10) {
                      return 'Please enter a valid 10-digit number';
                    }
                    return null;
                  },
                ),
                if (_showOtpField) ...[  
                  const SizedBox(height: 20),
                  // OTP Field
                  TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Enter OTP',
                      hintText: '123456',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the OTP';
                      }
                      if (value.length != 6) {
                        return 'OTP must be 6 digits';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 30),
                // Login Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
                      : Text(
                          _showOtpField ? 'Verify & Login' : 'Get OTP',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
                // Demo credentials hint
                if (!_showOtpField) ...[  
                  const SizedBox(height: 20),
                  Text(
                    'Demo Numbers: 1234567890 (Admin) or 2345678901 (User)',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use OTP: 123456',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}