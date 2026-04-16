import 'package:flutter/material.dart';


class AppColors {
  static const warning = Color.fromARGB(255, 245, 139, 17);
  static const filled = Colors.green;
  static const primary = Color.fromARGB(255, 0, 61, 153);
  static const lightPrimary = Color.fromARGB(255, 42, 82, 143);
}


class AppTextStyles {

  static const cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );


  static const cardSubtitle = TextStyle(
    fontWeight: FontWeight.w600,
  );

}

class AppButtonStyles{





}

class AppGradients {
  
  static BoxDecoration scaffoldBackground(BuildContext context) {
      return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFF5F7FA),
            const Color(0xFFEDEFF3),
          ],
        ),
      );
    }

  static BoxDecoration leftGlow(Color color) {
    return BoxDecoration(
      gradient: RadialGradient(
        center: const Alignment(-1.7, 0),
        radius: 1.4,
        colors: [
          color.withAlpha(89),
          Colors.transparent,
        ],
      ),
    );
  }

  static BoxDecoration rightGlow(Color color) {
    return BoxDecoration(
      gradient: RadialGradient(
        center: const Alignment(1.7, 0),
        radius: 1.4,
        colors: [
          color.withAlpha(89),
          Colors.transparent,
        ],
      ),
    );
  }

  static const blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E5F94),
      Color(0xFF5FA3D1),
    ],
  );
}

