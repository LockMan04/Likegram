import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:Likegram/features/home/data/user.dart';
import 'package:Likegram/features/home/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> createPost(String content, File? image, BuildContext context) async {
  final postRef = FirebaseFirestore.instance.collection('posts').doc();;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final username = prefs.getString('name');

  try {
    String? imageUrl;
    if (image != null) {
      imageUrl = await _uploadImage(image);
    }

    await postRef.set({
      'content': content,
      'imageUrl': imageUrl,
      'authorId': username,
      'createdAt': Timestamp.now(),
      'likes': [],
      'reports': 0,
    });

    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (content) => HomeScreen()),
        (Route<dynamic> route) => false
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content:
        Text('Đăng bài thành công'),
        backgroundColor: Colors.green,
        margin: EdgeInsets.only(bottom: 20),
        behavior: SnackBarBehavior.floating,
      )
    );

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Có lỗi xảy ra!")));
  }
}

Future<String?> _uploadImage(File image) async {
  try {
    final ref = FirebaseStorage.instance.ref().child('posts').child(DateTime.now().millisecondsSinceEpoch.toString() + '.jpg');
    await ref.putFile(image);
    String imageUrl = await ref.getDownloadURL();
    return imageUrl;
  } catch (e) {
    print("Error uploading image: $e");
    return null;
  }
}
