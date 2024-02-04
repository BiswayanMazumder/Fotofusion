import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  FirebaseFirestore _firestore=FirebaseFirestore.instance;
  FirebaseAuth _auth=FirebaseAuth.instance;
  int viewers=0;
  int followerscount=0;
  Future<void>fetchfollowerscount() async{
    final user=_auth.currentUser;
    final docsnap=await _firestore.collection('Followers Count').doc(user!.uid).get();
    if(docsnap.exists){
      setState(() {
        followerscount=docsnap.data()?['followers count'];
      });
    }
  }
  Future<void> fetchaccountviewers()async{
    final user=_auth.currentUser;
    final docsnap=await _firestore.collection('Account Viewers').doc(user!.uid).get();
    if(docsnap.exists){
      setState(() {
        viewers=docsnap.data()?['Viewers'];
      });
    }
  }
  int following=0;
  Future<void> fetchfollowing() async{
    final user=_auth.currentUser;
    final docsnap=await _firestore.collection('Users Followers Count').doc(user!.uid).get();
    if(docsnap.exists){
      setState(() {
        following=docsnap.data()?['followers count'];
      });
    }
  }
  int interaction=0;
  Future<void> fetchinteraction() async{
    final user=_auth.currentUser;
    final docsnap=await _firestore.collection('Account Interaction').doc(user!.uid).get();
    if(docsnap.exists){
      interaction=docsnap.data()?['Interaction'];
    }
  }
  Future<void> updateImagesPeriodically() async {
    while (true) {
      await Future.delayed(Duration(seconds: 2));
      fetchaccountviewers();
      fetchfollowerscount();
      fetchfollowing();
      fetchinteraction();
      fetchData();
    }
  }
  List<String> countryNames=[];
  Future<void> fetchData() async {
    final user = _auth.currentUser;
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await FirebaseFirestore.instance
          .collection('Country Name')
          .doc(user!.uid)
          .get();

      if (documentSnapshot.exists) {
        List<dynamic> data = documentSnapshot.data()?['country'] ?? [];
        countryNames = List<String>.from(data);
        setState(() {}); // Trigger a rebuild to update the UI
      }
      print('countries $countryNames');
    } catch (e) {
      print("Error fetching data: $e");
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateImagesPeriodically();
    fetchData();
    fetchaccountviewers();
    fetchfollowerscount();
    fetchfollowing();
    fetchinteraction();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(CupertinoIcons.back,color: CupertinoColors.white,)),
        title: Text('Professional dashboard',style: TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
      body:SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            Row(
              children: [
                SizedBox(
                  width: 15,
                ),
                Text('Insights',style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),),
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
                Text('Account reached',style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.w300),),
                SizedBox(
                  width: 185,
                ),
                if(viewers==0)
                  Text('None',style: TextStyle(color: Colors.white,
                      fontWeight: FontWeight.w300,
                      fontSize: 15
                  ),),
                if(viewers==1)
                  Text('$viewers',style: TextStyle(color: Colors.white,
                      fontWeight: FontWeight.w300,
                      fontSize: 15
                  ),),
                if(viewers>1)
                  Text('$viewers',style: TextStyle(color: Colors.white,
                      fontWeight: FontWeight.w300,
                      fontSize: 15
                  ),),
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
                Text('Account engaged',style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.w300),),
                SizedBox(
                  width: 180,
                ),
                if(interaction==0)
                  Text('None',style: TextStyle(color: Colors.white,
                      fontWeight: FontWeight.w300,
                      fontSize: 15
                  ),),
                if(interaction==1)
                  Row(
                    children: [
                      Text('${(interaction).toString()}',style: TextStyle(color: Colors.white,
                          fontWeight: FontWeight.w300,
                          fontSize: 15
                      ),),
                      Icon(CupertinoIcons.down_arrow,color: Colors.white,)
                    ],
                  ),
                if(interaction>1)

                      Column(
                        children: [
                          Row(
                            children: [
                              Text('${interaction}',style: TextStyle(color: Colors.white,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 15
                              ),),
                              Icon(CupertinoIcons.down_arrow,color: Colors.white,size: 16,),
                            ],
                          ),
                          Text('16.2%',style: TextStyle(color: Colors.white,
                              fontWeight: FontWeight.w100,
                              fontSize: 12
                          ),),
                        ],
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
                Text('Total Followers',style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.w300),),
                SizedBox(
                  width: 200,
                ),
                Text('$followerscount',style: TextStyle(color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontSize: 15
                ),)
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
                Text('Total Following',style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.w300),),
                SizedBox(
                  width: 200,
                ),
                Text('$following',style: TextStyle(color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontSize: 15
                ),)
              ],
            ),
            SizedBox(
              height: 50,
            ),
            Divider(
              color: Colors.white,
              thickness: 0.5,
              indent: 100,
              endIndent: 100,
            ),
            SizedBox(
              height: 30,
            ),
            Center(
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Text('Countries your account is mostly engaged',style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.w400),),
                ],
              ),
            ),
            Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                for (int i = 0; i < countryNames.length; i++)
                  Column(
                    children: [
                      if (i > 0) // Add gap starting from the second index
                        SizedBox(
                          height: 20,
                        ),
                      Row(
                        children: [
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            countryNames[i],
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w300),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
