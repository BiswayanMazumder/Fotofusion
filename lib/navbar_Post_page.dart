import 'package:flutter/material.dart';
import 'package:fotofusion/posts/post_page.dart';
import 'package:fotofusion/posts/reels.dart';
class postpagenavbar extends StatefulWidget {
  const postpagenavbar({Key? key}) : super(key: key);

  @override
  State<postpagenavbar> createState() => _postpagenavbarState();
}

class _postpagenavbarState extends State<postpagenavbar> {
  @override
  void initState() {
    super.initState();
    // Move the showDialog and navigation logic to a later stage, e.g., after the first frame is built
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _showUploadDialog();
    });
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          actions: [
            SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Postpage()),
                  );
                },
                child: Text(
                  'Upload a Photo',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Reels_page(isImage: false),
                    ),
                  );
                },
                child: Text(
                  'Upload Reels',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Other widgets in your column
        ],
      ),
    );
  }
}
