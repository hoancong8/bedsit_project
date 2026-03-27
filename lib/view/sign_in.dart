import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thuetro/provider/auth_provider.dart';

// Provider quản lý trạng thái đăng nhập (demo thôi, chưa kết nối Supabase)
// final authProvider = StateProvider<bool>((ref) => false);

class SignIn extends ConsumerStatefulWidget {
  const SignIn({super.key});

  @override
  ConsumerState<SignIn> createState() => _SignInState();
}

class _SignInState extends ConsumerState<SignIn> {
  // State cục bộ cho form
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    // Nhớ dispose controller khi widget bị huỷ
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFe6f7ff), Color(0xFFcfeefd)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 40.0,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                color: Colors.white.withOpacity(0.98),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          FlutterLogo(size: 52),
                          SizedBox(width: 12),
                          Text(
                            'THUÊ TRỌ',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      const Center(
                        child: Text(
                          'Đăng nhập',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14.0,
                            horizontal: 12.0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          prefixIcon: const Icon(Icons.lock_outline),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14.0,
                            horizontal: 12.0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text('Quên mật khẩu?'),
                        ),
                      ),

                      const SizedBox(height: 8),

                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            final a = await ref
                                .read(authProvider.notifier)
                                .signIn(
                                  emailController.text,
                                  passwordController.text,
                                  ref,
                                );
                            if (a) {
                              ref.read(loggedInProvider.notifier).state = true;
                              ref.invalidate(authInitProvider);
                              GoRouter.of(context).go('/');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Đăng nhập',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Text(
                              'Bạn chưa có tài khoản?',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () => GoRouter.of(context).push('/signup'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: primary, width: 1.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Đăng kí',
                            style: TextStyle(color: primary, fontSize: 16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Bằng việc đăng nhập bạn đồng ý với Điều khoản của chúng tôi',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
