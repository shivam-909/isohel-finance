import 'package:flutter/material.dart';
import 'package:isohel/pages/HomePage.dart';

import 'FinancesPage.dart';
import 'StocksPage.dart';
import 'HomePage.dart';

class HomeScaffold extends StatefulWidget {
  HomeScaffold({Key key}) : super(key: key);

  @override
  _HomeScaffoldState createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<HomeScaffold>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..forward();
    _offsetAnimation =
        Tween<Offset>(begin: const Offset(-1.5, 0.0), end: Offset.zero)
            .animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.fastLinearToSlowEaseIn,
    ));
  }

  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    StocksPage(),
    FinancesPage()
  ];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SlideTransition(
        position: _offsetAnimation,
        child: Scaffold(
          backgroundColor: Color(0xfffafafa),
          body: _widgetOptions.elementAt(_selectedIndex),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.stacked_line_chart_sharp),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_sharp),
                label: '',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Color(0xff845af9),
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}
