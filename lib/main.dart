import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thuetro/model/post.dart';
import 'package:thuetro/provider/auth_provider.dart';
import 'package:thuetro/provider/post_provider.dart';
import 'package:thuetro/view/bottomappbar.dart';
import 'package:thuetro/view/chat.dart';
import 'package:thuetro/view/detail_edit_post.dart';
import 'package:thuetro/view/detail_post.dart';
import 'package:thuetro/view/post.dart';
import 'package:thuetro/view/post_update.dart';
import 'package:thuetro/view/profile.dart';
import 'package:thuetro/view/room_chat.dart';
import 'package:thuetro/view/search.dart';
import 'package:thuetro/view/sign_in.dart';
import 'package:thuetro/view/sign_up.dart';

import 'miscellaneous_test/test_3D_img.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mvhldwmcuhdjbkgsgyib.supabase.co', // Project URL
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im12aGxkd21jdWhkamJrZ3NneWliIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY1NTc4ODIsImV4cCI6MjA3MjEzMzg4Mn0.zxqJ9CuzW3Bt8tquKBHBopgYUVYSEw-kDWqd9RdvxnI', // Anon public key
  );
  runApp(ProviderScope(child: MyApp()));
}

Future<void> initAuth(WidgetRef ref) async {
  final prefs = await SharedPreferences.getInstance();
  final uuid = prefs.getString("uuid");
  final statusLogin = prefs.getBool("status_login") ?? false;
  print("$uuid và $statusLogin");
  if (uuid != null && statusLogin) {
  ref.watch(loggedInProvider.notifier).state = true;
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAuth(ref);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authInitProvider);
    // final loggedIn = ref.watch(loggedInProvider);
    // initAuth(ref);
    final router = GoRouter(
      routes: [
        GoRoute(path: '/sign_in', builder: (_, __) => const SignIn()),
        GoRoute(path: '/signup', builder: (context, state) => const SignUp()),
        GoRoute(path: '/search', builder: (_, __) => SearchPage()),
        GoRoute(path: '/post', builder: (_, __) => Post()),
        GoRoute(path: '/chat', builder: (_, __) => Chat()),
        // GoRoute(path: '/update_post', builder: (_, __) => PostUpdate()),
        GoRoute(path: '/panorama_screen', builder: (_, __) => PanoramaScreen()),
        GoRoute(path: '/', builder: (_, __) => MyHomePage()),
        GoRoute(
          path: '/chatroom',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return RoomChat(
              friend: extra['friend'],
              roomId: extra['room_id'],
            );
          },
        ),

        GoRoute(
          path: '/detail',
          builder: (context, state) {
            final post =
                state.extra as Map<String, dynamic>; // ép kiểu về object
            return DetailPost(post: post);
          },
        ),
        GoRoute(path: '/', builder: (_, __) => MyHomePage()),
        GoRoute(
          path: '/update_post',
          builder: (context, state) {
            final post =
                state.extra as Map<String, dynamic>; // ép kiểu về object
            return PostUpdate(post: post);
          },
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) {
            final acc =
            state.extra as Map<String, dynamic>; // ép kiểu về object
            return Profile(acc: acc);
          },
        ),
        GoRoute(path: '/', builder: (_, __) => MyHomePage()),
        GoRoute(
          path: '/detail_edit_post',
          builder: (context, state) {
            final post =
                state.extra as Map<String, dynamic>; // ép kiểu về object
            return DetailEditPost(post: post);
          },
        ),
      ],

      // redirect: (context, state) {
      //   final loggedIn = ref.read(loggedInProvider);
      //
      //   final loggingIn = state.uri.path == '/'; // trang SignIn
      //   final signingUp = state.uri.path == '/signup';
      //
      //   if (!loggedIn && !loggingIn && !signingUp) {
      //     return '/'; // chưa login, redirect về SignIn
      //   }
      //
      //   if (loggedIn && (loggingIn || signingUp)) {
      //     return '/MyHomePage'; // đã login, không cho vào SignIn/SignUp
      //   }
      //
      //   return null; // không redirect
      // },
    );
    return authState.when(
      data: (check) {
        return MaterialApp.router(
          routerConfig: router,
          title: "Thuê trọ",
          debugShowCheckedModeBanner: false,
        );
      },
      loading: () => const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (e, _) => MaterialApp(
        home: Scaffold(body: Center(child: Text('Lỗi: $e'))),
      ),
    );
  }
}
