import 'dart:io';
import 'package:fotofusion/Chatbots/chatbot.dart';
import 'package:fotofusion/account%20page/comment_page.dart';
import 'package:fotofusion/pages/homepage.dart';
import 'package:fotofusion/pages/report_page.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'package:all_vibrate/all_vibrate.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shake/shake.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<String> imageUrls = [];
  List<String> captions = [];
  List<String> usernames = [];
  List<String> profilephotos = [];
  List<List<String>> likedUsers = [];
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int numberOfPosts = 0;
  bool isLoading = false;
  String location = '';
  bool isverified = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // You can also perform initialization here based on inherited widgets
  }

  Future<void> showVerification() async {
    final user = _auth.currentUser;

    if (user != null && user.emailVerified == false) {
      setState(() {
        isverified = false;
      });

      if (!isverified) {
        // Show dialog on screen
        showDialog(
          context: context, // Make sure to have access to the context
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Verification Required'),
              content: Text('Please verify your email to proceed.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
    print('isverified $isverified');
  }
  String? storyurl;
  bool storyuploaded=false;
  Future<void> _loadstory()async{
    final user=_auth.currentUser;
    try{
      final docsnap=await _firestore.collection('Story').doc(user!.uid).get();
      if(docsnap.exists){
        storyurl=docsnap.data()?['story'];
        storyuploaded=true;
      }
    }catch(e){
      print("Error getting story: $e");
    }
  }
  String? _imageUrl;
  Future<void> _loadProfilePicture() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final docSnapshot =
        await _firestore.collection('profile_pictures').doc(user.uid).get();
        if (docSnapshot.exists) {
          setState(() {
            _imageUrl = docSnapshot.data()?['url_user1'];
          });
        }
      } catch (e) {
        print('Error loading profile picture: $e');
      }
    }
  }
  Future<void> writestoryseen() async{
    final user=_auth.currentUser;
    await _firestore.collection('Story').doc(user!.uid).update(
        {
          'story seen':true
        });
  }
  bool storyseen=false;
  Future<void> fetchstoryseen()async{
    final user=_auth.currentUser;
    final docsnap=await _firestore.collection('Story').doc(user!.uid).get();
    if(docsnap.exists){
      storyseen=docsnap.data()?['story seen'];
    }
    print('Story seen $storyseen');
  }
  final screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    initializeNumberOfPosts();
    initializeLikedUsersList();
    updateImagesPeriodically();
    fetchverifications();
    fetchstoryseen();
    _loadstory();
    fetchprofilephoto();
    fetchusername();
    final vibrate = AllVibrate();
    showVerification();
    ShakeDetector detector = ShakeDetector.autoStart(
        onPhoneShake: () {
          vibrate.simpleVibrate(period: 1500, amplitude: 200);
          showDialog(context: context, builder:(context) {
            return AlertDialog(
              backgroundColor: Colors.black,
              title: Center(
                child: Text('Shake To Report',style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                ),),
              ),
              scrollable: true,
              actions: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => BugReportPage()));

                      },
                          style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(Colors.grey[900])
                          ),
                          child: Text('Report a Bug',style: TextStyle(color: Colors.white,
                              fontWeight: FontWeight.bold
                          ),)),
                      SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(onPressed: (){

                      },
                          style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(Colors.grey[900])
                          ),
                          child: Text('Make a Suggestion',style: TextStyle(color: Colors.white,
                              fontWeight: FontWeight.bold
                          ),)),
                      SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(onPressed: (){
                      },
                          style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(Colors.grey[900])
                          ),
                          child: Text('Turn Off',style: TextStyle(color: Colors.white,
                              fontWeight: FontWeight.bold
                          ),)),
                      SizedBox(
                        height: 20,
                      ),
                      TextButton(onPressed: (){
                        Navigator.pop(context);
                      },
                          child: Text('Cancel',style: TextStyle(color: Colors.grey,
                              fontWeight: FontWeight.bold
                          ),))
                    ],
                  ),
                )
              ],
            );
          }, );
        }
    );
  }


  List<String> locations = [];
  List<String> verification=[];
  Future<void> fetchverifications() async {
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
            verification = posts
                .map((post) => post['Verification'].toString())
                .toList();
          });
        }
      }
    } catch (e) {
      print('Error fetching profile photo: $e');
    }
  }
  Future<void> initializeNumberOfPosts() async {
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
            numberOfPosts = posts.length;
          });
        }
      }
    } catch (e) {
      print('Error initializing numberOfPosts: $e');
    }
  }

  Future<void> initializeLikedUsersList() async {
    setState(() {
      likedUsers = List.generate(numberOfPosts, (index) => []);
    });
  }
  String? username;
  Future<void> fetchusername() async {
    final user = _auth.currentUser;
    try {
      final docsnap =
      await _firestore.collection('User Details').doc(user!.uid).get();
      if (docsnap.exists) {
        setState(() {
          username = docsnap.data()?['user name'];
        });
      }
    } catch (e) {
      print(e);
    }
  }
  Future<void> updateImagesPeriodically() async {
    while (true) {
      await Future.delayed(Duration(seconds: 2));
      await fetchprofilephoto();
      await fetchusernames();
      await fetchImages();
      await fetchcaptions();
      await fetchInitialLikeStatus();
      await fetchlocations();
      await fetchverifications();
      await fetchstoryseen();
      await fetchusername();
    }
  }
  bool _uploading = false;
  Future<void> fetchInitialLikeStatus() async {
    try {
      final String currentUserUid = _auth.currentUser?.uid ?? '';

      List<List<String>> initialLikedUsers = await Future.wait(
        List.generate(min(numberOfPosts, imageUrls.length), (index) async {
          DocumentSnapshot postDoc =
          await _firestore.collection('All posts').doc('post$index').get();
          Map<String, dynamic> postData =
              postDoc.data() as Map<String, dynamic>? ?? {};
          List<dynamic>? existingLikedUsersDynamic = postData['likedUsers'];
          return existingLikedUsersDynamic?.cast<String>() ?? [];
        }),
      );

      setState(() {
        likedUsers = initialLikedUsers;
      });
    } catch (e) {
      print('Error fetching initial like status: $e');
    }
  }

  Future<void> fetchprofilephoto() async {
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
            profilephotos = posts
                .map((post) => post['profile photo'].toString())
                .toList();
          });
        }
      }
    } catch (e) {
      print('Error fetching profile photo: $e');
    }
  }

  Future<void> fetchlocations() async {
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
            locations = posts
                .map((post) => post['location'].toString())
                .toList();
          });
        }
      }
    } catch (e) {
      print('Error fetching profile photo: $e');
    }
  }

  Future<void> fetchusernames() async {
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
            usernames =
                posts.map((post) => post['username'].toString()).toList();
          });
        }
      }
    } catch (e) {
      print('Error fetching usernames: $e');
    }
  }

  Future<void> fetchcaptions() async {
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
            captions = posts.map((post) => post['caption'].toString()).toList();
          });
        }
      }
    } catch (e) {
      print('Error fetching captions: $e');
    }
  }

  Future<void> fetchImages() async {
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
            isLoading = true;
          });
        }
      }
    } catch (e) {
      print('Error fetching images: $e');
    }
  }

  Future<void> updateFirestoreLikedUsers(
      int index, List<String> newLikedUsers) async {
    final String currentUserUid = _auth.currentUser?.uid ?? '';
    try {
      CollectionReference allPostsCollection =
      FirebaseFirestore.instance.collection('All posts');
      DocumentReference postDocRef = allPostsCollection.doc('post$index');
      DocumentSnapshot postDoc = await postDocRef.get();
      Map<String, dynamic> postData =
          postDoc.data() as Map<String, dynamic>? ?? {};
      List<dynamic>? existingLikedUsersDynamic = postData['likedUsers'];
      List<String> existingLikedUsers =
          existingLikedUsersDynamic?.cast<String>() ?? [];
      bool userLiked = existingLikedUsers.contains(currentUserUid);

      if (userLiked) {
        existingLikedUsers.remove(currentUserUid);
      } else {
        existingLikedUsers.add(currentUserUid);
      }

      postData['likedUsers'] = existingLikedUsers;
      await postDocRef.set(postData);

      // Fetch the updated likedUsers count
      int likedUsersCount = existingLikedUsers.length;

      // Update UI with the likedUsers count
      updateUIWithLikedUsersCount(index, likedUsersCount);

      print('Firestore update successful');
    } catch (e) {
      print('Error updating Firestore: $e');
    }
  }

  void updateUIWithLikedUsersCount(int index, int count) {
    setState(() {
      likedUsers[index] = likedUsers[index] ?? [];
      likedUsers[index].length = count;
    });
  }

  Future<void> ShowDialogue() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.green,
          title: Text(
            'Please verify yourself',
            style:
            TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserUid = _auth.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => support_sections()),
          );
        },
        backgroundColor: Colors.purple,
        child: Icon(Icons.question_mark, color: Colors.white),
      ),
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: Text(
          '𝕱𝖔𝖙𝖔𝕱𝖚𝖘𝖎𝖔𝖓',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                InkWell(
                  onTap: () async {
                    writestoryseen();
                    if (storyurl != null) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: Colors.black,
                            actions: [
                              InstaImageViewer(
                                child: Image(
                                  image: storyurl != null
                                      ? Image.network(storyurl!).image
                                      : AssetImage('assets/placeholder_image.png'), // Replace with your placeholder image
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: _uploading
                      ? CircularProgressIndicator(
                    color: Colors.red,
                  )
                      : _imageUrl == null
                      ? Column(
                    children: [
                      ClipOval(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                          ),
                          child: Image.network(
                            'https://firebasestorage.googleapis.com/v0/'
                                'b/fotofusion-53943.appspot.com/o/profile%2'
                                '0pics.jpg?alt=media&token=17bc6fff-cfe9-4f2d-9'
                                'a8c-18d2a5636671',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        username ?? '',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                          fontSize: 12,
                        ),
                      )
                    ],
                  )
                      : Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: (storyuploaded && !storyseen)
                            ? Colors.green
                            : (storyuploaded && storyseen)
                            ? Colors.grey
                            : Colors.red,
                        width: 3,
                      ),
                    ),
                    child: Column(
                      children: [
                        ClipOval(
                          child: _imageUrl != null
                              ? Image.network(
                            _imageUrl!,
                            fit: BoxFit.cover,
                          )
                              : CircularProgressIndicator(color: Colors.white,) // Handle the case when _imageUrl is null
                        ),
                      ],
                    ),
                  ),
                ),

              ],
            ),
            SizedBox(
              height: 20,
            ),
            Column(
              children: List.generate(
                min(numberOfPosts, likedUsers.length),
                    (index) {
                  return Column(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 20,
                              ),
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.black,
                                child: Image.network(
                                  profilephotos[index],
                                  height: 50,
                                  width: 50,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                usernames[index],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              if (verification.isNotEmpty && verification[index] == 'true')
                                Image.network(
                                  'https://emkldzxxityxmjkxiggw.supabase.co/storage/v1/object/public/Grovito/480-4801090_instagram-verified-badge-png-instagram-verified-icon-png-removebg-preview.png',
                                  height: 30,
                                  width: 30,
                                ),
                            ],
                          ),
                          if (locations.isNotEmpty)
                            Row(
                              children: [
                                SizedBox(
                                  width: 70,
                                ),
                                Text(
                                  locations[index],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),

                      SizedBox(height: 10),
                      Image.network(
                        imageUrls[index],
                        height: 600,
                        width: 600,
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          SizedBox(width: 10),
                          Text(
                            usernames[index],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            captions[index],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          IconButton(
                            onPressed: () async {
                              List<String> currentLikedUsers =
                              likedUsers[index];
                              final bool userLiked =
                              currentLikedUsers.contains(currentUserUid);

                              if (userLiked) {
                                currentLikedUsers.remove(currentUserUid);
                              } else {
                                currentLikedUsers.add(currentUserUid);
                              }

                              await updateFirestoreLikedUsers(
                                  index, currentLikedUsers);
                            },
                            icon: likedUsers[index].contains(currentUserUid)
                                ? Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 30,
                            )
                                : Icon(
                              Icons.favorite_border,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),

                          if (likedUsers[index]?.length == 1)
                            Text(
                              '${likedUsers[index]?.length ?? 0} Like',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          if (likedUsers[index].length > 1)
                            Text(
                              '${likedUsers[index]?.length ?? 0} Likes',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          SizedBox(
                            width: 10,
                          ),
                          IconButton(onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Comment_page(startIndex: index)));
                            print('Index is $index');
                          },
                              icon: Icon(Icons.comment_outlined,color: Colors.white))
                        ],
                      ),
                      SizedBox(height: 30),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void takeScreenshot(BuildContext context) async {
    final imageFile = await screenshotController.capture();
    print('Screenshot taken');

    // Convert Uint8List to File
    final tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path;
    final File file = await File('$tempPath/screenshot.png').writeAsBytes(imageFile!);

    // Navigate to the next page with the captured screenshot
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BugReportPage(imageFile: file),
      ),
    );
  }

}

