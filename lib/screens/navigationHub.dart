import 'package:bookingapp/screens/FavoritesScreen.dart';
import 'package:bookingapp/screens/HomeScreen.dart';
import 'package:bookingapp/screens/profileScreen.dart';
import 'package:bookingapp/screens/reservationsScreen.dart';
import 'package:bookingapp/screens/searchScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bookingapp/utils/AppStyles.dart';

class navigationHub extends StatefulWidget {
  navigationHub({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<navigationHub> {
  final user = FirebaseAuth.instance.currentUser!;
  int _currentIndex = 0;
  PageController _pageController = PageController();
  final List<Widget> _pages = [
    HomeScreen(),
    SearchScreen(),
    FavoritesScreen(),
    ReservationsScreen(),
    profileScreen(),
  ];
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[200],
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey[800],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.animateToPage(index,
                duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Αρχική',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Αναζήτηση',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Αγαπημένα',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Κρατήσεις',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Προφίλ',
          ),
        ],
      ),
    );
  }
}

// class navigationHub extends StatefulWidget {
//   navigationHub({Key? key}) : super(key: key);

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<navigationHub> {
//   final user = FirebaseAuth.instance.currentUser!;
//   int _currentIndex = 0;
//   void updateIndex(int index) {
//     _currentIndex = index;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: AnimatedSwitcher(
//         duration: Duration(milliseconds: 300),
//         child: IndexedStack(
//           key: ValueKey<int>(_currentIndex),
//           index: _currentIndex,
//           children: [
//             HomeScreen(),
//             SearchScreen(),
//             FavoritesScreen(),
//             ReservationsScreen(),
//             profileScreen(),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         backgroundColor: Colors.grey[200],
//         selectedItemColor: primary,
//         unselectedItemColor: Colors.grey[800],
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Αρχική',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.search),
//             label: 'Αναζήτηση',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.bookmark),
//             label: 'Αγαπημένα',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.calendar_month),
//             label: 'Κρατήσεις',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Προφίλ',
//           ),
//         ],
//       ),
//     );
//   }
// }
