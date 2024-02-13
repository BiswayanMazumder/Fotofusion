import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fotofusion/Shopping%20FotoFusion/Homepage%20Shopping/homepage_shopping.dart';
import 'package:fotofusion/Shopping%20FotoFusion/NavBar_shopping.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
class Checkout extends StatefulWidget {
  List<String> imageUrls=[];
  int Price;
  List<String> productname=[];
  List<String> Size=[];
  List<String> Seller=[];
  List<String> Colour=[];
  List<int> productprice=[];
  Checkout({required this.imageUrls,required this.Price,required this.productname,required this.Colour,required this.Size,required this.Seller,
  required this.productprice
  });

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchusername();
    print(widget.Seller);
    print(widget.Colour);
    print(widget.imageUrls);
    print(widget.Price);
    print(widget.Size);
    print(widget.productname);
  }
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
  TextEditingController _addressline1=TextEditingController();
  TextEditingController _addressline2=TextEditingController();
  TextEditingController _pincode=TextEditingController();
  TextEditingController _state=TextEditingController();
  TextEditingController _district=TextEditingController();
  TextEditingController _phonenumber=TextEditingController();
  TextEditingController _name=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Order Summary'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 20,
                      ),
                      Text('Deliver To:',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black,),
                        borderRadius: BorderRadius.circular(50)
                      ),
                      child: TextField(
                        controller: _name,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          hintText: '   Full Name- $username'
                        ),
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black,),
                          borderRadius: BorderRadius.circular(50)
                      ),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: _phonenumber,
                        decoration: InputDecoration(
                            hintText: '   Phone Number'
                        ),
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black,),
                          borderRadius: BorderRadius.circular(50)
                      ),
                      child: TextField(
                        controller: _addressline1,
                        decoration: InputDecoration(
                            hintText: '   Address Line-1'
                        ),
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black,),
                          borderRadius: BorderRadius.circular(50)
                      ),
                      child: TextField(
                        controller: _addressline2,
                        decoration: InputDecoration(
                            hintText: '   Address Line-2'
                        ),
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black,),
                          borderRadius: BorderRadius.circular(50)
                      ),
                      child: TextField(
                        keyboardType: TextInputType.numberWithOptions(),
                        controller: _pincode,
                        decoration: InputDecoration(
                            hintText: '   Pincode'
                        ),
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black,),
                          borderRadius: BorderRadius.circular(50)
                      ),
                      child: TextField(
                        controller: _district,
                        decoration: InputDecoration(
                            hintText: '   District'
                        ),
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black,),
                          borderRadius: BorderRadius.circular(50)
                      ),
                      child: TextField(
                        controller: _state,
                        decoration: InputDecoration(
                            hintText: '   State'
                        ),
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 20,
                      ),
                      Text('Check Your Order Before Procedding',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),)
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  for(int i=0;i<widget.imageUrls.length;i++)
                    Column(
                      children: [
                        Row(
                          children: [
                            Image.network(widget.imageUrls[i],
                              width: 150,
                              height: 150,
                            ),
                            Column(
                              children: [
                                Text(
                                  widget.productname[i],
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  'Seller ${widget.Seller[i]}',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  'Size ${widget.Size[i]}',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  'Colour ${widget.Colour[i]}',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14),
                                ),
                                Text(
                                  'Price ${widget.productprice[i]}',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        )
                      ],
                    ),

                ],
              ),

            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Text('Price to pay',style: TextStyle(fontWeight: FontWeight.bold),),
                  Spacer(),
                  Text('₹${widget.Price}',style: TextStyle(fontWeight: FontWeight.bold),),
                  SizedBox(
                    width: 20,
                  )
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if(_name.text.isNotEmpty && _phonenumber.text.isNotEmpty && _addressline1.text.isNotEmpty
                    &&_pincode.text.isNotEmpty && _district.text.isNotEmpty && _state.text.isNotEmpty){
                      Razorpay razorpay = Razorpay();
                      var options = {
                        'key': 'rzp_test_WoKAUdpbPOQlXA',
                        'amount': widget.Price*100, // amount in the smallest currency unit
                        'timeout': 300,
                        'name': 'FotoFusion',
                        'description': 'Payment for $username',
                        'theme': {
                          'color': '#FF0000',
                        },
                      };

                      razorpay.open(options);
                      razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) async{
                        print('Payment Success');
                        final user=_auth.currentUser;
                        await _firestore.collection('Address').doc(user!.uid).set({
                          'Orders':FieldValue.arrayUnion([
                            {
                              'user name':_name.text,
                              'Address Line 1':_addressline1.text,
                              'Address Line 2':_addressline2.text,
                              'Phone Number':_phonenumber.text,
                              'District':_district.text,
                              'State':_state.text,
                              'Ordered On':DateTime.now(),

                            }
                          ])
                        },SetOptions(merge: true));
                        try{
                          for(int i=0;i<widget.imageUrls.length;i++){
                            final user=_auth.currentUser;
                            await _firestore.collection('Orders').doc(user!.uid).set({
                              'Orders':FieldValue.arrayUnion([
                                {
                                  'Product Image':widget.imageUrls[i],
                                  'Product Name':widget.productname[i],
                                  'Product Price':widget.productprice[i],
                                  'Product Seller':widget.Seller[i],
                                  'Product Size':widget.Size[i],
                                  'Product Colour':widget.Colour[i],
                                  'Ordered On':DateTime.now(),
                                  'isdelivered':'false',
                                  'Status':'Ordered',
                                  'Delivered On':DateTime.now()
                                }
                              ])
                            },SetOptions(merge: true));
                          }
                        }catch(e){
                          print('Error in writing $e');
                        }
                      }
                      );

                      Navigator.push(context, MaterialPageRoute(builder: (context) => NavBar_shopping(),));
                    }
                    else{
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill all the fields',style: TextStyle(fontWeight: FontWeight.bold),),
                          duration: Duration(seconds: 5),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                  ),
                  child: Text(
                    'Proceed To Pay',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
