import 'package:flutter/material.dart';
import 'package:flutter_application_3/gemini.dart';
import 'package:flutter_application_3/calenar.dart';
import 'package:flutter_application_3/web.dart';
import 'package:flutter_application_3/pdf.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Syncfusion Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    Book(),
    MyCalendar(),
    ChatScreen(),
    Telegram(),
    WebPage(),
    Test()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ella'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.grey[200],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Book',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Ai Bot',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.telegram),
            label: 'Telegram',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.web),
            label: 'US',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.heart_broken),
            label: 'Test',
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
