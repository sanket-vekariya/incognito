import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:incognito/Models/SharedPreferenceRepo.dart';
import 'package:incognito/main.dart';
import 'package:incognito/theme_config.dart';

switchThemeDrawerMethod(BuildContext context) async {
  theme = await getTheme();
  ThemeSwitcher.of(context).changeTheme(
    theme: switchTheme(),
  );
  theme = updateSwitchedTheme();
  setTheme(theme);
}

String updateSwitchedTheme() {
  return (theme == "darkTheme")
      ? "lightTheme"
      : (theme == "lightTheme")
          ? "halloweenTheme"
          : (theme == "halloweenTheme")
              ? "darkBlueTheme"
              : (theme == "darkBlueTheme") ? "darkTheme" : "lightTheme";
}

ThemeData switchTheme() {
  return (theme == "darkTheme")
      ? lightTheme
      : (theme == "lightTheme")
          ? halloweenTheme
          : (theme == "halloweenTheme")
              ? darkBlueTheme
              : (theme == "darkBlueTheme") ? darkTheme : lightTheme;
}

String currentThemeString(String temp) {
  return (temp == "darkTheme")
      ? "darkTheme"
      : (temp == "lightTheme")
          ? "lightTheme"
          : (temp == "halloweenTheme")
              ? "halloweenTheme"
              : (temp == "darkBlueTheme") ? "darkBlueTheme" : "lightTheme";
}

ThemeData currentTheme() {
  return (theme == "darkTheme")
      ? darkTheme
      : (theme == "lightTheme")
          ? lightTheme
          : (theme == "halloweenTheme")
              ? halloweenTheme
              : (theme == "darkBlueTheme") ? darkBlueTheme : lightTheme;
}
