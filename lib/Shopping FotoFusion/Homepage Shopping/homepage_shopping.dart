import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fotofusion/Shopping%20FotoFusion/Cart.dart';
import 'package:fotofusion/Shopping%20FotoFusion/Order_page.dart';
import 'package:fotofusion/Shopping%20FotoFusion/womendenimoffwhite.dart';

class Shoppinghomepage extends StatefulWidget {
  const Shoppinghomepage({Key? key}) : super(key: key);

  @override
  State<Shoppinghomepage> createState() => _ShoppinghomepageState();
}
class _ShoppinghomepageState extends State<Shoppinghomepage> {
  int _currentIndex = 0;
  late Timer _timer;
  final List<String> _images = [
    'https://images.pexels.com/photos/6089702/pexels-photo-6089702.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/12768514/pexels-photo-12768514.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/14767149/pexels-photo-14767149.jpeg?auto=compress&cs=tinysrgb&w=600',
    'https://images.pexels.com/photos/12007409/pexels-photo-12007409.jpeg?auto=compress&cs=tinysrgb&w=600',
  ];
  final List<String> _texts = [
    'Women Jacket Off-white',
    'Men Hoodie',
    'Golden Silk Saree',
    '1997 OG Nike Airmax 1 of 100',
  ];
  final List<String> _prices = [
    '₹35,000',
    '₹32,000',
    '₹10,000',
    '₹19,000',
  ];
  String name='';
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String username = 'Loading';
  Future<void> fetchusername() async {
    final user = _auth.currentUser;
    try {
      final docsnap =
      await _firestore.collection('User Details').doc(user!.uid).get();
      if (docsnap.exists) {
        setState(() {
          username = docsnap.data()?['user name'];
          name=docsnap.data()?['user names'];
        });
      }
    } catch (e) {
      print(e);
    }
  }
  @override
  void initState() {
    super.initState();
    _startTimer();
    fetchusername();
    _initializeOnTapHandlers();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
  late List<Function> _onTapImage;
  void _initializeOnTapHandlers() {
    _onTapImage = List<Function>.generate(4, (index) {
      switch (index) {
        case 0:
          return _onTapImage1;
        case 1:
          return _onTapImage2;
        case 2:
          return _onTapImage3;
        case 3:
          return _onTapImage4;
        default:
          throw Exception('Invalid index');
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _images.length;
      });
    });
  }

  void _onTapImage1() {
    // Handle onTap for the first image here
    print('Tapped image 1');
    Navigator.push(context, MaterialPageRoute(builder: (context) => Offwhitedenim(),));
  }

  void _onTapImage2() {
    // Handle onTap for the second image here
    print('Tapped image 2');
  }

  void _onTapImage3() {
    // Handle onTap for the third image here
    print('Tapped image 3');
  }

  void _onTapImage4() {
    // Handle onTap for the fourth image here
    print('Tapped image 4');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                InkWell(
                  onTap: () {
                    _onTapImage[_currentIndex]();
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30.0),
                    child: Image(
                      image: NetworkImage(_images[_currentIndex]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 40, // adjust the top position as needed
                  left: 20, // adjust the left position as needed
                  right: -300, // adjust the right position as needed
                  child: Container(
                    child: IconButton(onPressed: (){
                      print('clicked');
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Cart_page(),));
                    }, icon: Icon(CupertinoIcons.cart,color: Colors.purple,size: 20,))
                  ),
                ),
                Positioned(
                  top: 77, // adjust the top position as needed
                  left: 20, // adjust the left position as needed
                  right: 20, // adjust the right position as needed
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.5), // Greyish transparent color
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: TextField(
                      style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: 'What are you looking?',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: 80, // adjust the top position as needed
                  left: 20, // adjust the left position as needed
                  right: 20, // adjust the right position as needed
                  child: Container(
                    child: Text(_texts[_currentIndex],style: TextStyle(color: Colors.white,fontSize: 30,
                    fontWeight: FontWeight.bold
                    ),)
                  )
                ),
                Positioned(
                    bottom: 20, // adjust the top position as needed
                    left: 20, // adjust the left position as needed
                    right: 20, // adjust the right position as needed
                    child: Container(
                        child: Text(_prices[_currentIndex],style: TextStyle(color: Colors.blue,fontSize: 30,
                            fontWeight: FontWeight.bold
                        ),)
                    )
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _images.asMap().entries.map((entry) {
                int index = entry.key;
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: _currentIndex == index ? Colors.blueAccent : Colors.grey,
                  ),
                );
              }).toList(),
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                Text('Welcome $name',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20),),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                Text('Trending',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20),),
                Spacer(),
                TextButton(onPressed: (){}, child: Text('Show All',style: TextStyle(color: Colors.purple,fontWeight: FontWeight.bold,fontSize: 15),),),
                SizedBox(
                  width: 20,
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.05),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: (){},
                        child: Column(
                          children: [
                            Image(
                              image: NetworkImage('https://images.pexels.com/photos/9558601/pexels-photo-9558601.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
                              height: 180,
                              width: 180,
                            ),
                            Text('Levis T-Shirt',style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal,fontSize: 15),),
                            Row(
                              children: [
                                Text('₹4500 ',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                                Text('  ₹5̶0̶0̶0̶',style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w300),),
                              ],
                            )
                          ],
                        ),
                      )
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.05),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: (){},
                        child: Column(
                          children: [
                            Image(
                              image: NetworkImage('https://media.gucci.com/style/DarkGray_Center_0_0_1200x1200/1679113021/742384_XJFGU_2270_002_100_0000_Light-GG-cotton-silk-polo-shirt.jpg'),
                              height: 180,
                              width: 180,
                            ),
                            Text('GG Cotton Silk Polo T-Shirt',style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal,fontSize: 15),),
                            Row(
                              children: [
                                Text('₹150000',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                                Text('  ₹1̶5̶5̶0̶0̶0̶',style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w300),),
                              ],
                            )
                          ],
                        ),
                      )
                  ),
                  SizedBox(
                    width: 40,
                  ),
                  Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.05),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: (){},
                        child: Column(
                          children: [
                            Image(
                              image: NetworkImage('https://in.louisvuitton.com/images/is/image/lv/1/PP_VP_L/louis-vuitton-embroidered-signature-cotton-t-shirt-ready-to-wear--HQY71WNPL900_PM2_Front%20view.png?wid=1090&hei=1090'),
                              height: 180,
                              width: 180,
                            ),
                            Text('LV Embroidered Cotton T-Shirt',style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal,fontSize: 15),),
                            Row(
                              children: [
                                Text('₹152000',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                                Text('  ₹1̶5̶5̶0̶0̶0̶',style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w300),),
                              ],
                            )
                          ],
                        ),
                      )
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.05),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: (){},
                        child: Column(
                          children: [
                            Image(
                              image: NetworkImage('https://in.louisvuitton.com/images/is/image/lv/1/PP_VP_L/louis-vuitton-damier-leather-harrington-jacket-ready-to-wear--HQL62EBQV822_PM2_Front%20view.png?wid=1090&hei=1090'),
                              height: 180,
                              width: 180,
                            ),
                            Text('Damier Leather Harrington Jacket',style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal,fontSize: 15),),
                            Row(
                              children: [
                                Text('₹660000',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                                Text('   ₹6̶6̶5̶0̶0̶0̶',style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w300),),
                              ],
                            )
                          ],
                        ),
                      )
                  ),
                  SizedBox(
                    width: 20,
                  )
                ],
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                Text('Maha Bachat Deals 🤑',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20),),
                Spacer(),
                TextButton(onPressed: (){}, child: Text('Show All',style: TextStyle(color: Colors.purple,fontWeight: FontWeight.bold,fontSize: 15),),),
                SizedBox(
                  width: 20,
                )
              ],
            ),
            SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }
}
