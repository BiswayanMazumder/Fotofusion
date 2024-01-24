import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fotofusion/main.dart';
import 'package:google_fonts/google_fonts.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _usernamecontroller = TextEditingController();
  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController _passwordcontroller = TextEditingController();
  TextEditingController _namecontroller = TextEditingController();
  Future<void> signup() async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailcontroller.text,
        password: _passwordcontroller.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome To FotoFusion'),
          duration: Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Dismiss',
            onPressed: () {
              // Do something when the user presses the action button
            },
          ),
        ),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage()));
    } catch (e) {
      print(e);
    }
  }
  String err='';
  String success='';
  Future<void> signupfirestore() async {
    final user = _auth.currentUser;
    try {
      await _firestore.collection('User Details').doc(user!.uid).set({
        'user names':_usernamecontroller.text,
        'user name': _namecontroller.text,
        'email': _emailcontroller.text,
        'followers':[],
        'following':[],
        'time of registering': FieldValue.serverTimestamp(),
      });
      setState(() {
        success='Account Successfully Created';
      });
      user.sendEmailVerification();
      print('Details successfully written');
    } catch (e) {
      print('Error $e');
      setState(() {
        err='Account Already exists';
      });
    }
  }

  bool showpw = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 90,
            ),
            Image(
              image: NetworkImage(
                  'https://firebasestorage.googleapis.com/v0/b/fotofusion-53943.appspot.com/o/_c44cd56b-b056-4bee-9361-59b7751584cb.jpg?alt=media&token=36028288-14f6-4b68-ab27-3cb3f96a73a2'),
            ),
            Center(
              child: Text(
                'Welcome To FotoFusion',
                style: GoogleFonts.arya(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Username can be changed later',
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
            SizedBox(
              height: 50,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[800]!,
              ),
              child: TextField(
                style: TextStyle(color: Colors.white),
                controller: _usernamecontroller,
                decoration: InputDecoration(
                  hintText: '  Name',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[800]!,
              ),
              child: TextField(
                style: TextStyle(color: Colors.white),
                controller: _namecontroller,
                decoration: InputDecoration(
                  hintText: '  User Name',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[800]!,
              ),
              child: TextField(
                style: TextStyle(color: Colors.white),
                controller: _emailcontroller,
                decoration: InputDecoration(
                  hintText: '  Email ID',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[800]!,
              ),
              child: TextField(
                style: TextStyle(color: Colors.white),
                controller: _passwordcontroller,
                obscureText: showpw ? false : true,
                decoration: InputDecoration(
                  hintText: '  Password',
                  hintStyle: TextStyle(color: Colors.grey),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        showpw = !showpw;
                      });
                    },
                    icon: showpw
                        ? Icon(CupertinoIcons.eye_fill)
                        : Icon(CupertinoIcons.eye_slash),
                    color: showpw ? Colors.blue : Colors.grey,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            ElevatedButton(
              onPressed: () async {
                if (_namecontroller != null &&
                    _emailcontroller != null &&
                    _passwordcontroller != null &&
                    _namecontroller.text.isNotEmpty &&
                    _emailcontroller.text.isNotEmpty &&
                    _passwordcontroller.text.isNotEmpty &&
                    _usernamecontroller.text.isNotEmpty) {
                  await signup(); // Wait for signup to complete
                  signupfirestore();
                  Text(success,style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold),);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill every details to continue'),
                      duration: Duration(seconds: 5),
                      action: SnackBarAction(
                        label: 'Dismiss',
                        onPressed: () {},
                      ),
                    ),
                  );
                }
                Text(err,style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),);
              },
              style: ButtonStyle(
                shadowColor: MaterialStatePropertyAll(Colors.black),
                elevation: MaterialStatePropertyAll(50),
                backgroundColor: MaterialStatePropertyAll(Colors.blue),
              ),
              child: Text(
                'Sign Up',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }
}
