import 'package:flutter/material.dart';
import 'package:fotofusion/account%20page/user_account.dart';
import 'package:fotofusion/pages/explore.dart';
import 'package:fotofusion/pages/homepage.dart';
import 'package:fotofusion/posts/post_page.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  final _pageController = PageController(initialPage: 0);

  /// Controller to handle bottom nav bar and also handles initial page

  int _index = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  final List screens=[
    Homepage(),
    ExplorePage(),
    Postpage(),
    Account_page(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_index],
      backgroundColor: Colors.black,

      bottomNavigationBar: GNav(
          haptic: true,
          curve: Curves.bounceInOut,
          rippleColor: Colors.yellow,
          tabActiveBorder: Border.all(color: Colors.green,
              style: BorderStyle.solid),
          hoverColor: Colors.white,
          activeColor: Colors.black,
          color: Colors.deepPurpleAccent,
          // rippleColor: Colors.green,
          tabBackgroundColor: Colors.green,
          selectedIndex: _index,
          // tabBorder: Border.all(color: Colors.red),
          gap: 1,
          onTabChange: (value){
            setState(() {
              _index=value;
            });
          },
          tabs: [
            GButton(icon: Icons.home,
              text: 'HomePage',
              rippleColor: Colors.green,
              backgroundColor: Colors.cyan,
            ),
            GButton(icon: Icons.search,
              text: 'Search',
              rippleColor: Colors.green,
              backgroundColor: Colors.cyan,
            ),
            GButton(icon: Icons.add,text: 'Upload',
              backgroundColor: Colors.lightGreenAccent,
            ),
            GButton(icon: Icons.person,text: 'Profile',
              backgroundColor: Colors.deepOrangeAccent,
              haptic: true,
              debug: true,
            ),
          ]
      ),
    );
  }
}
