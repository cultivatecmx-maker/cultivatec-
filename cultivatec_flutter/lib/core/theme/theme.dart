import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // === Design System: "Wokov Blue" (plano, redondeado, muy azul) ===
  // Inspirado en la claridad de Duolingo: colores sólidos, sombra sólida
  // debajo de cada pieza y formas muy redondeadas. Nada de degradados ni
  // sombras difusas.

  // Azules de marca (cultivatec.com.mx usa #0958C2)
  static const Color brandBlue = Color(0xFF0958C2);
  // Escala completa de azules (del más oscuro al más claro)
  static const Color navyDeep = Color(0xFF061A4D);
  static const Color navy = Color(0xFF0A2463);
  static const Color toneNavy = Color(0xFF123A8F);
  static const Color toneIndigo = Color(0xFF3B5BDB);
  static const Color toneAzure = Color(0xFF0B8BD6);
  static const Color toneSky = Color(0xFF4DA3FF);
  static const Color primaryBlue = Color(0xFF1F6FEB);
  static const Color primaryDark = Color(0xFF0F4CB8); // sombra sólida de botones
  static const Color primaryLight = Color(0xFF5AA7FF);
  static const Color skyBlue = Color(0xFF8CC8FF);
  static const Color iceBlue = Color(0xFFDCEBFF);

  // Acentos
  static const Color accentGreen = Color(0xFF58CC02); // verde brote de Wokov = acierto
  static const Color accentGreenDark = Color(0xFF46A302);
  static const Color accentCyan = Color(0xFF1CB0F6);
  static const Color accentOrange = Color(0xFFFF9600);
  static const Color accentRed = Color(0xFFFF4B4B);
  static const Color accentRedDark = Color(0xFFD33131);
  static const Color accentGold = Color(0xFFFFC800);
  static const Color accentPurple = Color(0xFF3B5BDB); // índigo (azul)
  static const Color accentPink = Color(0xFFFF6FB5);
  static const Color accentLeaf = Color(0xFF7CC142); // hoja de Wokov

  // Fondos (todos con tinte azul)
  static const Color bgPrimary = Color(0xFFE2EEFF);
  static const Color bgSurface = Color(0xFFFFFFFF);
  static const Color bgSecondary = Color(0xFFD0E3FF);
  static const Color bgTertiary = Color(0xFFBBD5FF);

  // Alias heredados
  static const Color bgLight = bgPrimary;
  static const Color bgCard = bgSurface;

  // Texto (azul marino, como el contorno de Wokov)
  static const Color textPrimary = Color(0xFF0B2A5B);
  static const Color textSecondary = Color(0xFF45638F);
  static const Color textMuted = Color(0xFF8DA2C4);
  static const Color textHint = Color(0xFFC0CEE4);

  // Bordes
  static const Color borderColor = Color(0xFFCFE0FA);
  static const Color borderLight = Color(0xFFE4EEFC);
  static const Color borderFocus = primaryBlue;

  // Rarezas
  static const Color rarityCommon = Color(0xFF64748B);
  static const Color rarityRare = Color(0xFF1CB0F6);
  static const Color rarityEpic = Color(0xFF5B7CFA);
  static const Color rarityLegendary = Color(0xFFFFC800);

  // Sombras SÓLIDAS (sin blur): dan el efecto "pieza física" de Duolingo.
  static List<BoxShadow> get shadowSm => const [
        BoxShadow(color: Color(0xFFCFE0FA), blurRadius: 0, offset: Offset(0, 3)),
      ];

  static List<BoxShadow> get shadowMd => const [
        BoxShadow(color: Color(0xFFBBD3F5), blurRadius: 0, offset: Offset(0, 4)),
      ];

  static List<BoxShadow> get shadowLg => const [
        BoxShadow(color: Color(0xFFA9C7F2), blurRadius: 0, offset: Offset(0, 5)),
      ];

  static List<BoxShadow> get shadowGlow => const [
        BoxShadow(color: primaryDark, blurRadius: 0, offset: Offset(0, 5)),
      ];

  /// Tarjeta "3D" estándar: fondo sólido, borde de 2 px y sombra sólida abajo.
  static BoxDecoration cardDecoration({
    Color? color,
    Color? border,
    double radius = radiusLg,
    bool raised = true,
  }) {
    final b = border ?? borderColor;
    return BoxDecoration(
      color: color ?? bgSurface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: b, width: 2),
      boxShadow: raised ? [BoxShadow(color: b, blurRadius: 0, offset: const Offset(0, 4))] : null,
    );
  }

  // Degradados: ahora son planos (mismo color) para que todo el código
  // existente se vea sólido sin tener que editarlo pantalla por pantalla.
  /// Encabezados y barras grandes: del azul marino al azul de marca.
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A2463), Color(0xFF0958C2), Color(0xFF1F6FEB)],
    stops: [0.0, 0.62, 1.0],
  );

  /// Fondo de pantallas: cielo azul que se aclara hacia abajo.
  static const LinearGradient pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFC9DFFF), Color(0xFFE2EEFF), Color(0xFFEFF6FF)],
    stops: [0.0, 0.45, 1.0],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, primaryBlue],
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentCyan, accentCyan],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [bgSurface, bgSurface],
  );

  // Animation durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 500);
  static const Duration animVerySlow = Duration(milliseconds: 800);

  // Rounded corners
  static const double radiusSm = 14.0;
  static const double radiusMd = 18.0;
  static const double radiusLg = 24.0;
  static const double radiusXl = 32.0;

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          brightness: Brightness.light,
          surface: bgSurface,
        ),
        scaffoldBackgroundColor: bgPrimary,
        textTheme: TextTheme(
          displayLarge: GoogleFonts.nunito(fontWeight: FontWeight.w900),
          displayMedium: GoogleFonts.nunito(fontWeight: FontWeight.w900),
          displaySmall: GoogleFonts.nunito(fontWeight: FontWeight.w800),
          headlineLarge: GoogleFonts.nunito(fontWeight: FontWeight.w900),
          headlineMedium: GoogleFonts.nunito(fontWeight: FontWeight.w800),
          headlineSmall: GoogleFonts.nunito(fontWeight: FontWeight.w800),
          titleLarge: GoogleFonts.nunito(fontWeight: FontWeight.w900),
          titleMedium: GoogleFonts.nunito(fontWeight: FontWeight.w800),
          titleSmall: GoogleFonts.nunito(fontWeight: FontWeight.w800),
          bodyLarge: GoogleFonts.nunito(fontWeight: FontWeight.w600),
          bodyMedium: GoogleFonts.nunito(fontWeight: FontWeight.w600),
          bodySmall: GoogleFonts.nunito(fontWeight: FontWeight.w600),
          labelLarge: GoogleFonts.nunito(fontWeight: FontWeight.w800),
          labelMedium: GoogleFonts.nunito(fontWeight: FontWeight.w700),
          labelSmall: GoogleFonts.nunito(fontWeight: FontWeight.w700),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: textPrimary,
          titleTextStyle: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w900, color: textPrimary),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusXl),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
            textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryBlue,
            side: const BorderSide(color: primaryBlue, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusXl),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
            textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: primaryBlue, width: 2),
          ),
          filled: true,
          fillColor: bgSurface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: bgSurface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: bgSurface,
          selectedItemColor: primaryBlue,
          unselectedItemColor: textMuted,
          elevation: 0,
        ),
        dividerTheme: const DividerThemeData(
          color: borderColor,
          thickness: 1.5,
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: ZoomPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: ZoomPageTransitionsBuilder(),
          },
        ),
      );

  /// Smooth slide+fade page route for manual navigation
  static Route<T> smoothRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: animNormal,
      reverseTransitionDuration: animNormal,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(curved),
          child: FadeTransition(opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut), child: child),
        );
      },
    );
  }
}
