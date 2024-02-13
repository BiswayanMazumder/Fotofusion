import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> itemPhotos = [];
  List<String> itemNames = [];
  List<String> colours = [];
  List<int> prices = [];
  List<String> sellers = [];
  List<String> sizes = [];
  List<DateTime> orderDates = [];
  bool isLoading = true;
  bool isloadingcancelled=true;
  List<String> status=[];
  List<String> delivered=[];
  List<String> Cancelleditemsize=[];
  List<String> Cancelleditemcolour=[];
  List<String> Cancelleditemname=[];
  List<String> Cancelleditemphoto=[];
  List<int> Cancelleditemprice=[];
  List<String>Cancelleditemseller=[];
  List<DateTime> Canceldate=[];
  List<String> cancelledstatus=[];
  Future<void> fetchcancelleddataperiodically() async{
    Timer.periodic(Duration(seconds:2 ), (timer) async{
      final user=_auth.currentUser;
      try{
        DocumentSnapshot documentSnapshot=await _firestore
        .collection('Cancelled Orders')
        .doc(user?.uid)
            .get();
        if(documentSnapshot.exists){
          dynamic data=documentSnapshot.data();
          if(data!=null){
            List<dynamic> posts = (data['Cancelled'] as List?) ?? [];
            setState(() {
              Cancelleditemphoto=posts.map((post) => post['Product Image'].toString()).toList();
              Cancelleditemname=posts.map((post) => post['Product Name'].toString()).toList();
              Canceldate=posts.map((post) => (post['Cancelled On'] as Timestamp).toDate()).toList();
              cancelledstatus=posts.map((post) => post['Status'].toString()).toList();
              Cancelleditemprice=posts.map((post) => int.parse(post['Price'].toString())).toList();
              Cancelleditemcolour=posts.map((post) => post['Colour'].toString()).toList();
              Cancelleditemseller=posts.map((post) => post['Seller'].toString()).toList();
              Cancelleditemsize=posts.map((post) => post['Size'].toString()).toList();
              isloadingcancelled=false;
            });
          }
        }
        print('Canc Item photos: $Cancelleditemphoto');
        print('Canc Item names: $Cancelleditemname');
        print('Canc Item colours: $Cancelleditemcolour');
        print(' Canc Item sellers: $Cancelleditemseller');
        print('Canc Item sizes: $Cancelleditemsize');
        print(' CancItem prices: $Cancelleditemprice');
        print(" Can Date $Canceldate");
        print(' Canc Status $cancelledstatus');
      }catch(e){
        print('Cancelled $e');
      }
    });
  }
  Future<void> fetchDataPeriodically() async {
    Timer.periodic(Duration(milliseconds: 50), (timer) async {
      final user = _auth.currentUser;

      try {
        DocumentSnapshot documentSnapshot = await _firestore
            .collection('Orders')
            .doc(user?.uid)
            .get();

        if (documentSnapshot.exists) {
          dynamic data = documentSnapshot.data();
          if (data != null) {
            List<dynamic> posts = (data['Orders'] as List?) ?? [];
            setState(() {
              itemPhotos = posts.map((post) => post['Product Image'].toString()).toList();
              itemNames = posts.map((post) => post['Product Name'].toString()).toList();
              colours = posts.map((post) => post['Product Colour'].toString()).toList();
              sellers = posts.map((post) => post['Product Seller'].toString()).toList();
              sizes = posts.map((post) => post['Product Size'].toString()).toList();
              orderDates = posts.map((post) => (post['Ordered On'] as Timestamp).toDate()).toList();
              prices = posts.map((post) => int.parse(post['Product Price'].toString())).toList();
              status = posts.map((post) => post['Status'].toString()).toList();
              delivered = posts.map((post) => post['isdelivered'].toString()).toList();
              isLoading = false; // Set loading to false once data is fetched
            });
          }
        }
        print('Item photos: $itemPhotos');
        print('Item names: $itemNames');
        print('Item colours: $colours');
        print('Item sellers: $sellers');
        print('Item sizes: $sizes');
        print('Item prices: $prices');
        print("Date $orderDates");
        print('is delivered $delivered');
        print('Status $status');

        // Call the function to calculate the total sum of prices
      } catch (e) {
        print('Error fetching data: $e');
      }
    });
  }
  List<String> filteredItemNames = [];
  void filterItemNames(String query) {
    setState(() {
      filteredItemNames = itemNames
          .where((itemName) => itemName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
  @override
  void initState() {
    super.initState();
    fetchDataPeriodically();
    fetchcancelleddataperiodically();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('My Orders'),
      ),
      body: isLoading&isloadingcancelled
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 20,
            ),
            for (int i = 0; i < itemPhotos.length; i++)
              InkWell(
                highlightColor: Colors.greenAccent,
                onTap: (){
                  print("tapped $i");
                },
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        Image.network(
                          itemPhotos[i],
                          width: 150,
                          height: 150,
                        ),
                        Column(
                          children: [
                            if(delivered[i]=='false') //false
                              Text(
                                'Ordered On ${DateFormat('dd MMM yyyy').format(orderDates[i])}',
                                // Formats the date to 'dd mm' (day month) format
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                            if(delivered[i]=='true')
                              Text(
                                'Delivered On ${DateFormat('dd MMM yyyy').format(orderDates[i])}',
                                // Formats the date to 'dd mm' (day month) format
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(itemNames[i], style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w300),),
                            SizedBox(
                              height: 5,
                            ),
                            Text('Product Price ₹${prices[i]}', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w300),),
                            SizedBox(
                              height: 5,
                            ),
                            if(delivered[i]=='true')
                              Text('Status: Delivered', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w300),),
                            if(delivered[i]=='false')
                              Text('Status:Ordered', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w300),),
                            if(delivered[i]=='true')
                              Container(),
                            if(delivered[i]=='false')
                              TextButton(
                                  onPressed: () async {
                                    showDialog(context: context, builder: (context) =>
                                      AlertDialog(
                                        backgroundColor: Colors.black,
                                        title: Text('Are you sure you want to cancel   ',style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),),
                                        actions: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              ElevatedButton(onPressed: ()async{
                                                final user = _auth.currentUser;
                                                await _firestore.collection('Cancelled Orders').doc(user!.uid).set(
                                                    {
                                                      'Cancelled':FieldValue.arrayUnion([
                                                        {
                                                          'Product Image':itemPhotos[i],
                                                          'Product Name':itemNames[i],
                                                          'Cancelled On':DateTime.now(),
                                                          'Status':'Cancelled',
                                                          'Price':prices[i],
                                                          'Colour':colours[i],
                                                          'Seller':sellers[i],
                                                          'Size':sizes[i]
                                                        }
                                                      ])
                                                    },SetOptions(merge: true));
                                                if (user != null) {
                                                  try {
                                                    // Get the reference to the document
                                                    DocumentReference orderRef = _firestore.collection('Orders').doc(user.uid);

                                                    // Fetch the current data
                                                    DocumentSnapshot snapshot = await orderRef.get();

                                                    // Check if the document exists and data is not null
                                                    if (snapshot.exists) {
                                                      // Get the orders list from the document data
                                                      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
                                                      if (data != null) {
                                                        List<dynamic> orders = data['Orders'] ?? [];

                                                        // Check if the index is valid
                                                        if (i >= 0 && i < orders.length) {
                                                          // Remove the order at the specified index
                                                          orders.removeAt(i);

                                                          // Update the Firestore document with the modified orders list
                                                          await orderRef.set({'Orders': orders});

                                                          // Remove the corresponding elements from the local lists
                                                          setState(() {
                                                            itemPhotos.removeAt(i);
                                                            itemNames.removeAt(i);
                                                            colours.removeAt(i);
                                                            sellers.removeAt(i);
                                                            sizes.removeAt(i);
                                                            orderDates.removeAt(i);
                                                            prices.removeAt(i);
                                                            status.removeAt(i);
                                                            delivered.removeAt(i);
                                                          });
                                                        }
                                                      }
                                                    }
                                                  } catch (e) {
                                                    print('Error removing order: $e');
                                                  }
                                                }
                                                Navigator.pop(context);
                                              },
                                                  style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.red)),
                                                  child: Text('Cancel Order',style: TextStyle(
                                                color: Colors.white
                                              ),)),
                                              ElevatedButton(onPressed: (){
                                                Navigator.pop(context);
                                              },
                                                  child: Text('Cancel',style: TextStyle(
                                                color: Colors.black
                                              ),),
                                              style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.green)),
                                              ),
                                            ],
                                          )
                                        ],
                                      )
                                    ,);
                                  },

                                  child: Text(
                                    'Cancel Order',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold
                                    ),
                                  )
                              )
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 40,
                    )
                  ],
                ),
              ),
            for(int j=0;j<Cancelleditemphoto.length;j++)
              Column(
                children: [
                  InkWell(
                    child:Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            Image.network(Cancelleditemphoto[j],width: 150,height: 150,),
                            Column(
                              children: [
                                Text(
                                  'Cancelled On ${DateFormat('dd MMM yyyy').format(Canceldate[j])}',
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(Cancelleditemname[j], style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w300),),
                                SizedBox(
                                  height: 5,
                                ),
                                Text('Product Price ₹${Cancelleditemprice[j]}', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w300),),
                                SizedBox(
                                  height: 5,
                                ),
                                Text('Status:${cancelledstatus[j]}', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w300),),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  )
                ],
              )
          ],
        ),
      ),
    );
  }
}
