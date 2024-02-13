import 'package:fotofusion/Shopping%20FotoFusion/checkout.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Cart_page extends StatefulWidget {
  const Cart_page({Key? key}) : super(key: key);

  @override
  State<Cart_page> createState() => _Cart_pageState();
}

class _Cart_pageState extends State<Cart_page> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> Itemphotos = [];
  List<String> Itemname = [];
  List<String> Colour = [];
  List<int> Price = [];
  List<String> Seller = [];
  List<String> Size = [];
  int sumofprice = 0;
  bool isloading=true;
  // Function to calculate the total sum of prices
  bool ischeckout=true;
  void calculateSumOfPrices() {
    setState(() {
      sumofprice = Price.fold(0, (previousValue, element) => previousValue + element);
      if(sumofprice==0){
        ischeckout=false;
      }
    });
  }

  Future<void> fetchData() async {
    final user = _auth.currentUser;

    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('Cart Items')
          .doc(user?.uid)
          .get();

      if (documentSnapshot.exists) {
        dynamic data = documentSnapshot.data();
        if (data != null) {
          List<dynamic> posts = (data['Items'] as List?) ?? [];
          setState(() {
            Itemphotos = posts.map((post) => post['Item Photo'].toString()).toList();
            Itemname = posts.map((post) => post['Item Name'].toString()).toList();
            Colour = posts.map((post) => post['Colour'].toString()).toList();
            Seller = posts.map((post) => post['Seller'].toString()).toList();
            Size = posts.map((post) => post['Size'].toString()).toList();
            Price = posts.map((post) => int.parse(post['Price'].toString())).toList();
            isloading=false;
          });
        }
      }
      print('Item photos: $Itemphotos');
      print('Item names: $Itemname');
      print('Item colours: $Colour');
      print('Item sellers: $Seller');
      print('Item sizes: $Size');
      print('Item prices: $Price');

      // Call the function to calculate the total sum of prices
      calculateSumOfPrices();
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> deleteItem(int index) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        // Remove the item from Firestore document
        await _firestore.collection('Cart Items').doc(user.uid).update({
          'Items': FieldValue.arrayRemove([
            // Create a map representing the item to be removed
            {
              'Item Photo': Itemphotos[index],
              'Item Name': Itemname[index],
              'Colour': Colour[index],
              'Price': Price[index],
              'Seller': Seller[index],
              'Size': Size[index],
            }
          ])
        });

        // Update the UI by removing the item details at the specific index (i)
        setState(() {
          Itemphotos.removeAt(index);
          Itemname.removeAt(index);
          Colour.removeAt(index);
          Price.removeAt(index);
          Seller.removeAt(index);
          Size.removeAt(index);
          // Recalculate the total sum of prices
          calculateSumOfPrices();
        });
      } catch (e) {
        print('Error deleting item: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'My Cart',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: isloading?Center(child: CircularProgressIndicator()) :Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  for (int i = 0; i < Itemphotos.length; i++)
                    Column(
                      children: [
                        Row(
                          children: [
                            Image.network(
                              Itemphotos[i],
                              height: 150,
                              width: 150,
                            ),
                            Column(
                              children: [
                                Text(
                                  Itemname[i],
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  'Seller ${Seller[i]}',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  'Size ${Size[i]}',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  'Colour ${Colour[i]}',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  'Price - ₹${Price[i]}',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15),
                                ),
                                TextButton(
                                  onPressed: () {
                                    deleteItem(i);
                                  },
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                          height: 50,
                        )
                      ],
                    ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 30,
                    ),
                    Text(
                      'Total',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey),
                    ),
                    Spacer(),
                    Text(
                      '₹$sumofprice',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 30,
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ischeckout?Navigator.push(context, MaterialPageRoute(builder: (context) => Checkout(imageUrls: Itemphotos,
                        Price: sumofprice,
                        productname: Itemname,
                        Colour: Colour,
                        Size: Size,
                        Seller: Seller,
                        productprice:Price,
                      ),)):Container();
                    },
                    style: ButtonStyle(
                      backgroundColor: ischeckout?MaterialStateProperty.all(Colors.blue):MaterialStatePropertyAll(Colors.grey),
                    ),
                    child: Text(
                      'Check out',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
