import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void showReportOptions(BuildContext context, DocumentSnapshot postId) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Báo cáo nội dung',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.warning, color: Colors.orange),
              title: Text('Nội dung không phù hợp'),
              onTap: () {
                _reportPost(context, 'Nội dung không phù hợp', postId);
              },
            ),
            ListTile(
              leading: Icon(Icons.flag, color: Colors.red),
              title: Text('Spam'),
              onTap: () {
                _reportPost(context, 'Spam', postId);
              },
            ),
            ListTile(
              leading: Icon(Icons.block, color: Colors.blue),
              title: Text('Xâm phạm quyền riêng tư'),
              onTap: () {
                _reportPost(context, 'Xâm phạm quyền riêng tư', postId);
              },
            ),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Hủy'),
              ),
            ),
          ],
        ),
      );
    },
  );
}
void _reportPost(BuildContext context, String reason, DocumentSnapshot post) async {
  String postId = post.id;

  final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

  if (post.exists) {
    int reportTimes = post['reports'] ?? 0;

    await postRef.update({
      'reports': reportTimes + 1,
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã báo cáo: $reason'),
        margin: EdgeInsets.only(bottom: 20),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.orange,
      ),

    );
  } else {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Không thể báo cáo. Bài viết không tồn tại.'),
        margin: EdgeInsets.only(bottom: 20),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.orange,
      ),
    );
  }
}
