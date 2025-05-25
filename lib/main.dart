import 'package:controlusolab/firebase_options.dart';
// Rutas de importación corregidas a la estructura final
import 'package:controlusolab/screens/admin/admin_screen.dart';
import 'package:controlusolab/screens/auth/login_screen.dart';
import 'package:controlusolab/screens/auth/register_screen.dart';
import 'package:controlusolab/screens/support/support_screen.dart';
import 'package:controlusolab/screens/dev/temporal_data_upload_screen.dart';
import 'package:controlusolab/screens/user/user_screen.dart';
import 'package:controlusolab/services/auth_service.dart';
import 'package:controlusolab/widgets/auth_wrapper.dart'; // Asegúrate de que la ruta sea correcta
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart'; // Para formato de fechas en español

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('es_ES', null); // Inicializar localización para fechas
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        // No necesitas StreamProvider para User? aquí si AuthWrapper lo maneja internamente
        // con authService.authStateChanges.
        // Tampoco para userRoleStream si AuthWrapper lo maneja.
      ],
      child: MaterialApp(
        title: 'Control Uso Laboratorios',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple, // Un color base más acorde
          brightness: Brightness.dark, // Tema oscuro por defecto
          scaffoldBackgroundColor: const Color(0xFF1C1B1F), // secondaryDark
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF381E72), // primaryDarkPurple
            elevation: 0,
            iconTheme: IconThemeData(color: Color(0xFFD0BCFF)), // accentPurple
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD0BCFF), // accentPurple
              foregroundColor: const Color(0xFF381E72), // primaryDarkPurple
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            )
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF381E72).withOpacity(0.5), // primaryDarkPurple con opacidad
            labelStyle: TextStyle(color: const Color(0xFFD0BCFF).withOpacity(0.8)), // accentPurple
            hintStyle: TextStyle(color: const Color(0xFFCAC4D0).withOpacity(0.7)), // textOnDarkSecondary
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: const Color(0xFFD0BCFF).withOpacity(0.3)), // accentPurple
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Color(0xFFD0BCFF), width: 1.5), // accentPurple
            ),
            errorStyle: const TextStyle(color: Colors.redAccent),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFD0BCFF), // accentPurple
            )
          ),
          cardTheme: CardTheme(
            elevation: 2,
            color: const Color(0xFF1C1B1F).withOpacity(0.85), // secondaryDark con opacidad
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF381E72), // primaryDarkPurple
            brightness: Brightness.dark,
            primary: const Color(0xFF381E72),
            secondary: const Color(0xFFD0BCFF), // accentPurple
            surface: const Color(0xFF1C1B1F), // secondaryDark
            onPrimary: Colors.white,
            onSecondary: const Color(0xFF381E72),
            onSurface: Colors.white,
            error: Colors.redAccent,
            onError: Colors.white,
          ),
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'), // Español de España
          Locale('en', 'US'), // Inglés
        ],
        locale: const Locale('es', 'ES'), // Establecer español como idioma por defecto
        home: const AuthWrapper(), // AuthWrapper decide la pantalla inicial
        routes: {
          '/login': (context) => const LoginScreen(), // Añadir const
          '/register': (context) => const RegisterScreen(), // Añadir const
          '/admin': (context) => const AdminScreen(), 
          '/support': (context) => const SupportScreen(), 
          '/user': (context) => const UserScreen(), 
          '/temporal-data-upload': (context) => const TemporalDataUploadScreen(), // Añadir const
        },
      ),
    );
  }
}
