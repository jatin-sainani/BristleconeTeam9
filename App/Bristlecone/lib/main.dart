import 'package:flutter/material.dart';

import './MainPage.dart';
import 'intro/intro_page_view.dart';
void main() => runApp(new ExampleApplication());

class ExampleApplication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new IntroPageView(),
      routes: <String,WidgetBuilder>
        {
          'home' : (BuildContext context) => MainPage()


        },
    );
  }
}
