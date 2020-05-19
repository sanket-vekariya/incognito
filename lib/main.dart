import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:incognito/Models/ThemeSwitchRepo.dart';
import 'package:incognito/Screens/Splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences prefs;
String theme;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  var temp = prefs.getString("theme");
  theme = (prefs.getString("theme") != null)
      ? currentThemeString(temp)
      : "lightTheme";
  runApp(MyApp(theme: theme));
}

class MyApp extends StatelessWidget {
  final theme;

  const MyApp({Key key, this.theme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final initTheme = currentTheme();
    return ThemeProvider(
      initTheme: initTheme,
      key: key,
      child: Builder(builder: (context) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeProvider.of(context),
          home: Splash(),
          debugShowCheckedModeBanner: false,
        );
      }),
    );
  }
}
