import 'package:flutter/material.dart';

var theme = ThemeData(
    bottomNavigationBarTheme:
        BottomNavigationBarThemeData(selectedItemColor: Colors.black),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(backgroundColor: Colors.grey)),
    appBarTheme: AppBarTheme(
      color: Colors.white,
      actionsIconTheme: IconThemeData(color: Colors.black, size: 40),
      titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
    ),
    textTheme: TextTheme(bodyText2: TextStyle(color: Colors.black)));
