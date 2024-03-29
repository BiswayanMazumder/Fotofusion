import 'package:flutter/material.dart';
import 'package:fotofusion/Reels%20page/reel.dart';
import 'package:fotofusion/Shopping%20FotoFusion/Cart.dart';
import 'package:fotofusion/Shopping%20FotoFusion/Homepage%20Shopping/homepage_shopping.dart';
import 'package:fotofusion/Shopping%20FotoFusion/Order_page.dart';
import 'package:fotofusion/account%20page/user_account.dart';
import 'package:fotofusion/navbar_Post_page.dart';
import 'package:fotofusion/pages/explore.dart';
import 'package:fotofusion/pages/homepage.dart';
import 'package:fotofusion/pages/search_screen.dart';
import 'package:fotofusion/posts/post_page.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
class NavBar_shopping extends StatefulWidget {
  const NavBar_shopping({Key? key}) : super(key: key);

  @override
  State<NavBar_shopping> createState() => _NavBar_shoppingState();
}

class _NavBar_shoppingState extends State<NavBar_shopping> {
  final _pageController = PageController(initialPage: 0);
  int _index = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  final List screens=[
    Shoppinghomepage(),
    OrderPage(),
    Cart_page(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_index],
      backgroundColor: Colors.black,

      bottomNavigationBar: GNav(
        backgroundColor: Colors.white,
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
              rippleColor: Colors.green,
              backgroundColor: Colors.red,
            ),
            GButton(icon: Icons.shopping_bag,
              rippleColor: Colors.green,
              backgroundColor: Colors.yellow,
            ),
            GButton(icon: Icons.shopping_cart,
              backgroundColor: Colors.blue,
              haptic: true,
              debug: true,
            ),
          ]
      ),
    );
  }
}
