import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData.light().copyWith(
  indicatorColor: Colors.black,
  textTheme: TextTheme(
    body1: TextStyle(
      color: Colors.black,
    ),
    // list tiles title text color
    subhead: TextStyle(
      color: Colors.black,
    ),
    // list tiles subtitle text color, if not set default is indicator color
//    caption: TextStyle(
//      color: Colors.white,
//    ),
  ),
);

ThemeData darkTheme = ThemeData.dark().copyWith(
  indicatorColor: Colors.white,
  textTheme: TextTheme(
    body1: TextStyle(
      color: Colors.white,
    ),
    subhead: TextStyle(
      color: Colors.white,
    ),
  ),
);

ThemeData halloweenTheme = ThemeData.light().copyWith(
  primaryColor: Color(0xFF67806F),
  scaffoldBackgroundColor: Color(0xFF456970),
  indicatorColor: Colors.white,
  textTheme: TextTheme(
    body1: TextStyle(
      color: Color(0xFFAFF0FF),
    ),
    subhead: TextStyle(
      color: Color(0xFFAFF0FF),
    ),
  ),
);

ThemeData darkBlueTheme = ThemeData.dark().copyWith(
  primaryColor: Color(0xFF1E1E2C),
  scaffoldBackgroundColor: Color(0xFF2D2D44),
  textTheme: TextTheme(
    body1: TextStyle(
      color: Color(0xFF33E1Ed),
    ),
    subhead: TextStyle(
      color: Color(0xFF33E1Ed),
    ),
  ),
);
