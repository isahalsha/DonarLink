import 'package:blood_app/functions/cap_search.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});


  @override
 _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController donarlocation = TextEditingController();
  final TextEditingController selectedGroup = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _users = [];
  bool _noDataFound = false;

  final CarouselSliderController _carouselController =
      CarouselSliderController();

  final List<String> validBloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];
  int _currentIndex = 0;

  void _searchUsers(String group, String location) async {
    try {
      List<Location> userLocations = await locationFromAddress(location);
      if (userLocations.isEmpty) {
        _showToast('Location not found');
        return;
      }

      double userLat = userLocations[0].latitude;
      double userLng = userLocations[0].longitude;
      print('User Coordinates: Latitude: $userLat, Longitude: $userLng');

      QuerySnapshot result =
          await FirebaseFirestore.instance
              .collection('donor')
              .where('group', isEqualTo: group)
              .get();

      List<Map<String, dynamic>> filteredUsers = [];

      for (var doc in result.docs) {
        if (!doc.exists) continue;

        String donorLocation = doc.get("location");
        List<Location> donorLocations = await locationFromAddress(
          donorLocation,
        );
        if (donorLocations.isNotEmpty) {
          double donorLat = donorLocations[0].latitude;
          double donorLng = donorLocations[0].longitude;
          double distance =
              Geolocator.distanceBetween(userLat, userLng, donorLat, donorLng) /
              1000;

          if (distance <= 30) {
            bool userExists = filteredUsers.any(
              (user) => user['phone'] == doc['phone'],
            );

            if (!userExists) {
              filteredUsers.add({
                'name': doc['name'],
                'group': doc['group'],
                'phone': doc['phone'],
                'location': doc['location'],
                'district': doc.get('district'),
                'gender': doc.get('gender'),
                'age': doc.get('age'),
                'distance': distance,
              });

              print(
                "User added: ${doc['name']}, Location: ${doc['location']}, District: ${doc['district']}, Distance: $distance km",
              );
            }
          }
        }
      }

      if (filteredUsers.isEmpty) {
        setState(() {
          _users = [];
          _noDataFound = true;
          Center(child: Text('No data found'));
        });
      } else {
        filteredUsers.sort((a, b) => a['distance'].compareTo(b['distance']));
        setState(() {
          _users = filteredUsers;
          _noDataFound = false;
        });

        print("Users List:");
        for (var user in _users) {
          print(
            "Name: ${user['name']}, Location: ${user['location']}, District: ${user['district']}, Distance: ${user['distance']} km",
          );
        }
      }
    } catch (e, stackTrace) {
      print('Error fetching user data: $e');
      print(stackTrace);
      _showToast('An error occurred. Please try again.');
    }
  }

  void _onSearch() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      _searchUsers(selectedGroup.text, donarlocation.text);
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 1, 19, 47),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: selectedGroup,
                              maxLength: 3,
                              inputFormatters: [
                                CapitalizeFirstThreeLettersInputFormatter(),
                              ],
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                errorStyle: TextStyle(
                                  color: const Color.fromARGB(
                                    255,
                                    255,
                                    255,
                                    255,
                                  ),
                                ),
                                hintText: 'Which Blood Group?',
                                hintStyle: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: const Color.fromARGB(
                                      255,
                                      128,
                                      124,
                                      124,
                                    ),
                                  ),
                                ),
                                counterText: '',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a blood group';
                                }
                                if (!validBloodGroups.contains(
                                  value.toUpperCase(),
                                )) {
                                  return 'Enter a valid blood group';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              controller: donarlocation,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                errorStyle: TextStyle(
                                  color: const Color.fromARGB(
                                    255,
                                    255,
                                    255,
                                    255,
                                  ),
                                ),
                                hintText: 'Location',
                                hintStyle: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: const Color.fromARGB(
                                      255,
                                      174,
                                      170,
                                      170,
                                    ),
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a location';
                                }
                                return null;
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: ElevatedButton(
                                onPressed: _onSearch,
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  backgroundColor: MaterialStateProperty.all(
                                    const Color.fromARGB(255, 255, 255, 255),
                                  ),
                                  minimumSize: MaterialStateProperty.all(
                                    const Size(double.infinity, 50),
                                  ),
                                ),
                                child: const Text(
                                  "Search",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child:
                    _noDataFound
                        ? Center(
                          child: Text(
                            'No data found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                        : Stack(
                          alignment: Alignment.center,
                          children: [
                            CarouselSlider(
                              carouselController: _carouselController,
                              options: CarouselOptions(
                                height: 270,
                                aspectRatio: 1.2,
                                autoPlay: true,
                                autoPlayInterval: const Duration(seconds: 5),
                                autoPlayAnimationDuration: const Duration(
                                  milliseconds: 800,
                                ),
                                viewportFraction: .97,
                                enableInfiniteScroll: false,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _currentIndex = index;
                                  });
                                  print("Current Index: $index");
                                },
                              ),
                              items:
                                  _users.map((user) {
                                    return Builder(
                                      builder: (BuildContext context) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Container(
                                            height: 400,
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                10,
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                60,
                                                255,
                                                255,
                                                255,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              border: Border.all(
                                                color: const Color.fromARGB(
                                                  255,
                                                  0,
                                                  0,
                                                  0,
                                                ),
                                              ),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Color.fromARGB(
                                                    26,
                                                    255,
                                                    255,
                                                    255,
                                                  ),
                                                  blurRadius: 10,
                                                  spreadRadius: 10,
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            left: 10.0,
                                                          ),
                                                      child: Container(
                                                        width: 90.0,
                                                        height: 170,
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                    0.5,
                                                                  ),
                                                              spreadRadius: 1,
                                                              blurRadius: 1,
                                                            ),
                                                          ],
                                                          color:
                                                              const Color.fromARGB(
                                                                255,
                                                                243,
                                                                178,
                                                                200,
                                                              ),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            user['group'],
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 30,
                                                                  fontFamily:
                                                                      'Poppins',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color:
                                                                      Colors
                                                                          .black,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            10,
                                                          ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Row(
                                                            children: <Widget>[
                                                              const Text(
                                                                'Name : ',
                                                                style: TextStyle(
                                                                  fontFamily:
                                                                      'Poppins',
                                                                  fontSize: 18,
                                                                  color:
                                                                      Color.fromARGB(
                                                                        255,
                                                                        104,
                                                                        103,
                                                                        103,
                                                                      ),
                                                                ),
                                                              ),
                                                              Text(
                                                                user['name'],
                                                                style: const TextStyle(
                                                                  fontFamily:
                                                                      'Poppins',
                                                                  fontSize: 18,
                                                                  color:
                                                                      Colors
                                                                          .black,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: <Widget>[
                                                              const Text(
                                                                'Phone : ',
                                                                style: TextStyle(
                                                                  fontFamily:
                                                                      'Poppins',
                                                                  fontSize: 18,
                                                                  color:
                                                                      Color.fromARGB(
                                                                        255,
                                                                        104,
                                                                        103,
                                                                        103,
                                                                      ),
                                                                ),
                                                              ),
                                                              Text(
                                                                user['phone'],
                                                                style: const TextStyle(
                                                                  fontFamily:
                                                                      'Poppins',
                                                                  fontSize: 18,
                                                                  color:
                                                                      Colors
                                                                          .black,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: <Widget>[
                                                              const Text(
                                                                'City : ',
                                                                style: TextStyle(
                                                                  fontFamily:
                                                                      'Poppins',
                                                                  fontSize: 18,
                                                                  color:
                                                                      Color.fromARGB(
                                                                        255,
                                                                        104,
                                                                        103,
                                                                        103,
                                                                      ),
                                                                ),
                                                              ),
                                                              Text(
                                                                user['location'],
                                                                style: const TextStyle(
                                                                  fontFamily:
                                                                      'Poppins',
                                                                  fontSize: 18,
                                                                  color:
                                                                      Colors
                                                                          .black,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: <Widget>[
                                                              const Text(
                                                                'District : ',
                                                                style: TextStyle(
                                                                  fontFamily:
                                                                      'Poppins',
                                                                  fontSize: 18,
                                                                  color:
                                                                      Color.fromARGB(
                                                                        255,
                                                                        104,
                                                                        103,
                                                                        103,
                                                                      ),
                                                                ),
                                                              ),
                                                              Text(
                                                                user['district'],
                                                                style: const TextStyle(
                                                                  fontFamily:
                                                                      'Poppins',
                                                                  fontSize: 18,
                                                                  color:
                                                                      Colors
                                                                          .black,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: <Widget>[
                                                              const Text(
                                                                'Age : ',
                                                                style: TextStyle(
                                                                  fontFamily:
                                                                      'Poppins',
                                                                  fontSize: 18,
                                                                  color:
                                                                      Color.fromARGB(
                                                                        255,
                                                                        104,
                                                                        103,
                                                                        103,
                                                                      ),
                                                                ),
                                                              ),
                                                              Text(
                                                                user['age']
                                                                    .toString(),
                                                                style: const TextStyle(
                                                                  fontFamily:
                                                                      'Poppins',
                                                                  fontSize: 18,
                                                                  color:
                                                                      Colors
                                                                          .black,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: <Widget>[
                                                              Text(
                                                                'Gender : ',
                                                                style: TextStyle(
                                                                  fontFamily:
                                                                      'Poppins',
                                                                  fontSize: 18,
                                                                  color:
                                                                      Color.fromARGB(
                                                                        255,
                                                                        104,
                                                                        103,
                                                                        103,
                                                                      ),
                                                                ),
                                                              ),
                                                              Text(
                                                                user['gender'],
                                                                style: const TextStyle(
                                                                  fontFamily:
                                                                      'Poppins',
                                                                  fontSize: 18,
                                                                  color:
                                                                      Colors
                                                                          .black,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: <Widget>[
                                                              const Text(
                                                                'City : ',
                                                                style: TextStyle(
                                                                  fontFamily:
                                                                      'Poppins',
                                                                  fontSize: 18,
                                                                  color:
                                                                      Color.fromARGB(
                                                                        255,
                                                                        104,
                                                                        103,
                                                                        103,
                                                                      ),
                                                                ),
                                                              ),
                                                              Text(
                                                                '${user['distance'].toStringAsFixed(2)} km',
                                                                style: const TextStyle(
                                                                  fontFamily:
                                                                      'Poppins',
                                                                  fontSize: 18,
                                                                  color:
                                                                      Colors
                                                                          .black,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () async {
                                                        if (await Permission
                                                            .phone
                                                            .request()
                                                            .isGranted) {
                                                          String phoneNumber =
                                                              user['phone']
                                                                  .replaceAll(
                                                                    RegExp(
                                                                      r'[^0-9]',
                                                                    ),
                                                                    '',
                                                                  );
                                                          String countryCode =
                                                              '+91';
                                                          String url =
                                                              'tel:$countryCode$phoneNumber';

                                                          Uri uri = Uri.parse(
                                                            url,
                                                          );

                                                          if (await canLaunchUrl(
                                                            uri,
                                                          )) {
                                                            await launchUrl(
                                                              uri,
                                                            );
                                                          } else {
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                  'Could not launch $url',
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                        } else {
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                'Permission to make phone calls denied.',
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      child: SizedBox(
                                                        child: Row(
                                                          children: <Widget>[
                                                            SizedBox(width: 10),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets.only(
                                                                    left: 20.0,
                                                                  ),
                                                              child: Icon(
                                                                Icons.phone,
                                                                color:
                                                                    Colors
                                                                        .green,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets.all(
                                                                    8.0,
                                                                  ),
                                                              child: Text(
                                                                "Phone",
                                                                style: TextStyle(
                                                                  fontFamily:
                                                                      'Poppins',
                                                                  fontSize: 20,
                                                                  color:
                                                                      Colors
                                                                          .green,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            left: 40.0,
                                                          ),
                                                      child: Container(
                                                        height: 30,
                                                        width: 2,
                                                        decoration:
                                                            BoxDecoration(
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        String texttoshare =
                                                            "Patient Details:\n"
                                                            "Name: ${user['name']}\n"
                                                            "blood group: ${user['group']}\n"
                                                            "Phone: ${user['phone']}\n"
                                                            "Gender: ${user['gender']}\n"
                                                            "City: ${user['location']}\n"
                                                            "District: ${user['district']}\n"
                                                            "Hospital: ${user['hospital']}";
                                                        Share.share(
                                                          texttoshare,
                                                        );
                                                      },
                                                      child: SizedBox(
                                                        child: Row(
                                                          children: [
                                                            SizedBox(width: 10),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets.only(
                                                                    left: 20.0,
                                                                    right: 8.0,
                                                                    top: 8,
                                                                    bottom: 8,
                                                                  ),
                                                              child: Icon(
                                                                Icons.share,
                                                                color:
                                                                    Colors
                                                                        .black,
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets.only(
                                                                    left: 10.0,
                                                                  ),
                                                              child: Text(
                                                                "Share",
                                                                style: TextStyle(
                                                                  fontFamily:
                                                                      'Poppins',
                                                                  fontSize: 20,
                                                                  color:
                                                                      Colors
                                                                          .black,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }).toList(),
                            ),
                            Positioned(
                              bottom: 10.0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:
                                    _users.map((user) {
                                      int index = _users.indexOf(user);
                                      return Container(
                                        width: 8.0,
                                        height: 8.0,
                                        margin: EdgeInsets.symmetric(
                                          vertical: 10.0,
                                          horizontal: 2.0,
                                        ),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color:
                                              _currentIndex == index
                                                  ? const Color.fromARGB(
                                                    255,
                                                    0,
                                                    0,
                                                    0,
                                                  )
                                                  : Colors.grey,
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ),
                          ],
                        ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
