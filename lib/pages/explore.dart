import 'package:flutter/material.dart';
class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  TextEditingController _SearchController=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
         children: [
           SizedBox(
             height: 50,
           ),
           TextField(
             style: TextStyle(color: Colors.white),
             controller: _SearchController,
             decoration: InputDecoration(
               fillColor: Colors.grey[900],
               filled: true,
               prefixIcon: Icon(Icons.search,color: Colors.white,),
               hintText:'Search',
               hintStyle: TextStyle(color: Colors.grey)
             ),
           ),
           SizedBox(
             height: 20,
           ),

         ],
        ),
      ),
    );
  }
}
