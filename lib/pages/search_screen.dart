import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fotofusion/Searches/search_result.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController _searchController = TextEditingController();
  bool isShowUser = false;
  List<String> imageUrls = [];
  List<String> captions = [];
  List<String> usernames = [];
  List<String> profilePhotos = [];
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> fetchImages() async {
    final user = _auth.currentUser;

    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('All posts')
          .doc('Global Post')
          .get();

      if (documentSnapshot.exists) {
        dynamic data = documentSnapshot.data();
        if (data != null) {
          List<dynamic> posts = (data['posts'] as List?) ?? [];
          setState(() {
            imageUrls =
                posts.map((post) => post['imageUrl'].toString()).toList();
          });
        }
      }
    } catch (e) {
      print('Error fetching images: $e');
    }
  }

  Future<void> updateImagesPeriodically() async {
    while (true) {
      await Future.delayed(Duration(seconds: 2));
      fetchImages();
    }
  }

  @override
  void initState() {
    super.initState();
    updateImagesPeriodically();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
          ),
          child: Column(
            children: [
              TextFormField(
                style: TextStyle(color: Colors.white),
                controller: _searchController,
                decoration: InputDecoration(
                    hintText: 'Search Users',
                    prefixIcon: Icon(Icons.search, color: Colors.white),
                    filled: true,
                    fillColor: Colors.grey[700]!,
                    hintStyle: TextStyle(color: Colors.white)),
                onFieldSubmitted: (String _) {
                  print(_);
                  setState(() {
                    isShowUser = true;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      body: isShowUser
          ? FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('User Details')
            .where('user name',
            isGreaterThanOrEqualTo: _searchController.text)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          return ListView.builder(
            itemCount: (snapshot.data! as dynamic).docs.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                      (snapshot.data! as dynamic).docs[index]['url_user1']),
                ),
                title: Text(
                  (snapshot.data! as dynamic).docs[index]['user names'],
                  style: TextStyle(color: Colors.white),
                ),
                trailing: TextButton(onPressed: (){
                  String userId =
                      (snapshot.data! as dynamic).docs[index].id;
                  print('User ID: $userId');
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Searchresult(userid: userId),));
                }, child: Text('View Profile',style: TextStyle(
                  color: Colors.purple,fontWeight: FontWeight.bold
                ),))
              );
            },
          );
        },
      )
          : // Display images in a 3x3 grid
      GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.network(
              imageUrls[index],
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}
