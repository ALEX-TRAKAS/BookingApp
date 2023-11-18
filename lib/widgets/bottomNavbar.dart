import 'package:flutter/material.dart';
import 'package:bookingapp/routes/app_routes.dart';
import 'package:get/get.dart';

class bottomNavigationBar extends StatefulWidget{
  const bottomNavigationBar({super.key});

  @override
  _bottomNavigationBar createState() =>_bottomNavigationBar();
}
void onTabTapped(int index) {
    if(index==2) {
      
    }
  }

class _bottomNavigationBar extends  State<bottomNavigationBar> {


  
  int currentPageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
          if(currentPageIndex==2){
            Get.toNamed(AppRoutes.profileScreen);
          }
        },
        indicatorColor: const Color.fromRGBO(15, 155, 15, 100),
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Αρχική',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.search),
            icon: Icon(Icons.search_outlined),
            label: 'Αναζήτηση',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.bookmark),
            icon: Icon(Icons.bookmark_outline),
            label: 'Αγαπημένα',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.calendar_month),
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Κρατήσεις',
          ),
        ],
      ),
    );
  }}
