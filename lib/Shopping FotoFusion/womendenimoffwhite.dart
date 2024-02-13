//blue pid-1001
//black pid-1002
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elegant_notification/resources/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_animated_button/simple_animated_button.dart';
class Offwhitedenim extends StatefulWidget {
  const Offwhitedenim({Key? key}) : super(key: key);

  @override
  State<Offwhitedenim> createState() => _OffwhitedenimState();
}

class _OffwhitedenimState extends State<Offwhitedenim> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _currentIndex = 0;
  late Timer _timer;
  bool isblue=true;
  bool isblack=false;
  final List<String> _imagesblue = [
    'https://cdn-images.farfetch-contents.com/20/18/88/81/20188881_50824225_1000.jpg',
    'https://cdn-images.farfetch-contents.com/20/18/88/81/20188881_50824225_1000.jpg',
    'https://cdn-images.farfetch-contents.com/20/20/76/33/20207633_45892577_1000.jpg',
    'https://cdn-images.farfetch-contents.com/20/20/76/33/20207633_45892576_1000.jpg',
    'https://cdn-images.farfetch-contents.com/20/20/76/33/20207633_45892575_1000.jpg',
  ];
  final List<String> _imagesblack = [
    'https://cdn-images.farfetch-contents.com/20/73/46/94/20734694_51704712_1000.jpg',
    'https://cdn-images.farfetch-contents.com/20/73/46/94/20734694_51704700_1000.jpg',
    'https://cdn-images.farfetch-contents.com/20/73/46/94/20734694_51704692_1000.jpg',
    'https://cdn-images.farfetch-contents.com/20/73/46/94/20734694_51704676_1000.jpg',
    'https://cdn-images.farfetch-contents.com/20/73/46/94/20734694_51704696_1000.jpg',
  ];
  bool S_blue=false;
  bool L_blue=false;
  bool M_blue=false;
  bool XL_blue=false;
  bool XXL_blue=false;
  bool selected_S_blue=false;
  bool selected_L_blue=false;
  bool selected_M_blue=false;
  bool selected_XL_blue=false;
  bool selected_XXL_blue=false;
  bool S_black=false;
  bool L_black=false;
  bool M_black=false;
  bool XL_black=false;
  bool XXL_black=false;
  bool selected_S_black=false;
  bool selected_L_black=false;
  bool selected_M_black=false;
  bool selected_XL_black=false;
  bool selected_XXL_black=false;
  Future<void> updateImagesPeriodically() async {
    while (true) {
      await fetchsizeblue();
      await fetchsizeblack();
    }
  }
  Future<void> fetchsizeblue() async{
    final docsnap=await _firestore.collection('FotoKart').doc('Offwhite zip-embellishment denim jacket').get();
    if(docsnap.exists){
      setState(() {
        S_blue=docsnap.data()?['S'];
        L_blue=docsnap.data()?['L'];
        M_blue=docsnap.data()?['M'];
        XL_blue=docsnap.data()?['XL'];
        XXL_blue=docsnap.data()?['XXL'];
      });
    }
    print('Sizes ${S_blue} ${L_blue} ${M_blue} ${XL_blue} ${XXL_blue}');
  }
  Future<void> fetchsizeblack() async{
    final docsnap=await _firestore.collection('FotoKart').doc('Offwhite zip-embellishment denim jacket black').get();
    if(docsnap.exists){
      setState(() {
        S_black=docsnap.data()?['S'];
        L_black=docsnap.data()?['L'];
        M_black=docsnap.data()?['M'];
        XL_black=docsnap.data()?['XL'];
        XXL_black=docsnap.data()?['XXL'];
      });
    }
    print('Sizes ${S_black} ${L_black} ${M_black} ${XL_black} ${XXL_black}');
  }
  @override
  void initState() {
    super.initState();
    _startTimer();
    updateImagesPeriodically();
    fetchsizeblue();
    fetchsizeblack();
  }
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _imagesblue.length;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30.0),
                  child: Image(
                    filterQuality: FilterQuality.high,
                    image: isblue?NetworkImage(_imagesblue[_currentIndex]):NetworkImage(_imagesblack[_currentIndex]),
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 40,
                  left: -300,
                  right: 20,
                  child: Container(
                    child: IconButton(onPressed: (){
                      Navigator.pop(context);
                    }, icon: Icon(CupertinoIcons.back,color: Colors.black,))
                  ),
                ),

              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                Text('Off-White',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 40),),
                Spacer(),
                isblue?Text('Product ID-1001',style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w200,fontSize: 10),):
                Text('Product ID-1002',style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w200,fontSize: 10),),
                SizedBox(
                  width: 10,
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                isblue?Text('₹35,000',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: 25),):
                Text('₹40,000',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: 25),),
                Spacer(),
                Text('Seller- Off-White',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w200,fontSize: 10),),
                SizedBox(
                  width: 10,
                )
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
                Text('zip-embellishment denim jacket',style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w200,
                    fontSize: 20),),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                isblue?Text('Colour- Blue',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w200,
                    fontSize: 20),):Text('Colour-Black',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w200,
                    fontSize: 20),),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: (){
                    setState(() {
                      isblack=true;
                      isblue=false;
                      print('is blue $isblue isblack $isblack');
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: isblack?Colors.green:Colors.white,
                            width:3)
                    ),
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.black,
                    ),
                  ),
                ),
                SizedBox(
                  width: 30,
                ),
                InkWell(
                  onTap: (){
                    setState(() {
                      isblue=true;
                      isblack=false;
                      print('is blue $isblue isblack $isblack');
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: isblue?Colors.red:Colors.white,
                          width:3)
                    ),
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                isblue?S_blue||M_blue||L_blue||XL_blue||XXL_blue?Text('Sizes Avaliable',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w200,
                    fontSize: 20),):Text('Product Not Avaliable',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w200,
                    fontSize: 20),):Container(),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            //forblue colour
            isblue?Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 20,
                ),
                S_blue?ElevatedButton(onPressed: (){
                  selected_S_blue=true;
                  selected_L_blue=false;
                  selected_M_blue=false;
                  selected_XL_blue=false;
                  selected_XXL_blue=false;
                },
                    style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(selected_S_blue?Colors.blue[200]:Colors.grey[200]),
                    elevation: MaterialStatePropertyAll(10)
                    ),
                    child: Text('S',style: TextStyle(color: Colors.black),)):Container(),
                L_blue?ElevatedButton(onPressed: (){
                  setState(() {
                    selected_S_blue=false;
                    selected_L_blue=true;
                    selected_M_blue=false;
                    selected_XL_blue=false;
                    selected_XXL_blue=false;
                  });
                },
                    style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(selected_L_blue?Colors.blue[200]:Colors.grey[200]),
                        elevation: MaterialStatePropertyAll(10)
                    ),
                    child: Text('L',style: TextStyle(color: Colors.black),)):Container(),
                M_blue?ElevatedButton(onPressed: (){
                  setState(() {
                    selected_S_blue=false;
                    selected_L_blue=false;
                    selected_M_blue=true;
                    selected_XL_blue=false;
                    selected_XXL_blue=false;
                  });
                },
                    style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(selected_M_blue?Colors.blue[200]:Colors.grey[200]),
                        elevation: MaterialStatePropertyAll(10)
                    ),
                    child: Text('M',style: TextStyle(color: Colors.black),)):Container(),
                XL_blue?ElevatedButton(onPressed: (){
                  setState(() {
                    selected_S_blue=false;
                    selected_L_blue=false;
                    selected_M_blue=false;
                    selected_XL_blue=true;
                    selected_XXL_blue=false;
                  });
                },
                    style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(selected_XL_blue?Colors.blue[200]:Colors.grey[200]),
                        elevation: MaterialStatePropertyAll(10)
                    ),
                    child: Text('XL',style: TextStyle(color: Colors.black),)):Container(),
                XXL_blue?ElevatedButton(onPressed: (){
                  setState(() {
                    selected_S_blue=false;
                    selected_L_blue=false;
                    selected_M_blue=false;
                    selected_XL_blue=false;
                    selected_XXL_blue=true;
                  });
                },
                    style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(selected_XXL_blue?Colors.blue[200]:Colors.grey[200]),
                        elevation: MaterialStatePropertyAll(10)
                    ),
                    child: Text('XXL',style: TextStyle(color: Colors.black),)):Container(),
                SizedBox(
                  width: 20,
                )
              ],
            ):Container(),
            SizedBox(
              height: 20,
            ),
            isblue?Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                Text('Selected Size: ',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w200,fontSize: 20),),
                if(selected_S_blue)
                  Text('Small',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w200,fontSize: 20),),
                if(selected_L_blue)
                  Text('Large',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w200,fontSize: 20),),
                if(selected_M_blue)
                  Text('Medium',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w200,fontSize: 20),),
                if(selected_XL_blue)
                  Text('Xtra Large',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w200,fontSize: 20),),
                if(selected_XXL_blue)
                  Text('Xtra Xtra Large',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w200,fontSize: 20),),
              ],
            ):Container(),
            //for black colour
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                isblack?S_black||M_black||L_black||XL_black||XXL_black?Text('Sizes Avaliable',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w200,
                    fontSize: 20),):Text('Product Not Avaliable',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w200,
                    fontSize: 20),):Container(),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            isblack?Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 20,
                ),
                S_black?ElevatedButton(onPressed: (){
                  selected_S_black=true;
                  selected_L_black=false;
                  selected_M_black=false;
                  selected_XL_black=false;
                  selected_XXL_black=false;
                },
                    style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(selected_S_black?Colors.blue[200]:Colors.grey[200]),
                        elevation: MaterialStatePropertyAll(10)
                    ),
                    child: Text('S',style: TextStyle(color: Colors.black),)):Container(),
                L_black?ElevatedButton(onPressed: (){
                  setState(() {
                    selected_S_black=false;
                    selected_L_black=true;
                    selected_M_black=false;
                    selected_XL_black=false;
                    selected_XXL_black=false;
                  });
                },
                    style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(selected_L_black?Colors.blue[200]:Colors.grey[200]),
                        elevation: MaterialStatePropertyAll(10)
                    ),
                    child: Text('L',style: TextStyle(color: Colors.black),)):Container(),
                M_black?ElevatedButton(onPressed: (){
                  setState(() {
                    selected_S_black=false;
                    selected_L_black=false;
                    selected_M_black=true;
                    selected_XL_black=false;
                    selected_XXL_black=false;
                  });
                },
                    style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(selected_M_black?Colors.blue[200]:Colors.grey[200]),
                        elevation: MaterialStatePropertyAll(10)
                    ),
                    child: Text('M',style: TextStyle(color: Colors.black),)):Container(),
                XL_black?ElevatedButton(onPressed: (){
                  setState(() {
                    selected_S_black=false;
                    selected_L_black=false;
                    selected_M_black=false;
                    selected_XL_black=true;
                    selected_XXL_black=false;
                  });
                },
                    style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(selected_XL_black?Colors.blue[200]:Colors.grey[200]),
                        elevation: MaterialStatePropertyAll(10)
                    ),
                    child: Text('XL',style: TextStyle(color: Colors.black),)):Container(),
                XXL_black?ElevatedButton(onPressed: (){
                  setState(() {
                    selected_S_black=false;
                    selected_L_black=false;
                    selected_M_black=false;
                    selected_XL_black=false;
                    selected_XXL_black=true;
                  });
                },
                    style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(selected_XXL_black?Colors.blue[200]:Colors.grey[200]),
                        elevation: MaterialStatePropertyAll(10)
                    ),
                    child: Text('XXL',style: TextStyle(color: Colors.black),)):Container(),
                SizedBox(
                  width: 20,
                )
              ],
            ):Container(),
            SizedBox(
              height: 20,
            ),
            isblack?Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                Text('Selected Size: ',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w200,fontSize: 20),),
                if(selected_S_black)
                  Text('Small',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w200,fontSize: 20),),
                if(selected_L_black)
                  Text('Large',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w200,fontSize: 20),),
                if(selected_M_black)
                  Text('Medium',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w200,fontSize: 20),),
                if(selected_XL_black)
                  Text('Xtra Large',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w200,fontSize: 20),),
                if(selected_XXL_black)
                  Text('Xtra Xtra Large',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w200,fontSize: 20),),
              ],
            ):Container(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 20,),
                Text('Only a few left Hurry UP!',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            isblue ? IgnorePointer(
              ignoring: !(selected_S_blue || selected_L_blue || selected_M_blue || selected_XL_blue || selected_XXL_blue),
              child: ElevatedLayerButton(
                onClick: () async {
                  final user = _auth.currentUser;
                  String selectedSize = '';
                  if (selected_S_blue) {
                    selectedSize = 'S';
                  } else if (selected_L_blue) {
                    selectedSize = 'L';
                  } else if (selected_M_blue) {
                    selectedSize = 'M';
                  } else if (selected_XL_blue) {
                    selectedSize = 'XL';
                  } else if (selected_XXL_blue) {
                    selectedSize = 'XXL';
                  }
                  if (selectedSize.isNotEmpty) {
                    await _firestore.collection('Cart Items').doc(user!.uid).set({
                      'Items': FieldValue.arrayUnion([
                        {
                          'Item Photo':
                          'https://cdn-images.farfetch-contents.com/20/18/88/81/20188881_50824225_1000.jpg',
                          'Item Name': 'Zip-embellishment denim jacket',
                          'Colour': 'Blue',
                          'Price': 35000,
                          'Seller':'Off-White',
                          'Size': selectedSize,
                        }
                      ])
                    },SetOptions(merge: true));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added To Cart Succesfully',style: TextStyle(fontWeight: FontWeight.bold),),
                      duration: Duration(seconds: 5),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please Select a size',style: TextStyle(fontWeight: FontWeight.bold),),
                        duration: Duration(seconds: 5),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                buttonHeight: 60,
                buttonWidth: 270,
                animationDuration: const Duration(milliseconds: 200),
                animationCurve: Curves.ease,
                topDecoration: BoxDecoration(
                  color: Colors.amber,
                  border: Border.all(),
                ),
                topLayerChild: Text(
                  "Add to Cart Blue Colour",
                ),
                baseDecoration: BoxDecoration(
                  color: Colors.grey, // Change button color to grey when disabled
                  border: Border.all(),
                ),
              ),
            ) : Container(),
            isblack ? IgnorePointer(
              ignoring: !(selected_S_black || selected_L_black || selected_M_black || selected_XL_black || selected_XXL_black),
              child: ElevatedLayerButton(
                onClick: () async {
                  final user = _auth.currentUser;
                  String selectedSize = '';
                  if (selected_S_black) {
                    selectedSize = 'S';
                  } else if (selected_L_black) {
                    selectedSize = 'L';
                  } else if (selected_M_black) {
                    selectedSize = 'M';
                  } else if (selected_XL_black) {
                    selectedSize = 'XL';
                  } else if (selected_XXL_black) {
                    selectedSize = 'XXL';
                  }
                  if (selectedSize.isNotEmpty) {
                    await _firestore.collection('Cart Items').doc(user!.uid).set({
                      'Items': FieldValue.arrayUnion([
                        {
                          'Item Photo':
                          'https://cdn-images.farfetch-contents.com/20/73/46/94/20734694_51704700_1000.jpg',
                          'Item Name': 'Zip-embellishment denim jacket',
                          'Colour': 'Black',
                          'Price': 40000,
                          'Seller':'Off-White',
                          'Size': selectedSize,
                        }
                      ])
                    },SetOptions(merge: true));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added To Cart Succesfully',style: TextStyle(fontWeight: FontWeight.bold),),
                        duration: Duration(seconds: 5),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    // Handle case where no size is selected
                  }
                },
                buttonHeight: 60,
                buttonWidth: 270,
                animationDuration: const Duration(milliseconds: 200),
                animationCurve: Curves.ease,
                topDecoration: BoxDecoration(
                  color: Colors.amber,
                  border: Border.all(),
                ),
                topLayerChild: Text(
                  "Add to Cart Black Colour",
                ),
                baseDecoration: BoxDecoration(
                  color: Colors.grey, // Change button color to grey when disabled
                  border: Border.all(),
                ),
              ),
            ) : Container(),
            SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}
