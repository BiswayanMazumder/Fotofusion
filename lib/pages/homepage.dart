import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:fotofusion/Shopping%20FotoFusion/Homepage%20Shopping/homepage_shopping.dart';
import 'package:fotofusion/Shopping%20FotoFusion/NavBar_shopping.dart';
import 'package:http/http.dart' as http;
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:fotofusion/Chatbots/chatbot.dart';
import 'package:fotofusion/Notifications/notifications.dart';
import 'package:fotofusion/Searches/search_result.dart';
import 'package:fotofusion/account%20page/comment_page.dart';
import 'package:fotofusion/messages/messaging_page.dart';
import 'package:fotofusion/pages/homepage.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
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
import 'package:shimmer_image/shimmer_image.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
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
  List<String> usernamess = [];
  List<bool> verificationStatuses = [];
  List<String> profileurls=[];
  Future<void> fetchAllUserIds() async {
    final user=_auth.currentUser;
    try {
      final snapshot = await _firestore.collection('Story Seen').doc(user!.uid).get();

      if (snapshot.exists) {
        List<String> userIds = [];
        final seenData = snapshot.data()?['Seen'];

        if (seenData is List) {
          for (var userMap in seenData) {
            if (userMap is Map && userMap.containsKey('user id')) {
              String userId = userMap['user id'];
              userIds.add(userId);
            }
          }
        }
        fetchUserDetails(userIds);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchUserDetails(List<String> userIds) async {
    for (String userId in userIds) {
      try {
        // Fetch username
        final usernameDoc =
        await _firestore.collection('User Details').doc(userId).get();
        if (usernameDoc.exists) {
          setState(() {
            String username = usernameDoc.data()?['user names'] ?? '';
            usernamess.add(username);
          });
        }
        //fetch profile picture
        final profilepicdoc =
        await _firestore.collection('profile_pictures').doc(userId).get();
        if (profilepicdoc.exists) {
          setState(() {
            String urls = profilepicdoc.data()?['url_user1'] ?? '';
            profileurls.add(urls);
          });
        }
        else{
          setState(() {
            profileurls.add('https://images.pexels.com/photos/19861151/pexels-photo-1986115'
                '1/free-photo-of-a-mountain-stream-is-flowing-through-a-forest.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1');
          });
        }
        // Fetch verification status
        final verificationDoc =
        await _firestore.collection('Verifications').doc(userId).get();
        if (verificationDoc.exists) {
          setState(() {
            bool isVerified = verificationDoc.data()?['isverified'] ?? false;
            verificationStatuses.add(isVerified);
          });
        }
        print('usernames length: ${usernames.length}');
        print('verificationStatuses length: ${verificationStatuses.length}');
        print('profileurls length: ${profileurls.length}');

      } catch (e) {
        print(e);
      }
    }
    // After fetching all data, trigger a UI update
    setState(() {});
  }
  List<String> documentNames = [];
  List<String> fetchedUsernames = [];

  Future<List<String>> getusernames() async {
    try {
      for (String userId in documentNames) {
        print('Fetching user with ID: $userId');
        DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('User Details').doc(userId).get();

        if (userSnapshot.exists) {
          setState(() {
            String username = userSnapshot['user name'];
            fetchedUsernames.add(username);
          });
        } else {
          // Handle the case where the user document doesn't exist
          fetchedUsernames.add('User not found for ID: $userId');
        }
      }

      return fetchedUsernames;
    } catch (e) {
      print('Error fetching usernames: $e');
      return fetchedUsernames; // or throw an exception if needed
    }
  }
  List<String> usernamearray = [];
  List<String> userverifications=[];
  List<bool> verifs=[];

  Future<List<String>> getStoryUsernames() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Story').get();

      for (QueryDocumentSnapshot collectionSnapshot in querySnapshot.docs) {
        String documentName = collectionSnapshot.id;

        if (documentName != null) {
          documentNames.add(documentName);
        }
      }
      print('document names $documentNames');
    } catch (e) {
      // Handle errors, e.g., Firestore not reachable
      print('Error retrieving document names: $e');
    }

    print(documentNames);



    // Fetch usernames based on user IDs
    for (String userId in documentNames) {
      try {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('User Details').doc(userId).get();

        if (userSnapshot.exists) {
          String username = userSnapshot.get('user name');
          if (username != null) {
            usernamearray.add(username);
          }
        }
      } catch (e) {
        // Handle errors while fetching user details
        print('Error retrieving username for user ID $userId: $e');
      }
    }
    //fetch verifications
    for (String userId in documentNames) {
      try {
        DocumentSnapshot userSnapshots = await FirebaseFirestore.instance.collection('Verifications').doc(userId).get();

        if (userSnapshots.exists) {
          bool verif = userSnapshots.get('isverified');
          if (verif != null) {
            verifs.add(verif);
          }
        }
      } catch (e) {
        // Handle errors while fetching user details
        print('Error retrieving username for user ID $userId: $e');
      }
    }
    print(verifs);
    print(usernamearray);
    return usernames;
  }
  List<Map<String, dynamic>> allDocs = [];

  Future<void> fetchStories() async {
    try {
      // Fetch documents from the 'Story' collection
      QuerySnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('Story').get();

      // Initialize an empty list to store story links
      List<String> links = [];

      // Iterate through the documents in the snapshot
      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
        // Access the data from each document
        Map<String, dynamic> docData = doc.data();

        // Add the document data to the list of all documents
        allDocs.add(docData);

        // Access the 'story' field using the null-aware operator
        String storyLink = docData['story'] ?? '';

        // Add the story link to the list
        links.add(storyLink);
      }

      // Update the state with the list of story links
      setState(() {
        storyLinks = links;
      });
      likedstory = List.filled(storyLinks.length, false);
      print('is liked $likedstory');
    } catch (e) {
      // Handle any errors that occur during the process
      print('Error fetching stories: $e');
    }
  }
  List<String>bodystoryurl=[];
  List<bool> havestory=[];
  Future<void> dpstoryurl() async{
    await fetchuids();
    for(String Uids in uids)
    {
      try{
        final docsnap=await _firestore.collection('Story').doc(Uids).get();
        if(docsnap.exists){
          setState(() {
            String urls=docsnap.data()?['story'];
            bodystoryurl.add(urls);
            havestory.add(true);
          });
        }else{
          havestory.add(false);
        }
        print('body story $bodystoryurl ,  length ${bodystoryurl.length}');
        print('body story uploaded $havestory');
      }catch(e){
        print('error in body story $e');
      }
    }
  }
  List<String> uids=[];
  Future<void> fetchuids() async {
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
            uids =
                posts.map((post) => post['uid'].toString()).toList();
          });
        }
      }
      print('Uids $uids');
    } catch (e) {
      print('Error fetching uid: $e');
    }
  }
  List<bool> isverifiedd=[];
  List<String> usernamesss=[];
  Future<void> fetchusernamereal() async{
    await fetchuids();
    for(String Uid in uids){
      final docsnap=await _firestore.collection('User Details').doc(Uid).get();
      if(docsnap.exists){
        setState(() {
          String names=docsnap.data()?['user name'];
          usernamesss.add(names);
        });
      }
      final docs=await _firestore.collection('Verifications').doc(Uid).get();
      if(docs.exists){
        setState(() {
          bool verified=docs.data()?['isverified'];
          isverifiedd.add(verified);
        });
      }
      else{
        isverifiedd.add(false);
      }
    }
    print('fetched names $usernamesss  ,   verified $isverifiedd');
  }
  List<String> followers=[];
  List<String> follow=[];
  Future<void> fetchfollowers() async {
    await fetchuids();
    final user = _auth.currentUser;

    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('Following')
          .doc(user?.uid)
          .get();

      if (documentSnapshot.exists) {
        dynamic data = documentSnapshot.data();
        if (data != null) {
          List<dynamic> posts = (data['Followers'] as List?) ?? [];
          setState(() {
            followers =
                posts.map((post) => post['followerUid'].toString()).toList();
          });
        }
      }
      print('Uid $uids ${uids.length}'); //8
      print('followers $followers ${followers.length}'); //3
      for (int i = 0; i < uids.length; i++) {
        if (uids[i] == user?.uid ) {
          follow.add('True');
        }
        else if(followers.contains(uids[i])){
          follow.add('true');
        }
        else {
          follow.add('false');
        }
      }

      print('follow true/false $follow ${follow.length}');
    } catch (e) {
      print('Error fetching followers: $e');
    }
  }
  Future<void>fetchipaddress() async{
    final response = await http.get(Uri.parse('https://ipinfo.io/json'));
    if(response.statusCode==200){
      Map<String, dynamic> data = json.decode(response.body);
      String ip = data['ip'];
      final user=_auth.currentUser;
      await _firestore.collection('User IP').doc(user!.uid).set({
        'IP Address':FieldValue.arrayUnion([
          ip
        ])
      }, SetOptions(merge: true));
    }
  }
  @override
  void initState() {
    super.initState();
    fetchfollowers();
    fetchipaddress();
    fetchuids();
    dpstoryurl();
    fetchusernamereal();
    fetchprofilephotostory();
    initializeNumberOfPosts();
    fetchusernameofuser();
    fetchStories();
    fetchLikedUids();
    initializeLikedUsersList();
    updateImagesPeriodically();
    fetchverifications();
    getusernames();
    fetchstoryseen();
    _loadstory();
    fetchprofilephoto();
    fetchusername();
    fetchAllUserIds();
    final vibrate = AllVibrate();
    showVerification();
    fetchStories();
    getStoryUsernames();
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
      await fetchStories();
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
  List<String> storydp=[];
  Future<void> fetchprofilephotostory() async{
    await getStoryUsernames();
    for(String Uidd in documentNames)
    {
      final docsnap=await _firestore.collection('profile_pictures').doc(Uidd).get();
      if(docsnap.exists){
        String urls=docsnap.data()?['url_user1'];
        storydp.add(urls);
      }
    }
    print('Story url $storydp');
  }
  List<bool> likedstory=[];
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

            // Initialize likedstory with false values

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
  List<String> likedUidsList = [];
  bool liked=false;
  List<bool> likedStory =[];
  Future<void> fetchLikedUids() async {
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('Stories Liked').get();

    querySnapshot.docs.forEach((doc) {
      // Explicitly cast doc.data() to Map<String, dynamic>
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

      // Check if 'likes' field exists and is a List
      if (data != null &&
          data.containsKey('likes') &&
          data['likes'] is List) {
        List<dynamic>? likes = data['likes'];

        likes?.forEach((like) {
          if (like != null && like['liked uid'] != null) {
            likedUidsList.add(like['liked uid']);
          }
        });
      }
    });

    print('liked list $likedUidsList');

    final user = _auth.currentUser;

    // Wait for the for loop to complete before moving forward
    for (int i = 0; i < likedUidsList.length; i++) {
      if (likedUidsList[i] == user!.uid) {
        likedstory[i] = true;
      }
    }

    print('Liked UIDs List: $likedUidsList');
    print('Liked by: $likedstory');

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
  List<String> storyLinks = [];

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
  ScrollController scrollController = ScrollController();
  bool likeIconVisible = false;
  int clickedImageIndex = -1;
  void updateUIWithLikedUsersCount(int index, int count) {
    setState(() {
      likedUsers[index] = likedUsers[index] ?? [];
      likedUsers[index].length = count;
    });
  }
  String usernameofuser = 'Loading';
  Future<void> fetchusernameofuser() async {
    final user = _auth.currentUser;
    try {
      final docsnap =
      await _firestore.collection('User Details').doc(user!.uid).get();
      if (docsnap.exists) {
        setState(() {
          usernameofuser = docsnap.data()?['user name'];
        });
      }
    } catch (e) {
      print(e);
    }
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
          for(int i=0;i<documentNames.length;i++){
            print(documentNames[i]);
          }
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
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => NavBar_shopping(),));
          }, icon: Icon(Icons.shopping_bag,color: Colors.white,)),
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => Notifications(),));
          }, icon: Icon(Icons.notifications_active,color: Colors.white,)),
        ],
      ),
      body: LiquidPullToRefresh(
        backgroundColor: Colors.white,
        onRefresh: fetchStories,
        child: SingleChildScrollView(
          physics:BouncingScrollPhysics(decelerationRate: ScrollDecelerationRate.normal),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (int i = 0; i < storyLinks.length && i < usernames.length; i++)
                      ...[
                        SizedBox(
                          width: 20,
                        ),
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: Colors.black,
                                  actions:[
                                    Column(
                                      children: [
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            TextButton(onPressed: (){
                                            }, child: Text(usernamearray[i],style: TextStyle(color: Colors.white,fontSize: 15,fontWeight: FontWeight.bold),),),
                                          SizedBox(
                                            width: 5,
                                          ),
                                            if(verifs[i]==true)
                                            Image.network(
                                              'https://emkldzxxityxmjkxiggw.supabase.co/storage/v1/object/public/Grovito/480-4801090_instagram-verified-badge-png-instagram-verified-icon-png-removebg-preview.png',
                                              height: 30,
                                              width: 30,
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        InstaImageViewer(
                                          child: Image(
                                            image: NetworkImage(storyLinks[i]),
                                          ),
                                        ),
                                      ],
                                    )
                                  ]
                                );
                              },
                            );
                          },
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundImage: NetworkImage(storyLinks[i]),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                usernamearray[i],
                                style: TextStyle(color: Colors.white,fontSize: 13,fontWeight: FontWeight.bold),
                              ),

                            ],
                          ),
                        ),
                      ],
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  SizedBox(
                    width: 20,
                  ),
                ],
              ),
              SizedBox(
                height: 40,
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
                               InkWell(
                                 child:  CircleAvatar(
                                   radius: 20,
                                   backgroundColor: Colors.black,
                                   child: Image.network(
                                     profilephotos[index],
                                     height: 50,
                                     width: 50,
                                   ),
                                 ),
                               ),
                                SizedBox(
                                  width: 5,
                                ),
                                TextButton(onPressed: ()async{
                                  print('clicked $index');
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Searchresult(userid: uids[index]),));
                                }, child: Text(
                                  usernamesss[index],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),),
                                if (isverifiedd[index] == true)
                                  Image.network(
                                    'https://emkldzxxityxmjkxiggw.supabase.co/storage/v1/object/public/Grovito/480-4801090_instagram-verified-badge-png-instagram-verified-icon-png-removebg-preview.png',
                                    height: 30,
                                    width: 30,
                                  ),
                                if(follow[index]=='true')
                                  ElevatedButton(onPressed: ()async{
                                    final user=_auth.currentUser;
                                    print('uid clicked ${uids[index]}');
                                    await _firestore.collection('Followers').doc(uids[index]).set({
                                      'Followers': FieldValue.arrayRemove([
                                        {
                                          'followerUid': user!.uid,
                                        }
                                      ]),
                                    }, SetOptions(merge: true));
                                    await _firestore.collection('Following').doc(user!.uid).set({
                                      'Followers': FieldValue.arrayRemove([
                                        {
                                          'followerUid': uids[index],
                                        }
                                      ]),
                                    }, SetOptions(merge: true));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Unfollowed Successfully'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  },
                                      child: Text('Following',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 15),),
                                      style: ButtonStyle(
                                          backgroundColor: MaterialStatePropertyAll(Colors.black)
                                      ),
                                    ),
                                if(follow[index]=='false')
                                  ElevatedButton(onPressed: ()async{
                                    print('uid clicked ${uids[index]}');
                                    final user=_auth.currentUser;
                                    await _firestore.collection('Followers').doc(uids[index]).set({
                                      'Followers': FieldValue.arrayUnion([
                                        {
                                          'followerUid': user!.uid,
                                        }
                                      ]),
                                    }, SetOptions(merge: true));
                                    await _firestore.collection('Following').doc(user!.uid).set({
                                      'Followers': FieldValue.arrayUnion([
                                        {
                                          'followerUid': uids[index],
                                        }
                                      ]),
                                    }, SetOptions(merge: true));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Followed Successfully'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  },
                                      child: Text('Follow',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 15),),
                                      style: ButtonStyle(
                                          backgroundColor: MaterialStatePropertyAll(Colors.black)
                                      ),
                                    ),
                              ],
                            ),
                            if (locations.isNotEmpty)
                              Row(
                                children: [
                                  SizedBox(
                                    width: 90,
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
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Stack(
                            children: [
                              GestureDetector(
                                onDoubleTap: () async {
                                  showLikeIcon(index);
                                  print('index $index');
                                  List<String> currentLikedUsers = likedUsers[index];
                                  final bool userLiked = currentLikedUsers.contains(currentUserUid);

                                  if (userLiked) {
                                    currentLikedUsers.remove(currentUserUid);
                                  } else {
                                    currentLikedUsers.add(currentUserUid);
                                  }
                                  await updateFirestoreLikedUsers(index, currentLikedUsers);
                                },
                                child: ProgressiveImage(
                                  width: 350.0,
                                  baseColor: Colors.grey.shade900,
                                  highlightColor: Colors.white,
                                  imageError: 'Failed To Load Image',
                                  image: imageUrls[index],
                                  height: 400.0,
                                ),
                              ),
                              Visibility(
                                visible: likeIconVisible,
                                child: likeIcon(index),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            SizedBox(width: 10),
                            InkWell(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => Searchresult(userid: uids[index]),));
                              },
                              child: Text(
                                usernamesss[index],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
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
                                showLikeIcon(index);
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
                                icon: Icon(Icons.comment_outlined,color: Colors.white)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IconButton(onPressed: ()async{
                                  final user=_auth.currentUser;
                                  await _firestore.collection('Saved').doc(user?.uid).set(
                                      {
                                        'Saved':FieldValue.arrayUnion([
                                          {
                                            'image link':imageUrls[index],
                                            'captions':captions[index],
                                            'profile picture':profilephotos[index],
                                            'username':usernames[index],
                                            'location':locations[index],
                                            'uid':uids[index]
                                          }
                                        ])
                                      }, SetOptions(merge: true));
                                }, icon: Icon(Icons.save_alt,color: Colors.white,)),

                              ],
                            )
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

  void showLikeIcon(int pressedindex) {
    setState(() {
      likeIconVisible = true;
    });

    Timer(Duration(seconds: 1), () {
      setState(() {
        likeIconVisible = false;
      });
    });
  }

  Widget likeIcon(int index) {
    return Positioned(
      top: 0,
      bottom: 0,
      left: 0,
      right: 0,
      child: Icon(
        Icons.favorite,
        color: Colors.white,
        size: 80.0, // Adjust the size as needed
      ),
    );
  }
}

