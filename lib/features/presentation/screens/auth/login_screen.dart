import 'package:ecom/core/utils/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ecom/features/presentation/providers/auth_provider.dart';
import 'package:ecom/l10n/app_localizations.dart';
import '../root_screen.dart';
import 'widgets/auth_background.dart';
import 'widgets/auth_header.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/auth_button.dart';
import 'widgets/social_auth_button.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isRememberMeChecked) {
        setState(() {
          _rememberMe = true;
          _emailController.text = auth.rememberedEmail ?? '';
        });
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final l10n = AppLocalizations.of(context)!;
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseFillFields),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      await context.read<AuthProvider>().signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        rememberMe: _rememberMe,
      );
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const RootScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final goldColor = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
      ),
      body: AuthBackground(
        child: Column(
          children: [
            const SizedBox(height: 60),
            FadeInAnimation(
              delay: const Duration(milliseconds: 200),
              child: AuthHeader(
                title: l10n.welcomeBack,
                subtitle: l10n.signInSubtitle,
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: FadeInAnimation(
                delay: const Duration(milliseconds: 400),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? theme.colorScheme.surface : Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withAlpha(50) : theme.colorScheme.primary.withAlpha(15),
                        blurRadius: 30,
                        offset: const Offset(0, -10),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AuthTextField(
                          controller: _emailController,
                          label: l10n.emailAddress,
                          hint: l10n.enterEmail,
                          prefixIcon: LucideIcons.mail,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 25),
                        AuthTextField(
                          controller: _passwordController,
                          label: l10n.password,
                          hint: l10n.enterPassword,
                          prefixIcon: LucideIcons.lock,
                          isPassword: true,
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) => setState(() => _rememberMe = value ?? false),
                                    activeColor: theme.colorScheme.primary,
                                    side: BorderSide(
                                      color: onSurface.withAlpha(50),
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  l10n.rememberMe,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: onSurface.withAlpha(150),
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                                );
                              },
                              child: Text(
                                l10n.forgotPassword,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        AuthButton(
                          text: l10n.signIn,
                          onTap: _handleLogin,
                          isLoading: isLoading,
                        ),
                        const SizedBox(height: 40),
                        Row(
                          children: [
                            Expanded(child: Divider(color: onSurface.withAlpha(50))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: Text(
                                l10n.orContinueWith,
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: onSurface.withAlpha(100),
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: onSurface.withAlpha(50))),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SocialAuthButton(
                              iconUrl: 'https://cdn-icons-png.flaticon.com/512/2991/2991148.png',
                              onTap: () {},
                            ),
                            const SizedBox(width: 25),
                            SocialAuthButton(
                              iconUrl: 'https://cdn-icons-png.flaticon.com/512/0/747.png',
                              onTap: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.dontHaveAccount,
                              style: GoogleFonts.poppins(
                                color: onSurface.withAlpha(150),
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SignupScreen()),
                                );
                              },
                              child: Text(
                                l10n.signUp,
                                style: GoogleFonts.poppins(
                                  color: goldColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
