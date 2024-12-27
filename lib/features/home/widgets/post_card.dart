import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Likegram/features/home/widgets/show_report.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/post.dart';
import '../screens/comment_screen.dart';
import '../screens/edit_post_screen.dart';

class Post extends StatelessWidget {
  const Post({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("Không có bài đăng nào"));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var post = snapshot.data!.docs[index];
            return PostCard(post: post,);
          }
        );
      },
    );
  }
}


class PostCard extends StatefulWidget {
  final DocumentSnapshot post;

  const PostCard({super.key, required this.post});

  @override
  PostCardState createState() => PostCardState();
}

class PostCardState extends State<PostCard> {
  ValueNotifier<bool> expandListener = ValueNotifier<bool>(false);
  bool isLiked = false;
  int likeCount = 0;
  int report = 0;

  void toggleLike() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userName = prefs.getString('name');

    if (userName != null) {
      DocumentReference postRef = FirebaseFirestore.instance.collection('posts').doc(widget.post.id);

      DocumentSnapshot postSnapshot = await postRef.get();
      if (postSnapshot.exists) {
        List likes = postSnapshot['likes'] ?? [];

        if (likes.contains(userName)) {
          likes.remove(userName);
        } else {
          likes.add(userName);
        }

        await postRef.update({'likes': likes});

        setState(() {
          isLiked = !isLiked;
          likeCount = likes.length;
        });
      }
    }
  }

  Future<void> _checkIfLiked() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userName = prefs.getString('name');

    if (userName != null) {
      final postSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.id)
          .get();

      if (postSnapshot.exists) {
        List likes = postSnapshot['likes'] ?? [];
        setState(() {
          isLiked = likes.contains(userName);
          likeCount = likes.length;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initAsyncTask();
  }

  void _initAsyncTask() async {
    await _checkIfLiked();
  }

  Future<bool> _canEditPost() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('name');

    if(username == null) {
      return false;
    }
    String? postAuthor = widget.post['authorId'];

    return username == postAuthor;
  }

  Future<void> deletePost(BuildContext context) async {
    try {
      if (await _canEditPost()) {
        await FirebaseFirestore.instance.collection('posts').doc(widget.post.id).delete();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bài đã được xóa'),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(bottom: 20),
              backgroundColor: Colors.orange,
            ));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bạn không có quyền xóa bài này'),
          backgroundColor: Colors.red,
          margin: EdgeInsets.only(bottom: 20),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      print("Error deleting post: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String content = widget.post['content'];
    String imageUrl = widget.post['imageUrl'] ?? '';
    Timestamp timestamp = widget.post['createdAt'];
    String username = widget.post['authorId'] ?? 'Ẩn danh';


    // String content = 'Test';
    // String imageUrl = 'https://xemayhuyhoang.com/upload/product/exciter150phienbangioihanxanhden-3824.jpg';
    // String timestamp = '12/12/2024';
    // String username = 'Ẩn danh';

    DateTime createdAt = timestamp.toDate();
    String formattedDate =
        "${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute}";
    return Container(
      padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 30),
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: imageUrl.isNotEmpty
                  ? Image.network(imageUrl, fit: BoxFit.cover, height: 150)
                  : Container(),
            ),
          ),
          SizedBox(height: 10),
          Text(
            formattedDate,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  toggleLike();
                },
                icon: Icon(
                  isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                  color: isLiked ? Colors.orange : Colors.black,
                  size: 30,
                ),
              ),
              Text(
                '$likeCount',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommentsScreen(postId: widget.post.id),
                    ),
                  );
                },
                icon: const Icon(
                  CupertinoIcons.chat_bubble_2,
                  size: 30,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.share,
                  size: 30,
                ),
              ),
              SizedBox(width: 100),
              PopupMenuButton<String>(
                onSelected: (String result) async {
                  bool canEdit = await _canEditPost();
                  switch (result) {
                    case 'edit':
                      if(canEdit) {
                        Navigator.push(context, MaterialPageRoute(builder:
                            (context) => EditPostScreen(post: widget.post,)));
                      } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Bạn không có quyền chỉnh sửa bài này'),
                              margin: EdgeInsets.only(bottom: 20),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.red,
                            ));
                      }
                      break;
                    case 'delete':
                      if(canEdit) {
                        showDialog(context: context,
                            builder: (context){
                          return AlertDialog(
                            title: Text('Cảnh báo'),
                            content: Text('Bạn có chắc muốn xóa bài đăng này không?'),
                            actions: [
                              ElevatedButton(
                                  onPressed: (){
                                    deletePost(context);
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(Colors.red),
                                    foregroundColor: WidgetStatePropertyAll(Colors.white)
                                  ),
                                  child: Text('Xác nhận', style: TextStyle(
                                      color: Colors.white),
                                  )),
                            ],
                          );
                          }
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Bạn không có quyền xóa bài này'),
                              margin: EdgeInsets.only(bottom: 20),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.red,
                            ));
                      }
                      break;
                    case 'report':
                        showReportOptions(context, widget.post);
                      break;
                  }
                },
                icon: Icon(Icons.more_vert),
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Chỉnh sửa'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Xóa'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Icons.report, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Báo cáo'),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
          ValueListenableBuilder<bool>(
            valueListenable: expandListener,
            builder: (context, value, _) {
              return GestureDetector(
                onTap: content.length > 50
                    ? () {
                  expandListener.value = !value;
                }
                    : null,
                child: Text.rich(
                  TextSpan(
                    text: username,
                    children: [
                      TextSpan(
                        text: content.length > 50 && !value
                            ? " ${content.substring(0, 50)}"
                            : " ${content}",
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      content.length > 50
                          ? TextSpan(
                        text: value ? "" : " ...more",
                        style: const TextStyle(
                          fontWeight: FontWeight.w200,
                        ),
                      )
                          : const TextSpan(),
                    ],
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    expandListener.dispose();
    super.dispose();
  }
}
