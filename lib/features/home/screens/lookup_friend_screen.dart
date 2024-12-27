import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Likegram/features/home/screens/chat_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Map<String, dynamic>> allUsers = [];
  List<Map<String, dynamic>> filteredUsers = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').get();
      setState(() {
        allUsers = snapshot.docs.map((doc) {
          return {
            'name': doc['name'],
            'email': doc['email'],
            'uid': doc.id,
          };
        }).toList();
        filteredUsers = allUsers;
      });
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  void filterUsers(String query) {
    setState(() {
      filteredUsers = allUsers.where((user) {
        return user['name'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        title: const Text("Mọi người"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ContactSearchDelegate(
                  users: allUsers,
                  onSearch: filterUsers,
                ),
              );
            },
          ),
        ],
      ),
      body: filteredUsers.isEmpty
          ? Center(child: CircularProgressIndicator()) // Hiển thị loading khi chưa có dữ liệu
          : ListView.builder(
        itemCount: filteredUsers.length,
        itemBuilder: (context, index) {
          return ContactCard(
            name: filteredUsers[index]['name'],
            email: filteredUsers[index]['email'],
            press: () {
              final recipientId = filteredUsers[index]['uid'];
              final recipientName = filteredUsers[index]['name'];

              Navigator.push(context,
                  MaterialPageRoute(builder:
                      (context) => ChatScreen(
                      recipientId: recipientId,
                      recipientName: recipientName
                  )
                  )
              );
            },
          );
        },
      ),
    );
  }
}

class ContactCard extends StatelessWidget {
  const ContactCard({
    super.key,
    required this.name,
    required this.email,
    required this.press,
  });

  final String name, email;
  final VoidCallback press;
  final String image = 'https://img.freepik.com/free-psd/3d-illustration-human-avatar-profile_23-2150671142.jpg';

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0 / 2),
      onTap: press,
      leading: CircleAvatarWithActiveIndicator(
        image: image,
        radius: 28,
      ),
      title: Text(name),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 16.0 / 2),
        child: Text(
          email,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.64),
          ),
        ),
      ),
    );
  }
}

class CircleAvatarWithActiveIndicator extends StatelessWidget {
  const CircleAvatarWithActiveIndicator({
    super.key,
    this.image,
    this.radius = 24,
  });

  final String? image;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundImage: image != null && image!.isNotEmpty
              ? NetworkImage(image!)
              : null,
        ),
      ],
    );
  }
}

class ContactSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> users;
  final Function(String) onSearch;

  ContactSearchDelegate({
    required this.users,
    required this.onSearch,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          onSearch(query);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildContactList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildContactList();
  }

  Widget _buildContactList() {
    final filteredUsers = users.where((user) {
      return user['name'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(filteredUsers[index]['name']),
          subtitle: Text(filteredUsers[index]['email']),
          onTap: ()
              {
            close(context, filteredUsers[index]);
          },
        );
      },
    );
  }
}
