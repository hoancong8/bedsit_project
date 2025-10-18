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
    // final authState = ref.watch(authProvider);
    return Scaffold(

      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  FlutterLogo(size: 40),
                  SizedBox(width: 10),
                  Text(
                    "THUÊ TRỌ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              Text(
                "Đăng nhập",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Mật khẩu",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: TextButton(
                  onPressed: () {},
                  child: const Text("Quên mật khẩu?"),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: () async {
                    final a = await ref
                        .read(authProvider.notifier)
                        .signIn(emailController.text, passwordController.text,ref);
                    if (a) {
                      ref.read(loggedInProvider.notifier).state = true;
                      ref.invalidate(authInitProvider);
                      // ref.read(userIdProvider.notifier).state = prefs.getString("uuid")!;
                      GoRouter.of(context).go('/');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 217, 217, 217),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(10),
                    ),
                  ),
                  child: const Text("Đăng nhập"),
                ),
              ),

              Row(
                children: [
                  Expanded(child: const Divider()),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Bạn chưa có tài khoản?"),
                  ),
                  Expanded(child: const Divider()),
                ],
              ),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    GoRouter.of(context).push('/signup');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 217, 217, 217),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(10),
                    ),
                  ),

                  child: const Text("Đăng kí"),
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }
}
