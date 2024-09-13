import 'package:flutter/material.dart';
import 'package:geo_tag/core/shared_prefs/shared_prefs.dart';
import 'package:geo_tag/core/widgets/label_widegt.dart';
import 'package:geo_tag/core/widgets/loader_widget.dart';
import 'package:geo_tag/core/widgets/primary_button.dart';
import 'package:geo_tag/core/widgets/text_field_widget.dart';
import 'package:geo_tag/features/home/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const LoaderWidget()
        : Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 60,
                      ),
                      Image.asset(
                        height: 60,
                        // width: 60,
                        'assets/images/logo.png',
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Text(
                        'Welcome back!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withOpacity(0.9),
                        ),
                      ),
                      Text(
                        'Login now to continue using Geo Tag',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.black.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const LabelWidget(label: 'Full Name'),
                            TextFieldWidget(
                              controller: _nameController,
                              label: 'Enter your full name',
                              keyboardType: TextInputType.name,
                              isPassword: false,
                              validator: (val) {
                                return val!.isNotEmpty
                                    ? null
                                    : 'Please provide a valid name';
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      PrimaryButton(
                        label: 'Login',
                        onTap: () {
                          if ((_formKey.currentState!.validate())) {
                            _handleLogin(_nameController.text);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  _handleLogin(String username) async {
    setState(() {
      _isLoading = true;
    });
    SharedPrefs.saveUsernameSharedPreference(username);
    await Future.delayed(const Duration(seconds: 2));
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text('Welcome $username'),
      ),
    );
    // setState(() {
    //   _isLoading = false;
    // });
  }
}
