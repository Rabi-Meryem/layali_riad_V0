import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> _userData = {
    'name': 'Meryem Rabi',
    'email': 'rabimeryem@example.com',
    'phone': '0675849328',
    'profileImage': null,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 106, 62, 3), // Light brown / beige
      body: Column(
        children: [
          SizedBox(height: 100),
          Container(
            height: 20,
            color: Color.fromARGB(255, 106, 62, 3),
          ),
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 80),
                  decoration: BoxDecoration(
                    color: Color(0xFFD2B48C),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 70),
                      Text(
                        _userData['name'],
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 30),
                      _buildSection(
                        title: 'Personal Information',
                        onTap: () {
                          // Navigate to personal info page later
                        },
                      ),
                      _buildSection(title: 'Login and Security'),
                      _buildSection(title: 'Translation'),
                      _buildSection(title: 'Notifications'),
                      SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Log out',
                            style: TextStyle(fontSize: 14, color: Colors.red),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFD2B48C),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(4),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _userData['profileImage'] != null
                            ? NetworkImage(_userData['profileImage'])
                            : null,
                        child: _userData['profileImage'] == null
                            ? Icon(Icons.person, size: 50)
                            : null,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 120,
            color: Color.fromARGB(255, 106, 62, 3),
          )
        ],
      ),
    );
  }

  Widget _buildSection({required String title, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16),
            ),
            Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    TextEditingController nameController =
    TextEditingController(text: _userData['name']);
    TextEditingController phoneController =
   TextEditingController(text: _userData['phone']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Full Name'),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _userData['name'] = nameController.text;
                  _userData['phone'] = phoneController.text;
                });
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
