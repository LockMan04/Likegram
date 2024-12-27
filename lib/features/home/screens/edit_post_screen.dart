import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditPostScreen extends StatefulWidget {
  final DocumentSnapshot post;

  EditPostScreen({required this.post});

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.post['content']);
  }

  Future<void> updatePost() async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.id)
          .update({
        'content': _controller.text,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chỉnh sửa bài viết thành công'),
            backgroundColor: Colors.green,
            margin: EdgeInsets.only(bottom: 20),
            behavior: SnackBarBehavior.floating,
          ));
      Navigator.pop(context);
    } catch (e) {
      print("Error updating post: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sửa bài"),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Colors.white),
            onPressed: updatePost,
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: TextField(
          controller: _controller,
          maxLines: 10,
          decoration: InputDecoration(
            labelText: 'Nội dung bài viết',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}
