import 'package:blood_app/controller/auth_provider.dart'
    as bloodAppAuthProvider;
import 'package:blood_app/functions/cap_first.dart';
import 'package:blood_app/screens/sigin_page.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Adduser extends StatefulWidget {
  const Adduser({super.key});

  @override
  State<Adduser> createState() => _AdduserState();
}

class _AdduserState extends State<Adduser> {
  TextEditingController donarName = TextEditingController();
  TextEditingController dob = TextEditingController();
  TextEditingController age = TextEditingController();
  TextEditingController donarPhone = TextEditingController();
  TextEditingController donarlocation = TextEditingController();

  final formKeyLogin = GlobalKey<FormState>();

  final List<String> bloodgroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];
  final List<String> district = [
    'Kasragod',
    'Kannur',
    'Wayanad',
    'Kozhikode',
    'Malappuram',
    'Palakkad',
    'Thrissur',
    'Ernakulam',
    'Idukki',
    'Kottayam',
    'Alappuzha',
    'Pathanamthitta',
    'Kollam',
    'Thiruvananthapuram',
  ];

  final List<String> sex = ['Male', 'Female'];
  String? gender;
  String? selecteddistrict;
  String? selectedgroup;
  final _formkey = GlobalKey<FormState>();

  bool isValidEmail(String email) {
    final RegExp regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$',
    );
    return regex.hasMatch(email);
  }

  bool isValidDate(String input) {
    try {
      final date = DateTime.parse(input);
      return date.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  bool is18OrOlder(String input) {
    final date = DateTime.parse(input);
    final today = DateTime.now();
    final age = today.year - date.year;
    if (today.month < date.month ||
        (today.month == date.month && today.day < date.day)) {
      return age > 18;
    }
    return age >= 18;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dob.text = DateFormat('yyyy-MM-dd').format(picked);
        age.text = calculateAge(picked).toString();
      });
    }
  }

  int calculateAge(DateTime dob) {
    DateTime today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
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
  void dispose() {
    donarName.dispose();
    donarPhone.dispose();
    dob.dispose();

    donarlocation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<bloodAppAuthProvider.AuthPvdr>(
      builder:
          (context, authProvider, child) => Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text("Sign Up"),
              centerTitle: true,
              titleTextStyle: TextStyle(
                fontSize: 18,
                fontFamily: "poppins",
                color: const Color.fromARGB(255, 0, 0, 0),
                fontStyle: FontStyle.normal,
              ),
              foregroundColor: Colors.black,
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              automaticallyImplyLeading: false,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: _formkey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          inputFormatters: [
                            CapitalizeFirstLetterInputFormatter(),
                          ],
                          controller: donarName,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            label: Text("Name"),
                            labelStyle: const TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                              fontFamily: "poppins",
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              _showToast('Please check the name');
                              return 'Please enter name properly';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: dob,
                          decoration: InputDecoration(
                            labelText: 'Date of Birth',
                            labelStyle: const TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                              fontFamily: "poppins",
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onTap: () async {
                            FocusScope.of(context).requestFocus(FocusNode());
                            await _selectDate(context);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your date of birth';
                            }
                            if (!isValidDate(value)) {
                              return 'Please enter a valid date';
                            }
                            if (!is18OrOlder(value)) {
                              return 'You must be at least 18 years old to create an account';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: DropdownButtonFormField(
                                    decoration: InputDecoration(
                                      label: const Text("Gender"),
                                      labelStyle: const TextStyle(
                                        color: Color.fromARGB(255, 0, 0, 0),
                                        fontFamily: "poppins",
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.black,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.black,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    items:
                                        sex
                                            .map(
                                              (e) => DropdownMenuItem(
                                                value: e,
                                                child: Text(e),
                                              ),
                                            )
                                            .toList(),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        _showToast('Please select a Gender');
                                        return 'Please select a Gender';
                                      }
                                      return null;
                                    },
                                    onChanged: (val) {
                                      gender = val as String;
                                    },
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: age,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: 'Age',
                                      labelStyle: const TextStyle(
                                        color: Color.fromARGB(255, 0, 0, 0),
                                        fontFamily: "poppins",
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.black,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.black,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          inputFormatters: [
                            CapitalizeFirstLetterInputFormatter(),
                          ],
                          controller: donarlocation,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            label: Text("City"),
                            labelStyle: const TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                              fontFamily: "poppins",
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              _showToast('Please check the City');
                              return 'Please check the City';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: TextFormField(
                                    controller: donarPhone,
                                    keyboardType: TextInputType.phone,
                                    maxLength: 10,
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.black,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.black,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      label: Text("Phone number"),
                                      labelStyle: const TextStyle(
                                        color: Color.fromARGB(255, 0, 0, 0),
                                        fontFamily: "poppins",
                                      ),
                                      counterText: '',
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        _showToast(
                                          'Please check the Phone Number',
                                        );
                                        return 'Please check the Phone Number';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: DropdownButtonFormField(
                                    decoration: InputDecoration(
                                      label: const Text("Blood Group"),
                                      labelStyle: const TextStyle(
                                        color: Color.fromARGB(255, 0, 0, 0),
                                        fontFamily: "poppins",
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.black,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.black,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    items:
                                        bloodgroups
                                            .map(
                                              (e) => DropdownMenuItem(
                                                value: e,
                                                child: Text(e),
                                              ),
                                            )
                                            .toList(),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        _showToast(
                                          'Please select a Blood Group',
                                        );
                                        return 'Please select a Blood Group';
                                      }
                                      return null;
                                    },
                                    onChanged: (val) {
                                      selectedgroup = val as String;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                            label: const Text("District"),
                            labelStyle: const TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                              fontFamily: "poppins",
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          items:
                              district
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              _showToast('Please select a District');
                              return 'Please select a District';
                            }
                            return null;
                          },
                          onChanged: (val) {
                            selecteddistrict = val as String;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () async {
                            if (_formkey.currentState!.validate()) {
                              if (gender == null ||
                                  selectedgroup == null ||
                                  selecteddistrict == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Please select all required fields.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              final donor = bloodAppAuthProvider.Donor(
                                name: donarName.text,
                                phone: donarPhone.text,
                                location: donarlocation.text,
                                gender: gender,
                                group: selectedgroup,
                                dateofbirth: dob.text,
                                age: age.text,
                                district: selecteddistrict,
                              );

                              try {
                                final authProvider =
                                    Provider.of<bloodAppAuthProvider.AuthPvdr>(
                                      context,
                                      listen: false,
                                    );
                                await authProvider.completesignup(donor);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return SiginPage();
                                    },
                                  ),
                                );
                              } catch (e) {
                                _showToast('Error: $e');
                              }
                            }
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
                                "submit",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "poppins",
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
            ),
          ),
    );
  }
}
