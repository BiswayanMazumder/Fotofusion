import 'package:flutter/material.dart';
import 'package:fotofusion/account%20page/user_account.dart';
import 'package:fotofusion/navbar.dart';
import 'package:fotofusion/pages/signup.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context){
    final FirebaseAuth _auth=FirebaseAuth.instance;
    final user=_auth.currentUser;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FotoFusion',
      home: user!=null?NavBar():MyHomePage()
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseAuth _auth=FirebaseAuth.instance;
  TextEditingController _emailcontroller=TextEditingController();
  TextEditingController _passwordcontroller=TextEditingController();
  TextEditingController _namecontroller=TextEditingController();
  bool isloading=true;
  int count=0;
  String res='';
  void inccount(){
    setState(() {
      count+=1;
    });
    print(count);
  }
  bool isLoading=false;
  String error='';
  Future<void> login() async{
    try{
      await _auth.signInWithEmailAndPassword(email: _emailcontroller.text, password: _passwordcontroller.text);
      print('logged in');
      setState(() {
        isLoading=true;
      });
      Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => NavBar()));
    }catch(e){
      print(e);
      setState(() {
        error='Enter correct email id or password';

      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Enter correct email id or password'),
      ));
    }
  }
  bool showpw=false;
  Future<void> signup() async{
    await _auth.createUserWithEmailAndPassword(email: _emailcontroller.text, password: _passwordcontroller.text);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 100,
            ),
            Image(image: NetworkImage('https://firebasestorage.googleapis.com/v0/b/fotofusion-53943.appspot.com/o/fotofusion%20bg%20-%20Made%20with%20Clipchamp.gif?alt=media&token=b9674f4c-e669-44db-ae54-4c5628c01d06'),
            height: 400,
              width: 800,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[800]!,

              ),
                child: TextField(
                  controller: _emailcontroller,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '  Email ID',
                    hintStyle: TextStyle(
                      color: Colors.grey
                    )
                  ),
                )),
            SizedBox(
              height: 30,
            ),
            Container(
                decoration: BoxDecoration(
                  color: Colors.grey[800]!,

                ),
                child: TextField(
                  controller: _passwordcontroller,
                  obscureText: showpw?false:true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                      hintText: '  Password',
                      hintStyle: TextStyle(
                          color: Colors.grey,
                      ),
                    suffixIcon: IconButton(onPressed: (){
                      setState(() {
                        showpw=!showpw;
                      });
                    },
                        icon: showpw?Icon(CupertinoIcons.eye_fill):Icon(CupertinoIcons.eye_slash),
                    color: showpw?Colors.blue:Colors.grey,
                    )
                  ),
                )),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: ()async{
                  await _auth.sendPasswordResetEmail(email: _emailcontroller.text);
                  setState(() {
                    res='Password reset email sent';
                  });
                },
                    child: Text('Forgot Password?',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)),
              ),

            SizedBox(
              height: 20,
            ),
            ElevatedButton(onPressed: (){
              inccount();
              login();
            },
                style: ButtonStyle(
                  shadowColor: MaterialStatePropertyAll(Colors.black),
                  elevation: MaterialStatePropertyAll(50),
                  backgroundColor: MaterialStatePropertyAll(Colors.blue)
                ),
                child: isLoading?Container(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.black,),
                ):Text('Login',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                )
            ),
            SizedBox(
              height: 20,
            ),
            Text(error,style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),),
            Text(res,style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold),),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account?",style: TextStyle(color: Colors.grey,fontSize: 13),),
                TextButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Signup(),));
                },
                    child: Text('Create an account',style: TextStyle(color: Colors.white,fontWeight:FontWeight.bold),))
              ],
            ),
               ],
        ),
      ),
    );
  }
}
