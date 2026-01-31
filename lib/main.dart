// import 'package:flutter/material.dart';
// import 'package:todo_app_gelismis/screens/login_screen.dart';
// import 'package:todo_app_gelismis/services/api_test.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   MyApp({super.key});

//   final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Todo Uygulaması',
//       debugShowCheckedModeBanner: false,
//       navigatorKey: _navigatorKey,
//       builder: (context, child) {
//         return GestureDetector(
//           onTap: () => FocusScope.of(context).unfocus(),
//           child: child!,
//         );
//       },
//       theme: ThemeData(
//         scaffoldBackgroundColor: const Color(0xFFFFF9C4),
//       ),
//       home: const SplashScreen(),
//     );
//   }
// }

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _checkSavedCredentials();
//     // API testini çalıştır (debug modda)
//     _testApiConnection();
//   }

//   Future<void> _testApiConnection() async {
//     try {
//       await ApiTest.testApiConnection();
//     } catch (e) {
//       print('API test hatası: $e');
//     }
//   }

//   Future<void> _checkSavedCredentials() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final rememberMe = prefs.getBool('remember_me') ?? false;
//       final savedUsername = prefs.getString('saved_username');
//       final savedPassword = prefs.getString('saved_password');

//       if (rememberMe && savedUsername != null && savedPassword != null) {
//         // Kaydedilmiş bilgiler varsa direkt HomeScreen'e yönlendir
//         // Burada kullanıcı doğrulaması yapılabilir
//         await Future.delayed(const Duration(seconds: 1));
//         if (mounted) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const LoginScreen(),
//             ),
//           );
//         }
//       } else {
//         // Kaydedilmiş bilgiler yoksa LoginScreen'e yönlendir
//         await Future.delayed(const Duration(seconds: 1));
//         if (mounted) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const LoginScreen(),
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       // Hata durumunda LoginScreen'e yönlendir
//       await Future.delayed(const Duration(seconds: 1));
//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const LoginScreen(),
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFFF9C4),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.6),
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: const [
//                   BoxShadow(
//                     color: Colors.black26,
//                     blurRadius: 8,
//                     offset: Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: const Text(
//                 'To-do',
//                 style: TextStyle(
//                   fontSize: 32,
//                   color: Colors.blueGrey,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 40),
//             const CircularProgressIndicator(
//               color: Colors.blueGrey,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // EKLENDİ
import 'package:todo_app_gelismis/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// main fonksiyonunu async yapıyoruz
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // EKLENDİ
  await Firebase.initializeApp(); // EKLENDİ

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo Uygulaması',
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      // Klavye kapatma davranışı
      builder: (context, child) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: child!,
        );
      },
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFF9C4),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSavedCredentials();
  }

  Future<void> _checkSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool('remember_me') ?? false;
      final savedUsername = prefs.getString('saved_username');
      final savedPassword = prefs.getString('saved_password');

      // Bekleme süresi (Logo görünsün diye)
      await Future.delayed(const Duration(seconds: 2));

      if (rememberMe && savedUsername != null && savedPassword != null) {
        // Kaydedilmiş bilgiler varsa direkt Login ekranına yönlendir
        // (LoginScreen içinde otomatik giriş mantığı zaten var veya direkt Home'a da alabilirsin)
        // Güvenlik için Login ekranına atıp oradan geçiş yapmak daha sağlıklıdır.
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        }
      } else {
        // Kaydedilmiş bilgiler yoksa LoginScreen'e yönlendir
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        }
      }
    } catch (e) {
      // Hata durumunda LoginScreen'e yönlendir
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9C4),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                'To-do',
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: Colors.blueGrey,
            ),
          ],
        ),
      ),
    );
  }
}
