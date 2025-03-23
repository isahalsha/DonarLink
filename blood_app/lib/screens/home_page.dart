import 'package:blood_app/controller/home_provider.dart';
import 'package:blood_app/screens/patient_req.dart';
import 'package:blood_app/screens/volunteer.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

class HomePageBody extends StatefulWidget {
  const HomePageBody({super.key});

  @override
  HomePageBodyState createState() => HomePageBodyState();
}

class HomePageBodyState extends State<HomePageBody> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  bool isSearchFocused = false;
  final List<String> bloodGroups = [
    'All',
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];
  final CollectionReference donor = FirebaseFirestore.instance.collection(
    'donor',
  );
  @override
  void initState() {
    super.initState();
    // Add listeners to the FocusNode
    searchFocusNode.addListener(() {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      homeProvider.setIsSearchFocused(searchFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    searchFocusNode.dispose();
    super.dispose();
  }

  int _currentIndex = 0;
  final selectedGroup = ValueNotifier<String>('All');
  final searchQuery = ValueNotifier<String>('');

  Future<List<Map<String, dynamic>>> fetchPatients(String searchQuery) async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('patient').get();
    List<Map<String, dynamic>> patients =
        querySnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'name': doc['name'],
            'hospital': doc['hospital'],
            'phone': doc['phone'],
            'location': doc['location'],
            'district': doc['district'],
            'group': doc['group'],
            'gender': doc['gender'],
          };
        }).toList();

    if (searchQuery.isNotEmpty) {
      patients =
          patients.where((patient) {
            return patient['name'].toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                patient['hospital'].toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                patient['location'].toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                patient['district'].toLowerCase().contains(
                  searchQuery.toLowerCase(),
                );
          }).toList();
    }

    return patients;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        return Scaffold(
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.filter_alt),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 8,
                            right: 8,
                            top: 8,
                            bottom: 8,
                          ),
                          child: TextFormField(
                            controller: searchController,
                            focusNode: searchFocusNode,
                            decoration: InputDecoration(
                              hintText: "Search Users",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontFamily: 'Poppins',
                              ),
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: () {
                                  homeProvider.setSearchQuery(
                                    searchController.text,
                                  );
                                },
                              ),
                            ),
                            onChanged: (value) {
                              homeProvider.setSearchQuery(value);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Visibility(
                        visible: !homeProvider.isSearchFocused,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FutureBuilder<List<Map<String, dynamic>>>(
                            future: fetchPatients(homeProvider.searchQuery),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (snapshot.hasError) {
                                return Center(
                                  child: Text('Error: ${snapshot.error}'),
                                );
                              }

                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return Center(
                                  child: Text(
                                    'No Blood Requests found.',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'Poppins',
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              }

                              List<Map<String, dynamic>> patients =
                                  snapshot.data!;

                              List<Map<String, dynamic>> uniquePatients = [];
                              Set<String> uniqueIds = Set();

                              for (var patient in patients) {
                                if (!uniqueIds.contains(patient['id'])) {
                                  uniquePatients.add(patient);
                                  uniqueIds.add(patient['id']);
                                }
                              }

                              return Container(
                                height: 240,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 255, 17, 0),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CarouselSlider(
                                      items:
                                          uniquePatients.map((patient) {
                                            return Container(
                                              height: 450,
                                              width: 370,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Colors.white,
                                              ),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              8,
                                                            ),
                                                        child: Container(
                                                          width: 90.0,
                                                          height: 160,
                                                          decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  10,
                                                                ),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .grey
                                                                    .withOpacity(
                                                                      0.5,
                                                                    ),
                                                                spreadRadius: 1,
                                                                blurRadius: 1,
                                                                offset:
                                                                    const Offset(
                                                                      0,
                                                                      3,
                                                                    ),
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
                                                              patient['group'],
                                                              style: const TextStyle(
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
                                                      Column(
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
                                                                patient['name'],
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
                                                                patient['phone'],
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
                                                                patient['gender'],
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
                                                                patient['location'],
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
                                                                patient['district'],
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
                                                                'Hospital : ',
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
                                                                patient['hospital'],
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
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                  'This app needs phone permission to initiate calls.',
                                                                ),
                                                              ),
                                                            );
                                                          }

                                                          if (await Permission
                                                              .phone
                                                              .request()
                                                              .isGranted) {
                                                            String phoneNumber =
                                                                patient['phone']
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
                                                              const SnackBar(
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
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets.only(
                                                                      left:
                                                                          20.0,
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
                                                                    fontSize:
                                                                        20,
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
                                                              "Name: ${patient['name']}\n"
                                                              "blood group: ${patient['group']}\n"
                                                              "Phone: ${patient['phone']}\n"
                                                              "Gender: ${patient['gender']}\n"
                                                              "City: ${patient['location']}\n"
                                                              "District: ${patient['district']}\n"
                                                              "Hospital: ${patient['hospital']}";
                                                          Share.share(
                                                            texttoshare,
                                                          );
                                                        },
                                                        child: SizedBox(
                                                          child: Row(
                                                            children: [
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets.only(
                                                                      left:
                                                                          20.0,
                                                                      right:
                                                                          8.0,
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
                                                                      left:
                                                                          10.0,
                                                                    ),
                                                                child: Text(
                                                                  "Share",
                                                                  style: TextStyle(
                                                                    fontFamily:
                                                                        'Poppins',
                                                                    fontSize:
                                                                        20,
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
                                            );
                                          }).toList(),
                                      options: CarouselOptions(
                                        height: 230,
                                        autoPlay: true,
                                        aspectRatio: 1.5,
                                        viewportFraction: 0.99,
                                        scrollDirection: Axis.horizontal,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Visibility(
                        visible: !homeProvider.isSearchFocused,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:
                              homeProvider.users.map((user) {
                                int index = homeProvider.users.indexOf(user);
                                return Container(
                                  width: 10,
                                  height: 10,
                                  margin: EdgeInsets.symmetric(
                                    vertical: 10.0,
                                    horizontal: 2.0,
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        _currentIndex == index
                                            ? const Color.fromARGB(255, 0, 0, 0)
                                            : Colors.grey,
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Visibility(
                        visible: !homeProvider.isSearchFocused,
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap:
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PatientRequest(),
                                      ),
                                    ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                        255,
                                        85,
                                        195,
                                        247,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.volunteer_activism_outlined,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            "Request Blood",
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: GestureDetector(
                                onTap:
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Volunteer(),
                                      ),
                                    ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                        255,
                                        85,
                                        195,
                                        247,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons
                                                .supervised_user_circle_rounded,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            "Be A volunteer",
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Visibility(
                        visible: homeProvider.isSearchFocused,
                        child: SizedBox(
                          height: 60,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: bloodGroups.length,
                            itemBuilder: (context, index) {
                              final bloodGroup = bloodGroups[index];
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    homeProvider.setSelectedGroup(bloodGroup);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          homeProvider.selectedGroup ==
                                                  bloodGroup
                                              ? Colors.red
                                              : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color:
                                            homeProvider.selectedGroup ==
                                                    bloodGroup
                                                ? Colors.white
                                                : Colors.black,
                                        width: 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        bloodGroup,
                                        style: TextStyle(
                                          color:
                                              homeProvider.selectedGroup ==
                                                      bloodGroup
                                                  ? Colors.white
                                                  : Colors.black,
                                          fontFamily: 'Poppins',
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    ValueListenableBuilder<String>(
                      valueListenable: selectedGroup,
                      builder: (context, bloodGroup, child) {
                        return ValueListenableBuilder<String>(
                          valueListenable: searchQuery,
                          builder: (context, value, child) {
                            return StreamBuilder<QuerySnapshot>(
                              stream:
                                  bloodGroup == 'All'
                                      ? donor.orderBy('name').snapshots()
                                      : donor
                                          .where('group', isEqualTo: bloodGroup)
                                          .orderBy('name')
                                          .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final List<DocumentSnapshot> donors =
                                      snapshot.data!.docs.where((doc) {
                                        final nameMatch = doc['name']
                                            .toLowerCase()
                                            .contains(
                                              homeProvider.searchQuery
                                                  .toLowerCase(),
                                            );
                                        final bloodGroupMatch =
                                            bloodGroup == 'All' ||
                                            doc['group'] == bloodGroup;
                                        return nameMatch && bloodGroupMatch;
                                      }).toList();

                                  return SliverList(
                                    delegate: SliverChildBuilderDelegate((
                                      context,
                                      index,
                                    ) {
                                      final DocumentSnapshot donorsnap =
                                          donors[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8,
                                          right: 8,
                                          top: 3,
                                          bottom: 3,
                                        ),
                                        child: Container(
                                          height: 180,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: const Color.fromARGB(
                                                255,
                                                198,
                                                195,
                                                195,
                                              ),
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            color: const Color.fromARGB(
                                              255,
                                              255,
                                              255,
                                              255,
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
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                child: Container(
                                                  width: 90.0,
                                                  height: 155.0,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    color: const Color.fromARGB(
                                                      255,
                                                      243,
                                                      178,
                                                      200,
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      donorsnap['group'],
                                                      style: const TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontSize: 30,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Row(
                                                    children: <Widget>[
                                                      const Text(
                                                        'Name : ',
                                                        style: TextStyle(
                                                          fontFamily: 'Poppins',
                                                          fontSize: 18,
                                                          color: Color.fromARGB(
                                                            255,
                                                            104,
                                                            103,
                                                            103,
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        donorsnap['name'],
                                                        style: const TextStyle(
                                                          fontFamily: 'Poppins',
                                                          fontSize: 18,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: <Widget>[
                                                      const Text(
                                                        'Phone : ',
                                                        style: TextStyle(
                                                          fontFamily: 'Poppins',
                                                          fontSize: 18,
                                                          color: Color.fromARGB(
                                                            255,
                                                            104,
                                                            103,
                                                            103,
                                                          ),
                                                        ),
                                                      ),
                                                      const Text(
                                                        '+91 ',
                                                        style: TextStyle(
                                                          fontFamily: 'Poppins',
                                                          fontSize: 18,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      Text(
                                                        donorsnap['phone'],
                                                        style: const TextStyle(
                                                          fontFamily: 'Poppins',
                                                          fontSize: 18,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: <Widget>[
                                                      const Text(
                                                        'City : ',
                                                        style: TextStyle(
                                                          fontFamily: 'Poppins',
                                                          fontSize: 18,
                                                          color: Color.fromARGB(
                                                            255,
                                                            104,
                                                            103,
                                                            103,
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        donorsnap['location'],
                                                        style: const TextStyle(
                                                          fontFamily: 'Poppins',
                                                          fontSize: 18,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: <Widget>[
                                                      const Text(
                                                        'District : ',
                                                        style: TextStyle(
                                                          fontFamily: 'Poppins',
                                                          fontSize: 18,
                                                          color: Color.fromARGB(
                                                            255,
                                                            104,
                                                            103,
                                                            103,
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        donorsnap['district'],
                                                        style: const TextStyle(
                                                          fontFamily: 'Poppins',
                                                          fontSize: 18,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: <Widget>[
                                                      Text(
                                                        'Gender : ',
                                                        style: TextStyle(
                                                          fontFamily: 'Poppins',
                                                          fontSize: 18,
                                                          color: Color.fromARGB(
                                                            255,
                                                            104,
                                                            103,
                                                            103,
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        donorsnap['gender'],
                                                        style: const TextStyle(
                                                          fontFamily: 'Poppins',
                                                          fontSize: 18,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: <Widget>[
                                                      const Text(
                                                        'Age : ',
                                                        style: TextStyle(
                                                          fontFamily: 'Poppins',
                                                          fontSize: 18,
                                                          color: Color.fromARGB(
                                                            255,
                                                            104,
                                                            103,
                                                            103,
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        donorsnap['age']
                                                            .toString(),
                                                        style: const TextStyle(
                                                          fontFamily: 'Poppins',
                                                          fontSize: 18,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }, childCount: donors.length),
                                  );
                                }
                                return SliverToBoxAdapter(
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
