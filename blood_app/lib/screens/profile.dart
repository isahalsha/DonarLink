import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:blood_app/controller/auth_provider.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthPvdr>(context, listen: false).fetchdetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        titleTextStyle: TextStyle(
          fontFamily: "poppins",
          color: Colors.black,
          fontSize: 18,
        ),
      ),
      body: Consumer<AuthPvdr>(
        builder: (context, authProvider, child) {
          if (authProvider.user == null) {
            return Center(child: Text('Please log in.'));
          }
          if (authProvider.donor == null &&
              authProvider.authStatus == Authstatus.loading) {
            return Center(child: CircularProgressIndicator());
          }
          if (authProvider.authStatus == Authstatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error loading profile'),
                  if (authProvider.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(authProvider.errorMessage!),
                    ),
                ],
              ),
            );
          }
          if (authProvider.donor == null) {
            return Center(child: Text('Profile not found'));
          }

          final donor = authProvider.donor!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                ),
                SizedBox(height: 20),
                _buildProfileRow("Name: ", donor.name ?? 'N/A'),
                _buildProfileRow("Age: ", donor.age ?? 'N/A'),
                _buildProfileRow("Gender: ", donor.gender ?? 'N/A'),
                _buildProfileRow("Blood Group: ", donor.group ?? 'N/A'),

                _buildProfileRow("Phone: ", donor.phone ?? 'N/A'),
                _buildProfileRow("City: ", donor.location ?? 'N/A'),
                _buildProfileRow("District: ", donor.district ?? 'N/A'),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Provider.of<AuthPvdr>(
                      context,
                      listen: false,
                    ).logout(context);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 1, 19, 47),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        "Logout",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "poppins",
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontFamily: 'poppins', color: Colors.grey),
          ),
          Text(
            value,
            style: TextStyle(fontFamily: 'poppins', color: Colors.black),
          ),
        ],
      ),
    );
  }
}
