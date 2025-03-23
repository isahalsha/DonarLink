import 'package:blood_app/functions/cap_first.dart';

import 'package:blood_app/screens/home_page.dart';
import 'package:blood_app/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:intl/intl.dart';

class PatientRequest extends StatefulWidget {
  const PatientRequest({super.key});

  @override
  State<PatientRequest> createState() => _PatientRequestState();
}

class _PatientRequestState extends State<PatientRequest> {
  final CollectionReference patient = FirebaseFirestore.instance.collection(
    'patient',
  );

  DateTime? selectedDate;
  final TextEditingController _dateController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate!);
      });
    }
  }

  TextEditingController hospital = TextEditingController();
  TextEditingController donarName = TextEditingController();

  TextEditingController donarPhone = TextEditingController();
  TextEditingController donarlocation = TextEditingController();

  final _formKey = GlobalKey<FormState>();
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
    'Kasargod',
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
  String? gender;
  final List<String> sex = ['Male', 'Female'];
  String? selecteddistrict;
  String? selectedgroup;

  Future<void> addrequest() async {
    String group = selectedgroup ?? '';
    String district = selecteddistrict ?? '';
    String gen = gender ?? '';

    print('Selected Group: $group');
    print('Selected District: $district');
    print('Gender: $gen');
    print('donarName: ${donarName.text}');
    print('donarPhone: ${donarPhone.text}');
    print('donarlocation: ${donarlocation.text}');
    print('hospital: ${hospital.text}');

    try {
      await FirebaseFirestore.instance.collection('patient').doc().set({
        'name': donarName.text,
        'phone': donarPhone.text,
        'location': donarlocation.text,
        'group': group,
        'district': district,
        'gender': gen,
        'hospital': hospital.text,
        'createdAt': FieldValue.serverTimestamp(),
        'expiryTime':
            FieldValue.serverTimestamp(), // Consider setting a specific expiry time
      });
    } catch (e) {
      print("Error in addrequest: $e");
      _showToast("Error submitting request. Please try again.");
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

  Future<void> _submitForm() async {
    print('Submit Form Called');
    if (_formKey.currentState?.validate() ?? false) {
      bool? proceed = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Confirmation"),
            content: Text("Are you sure you want to proceed?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Close the dialog with true
                },
                child: Text("Proceed"),
              ),
            ],
          );
        },
      );

      if (proceed == true) {
        await addrequest();

        Fluttertoast.showToast(
          msg: 'Patient request submitted successfully!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 255, 1, 1),
          textColor: Colors.white,
        );

        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => HomeScreen()));
      }
    } else {
      Fluttertoast.showToast(
        msg: 'Please fill in all fields correctly.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Add Patient Request"),
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontFamily: "poppins",
          color: Colors.white,
          fontStyle: FontStyle.normal,
        ),
        foregroundColor: Colors.black,
        backgroundColor: Color.fromARGB(255, 1, 19, 47),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    inputFormatters: [CapitalizeFirstLetterInputFormatter()],
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
                              onTap: () => _selectDate(context),
                              controller: _dateController,
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
                                labelText: 'Select Date',
                                labelStyle: const TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontFamily: "poppins",
                                ),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              readOnly: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  _showToast('Please check the Date');
                                  return 'Please check the Date';
                                }
                                return null;
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
                  child: TextFormField(
                    inputFormatters: [CapitalizeFirstLetterInputFormatter()],
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
                                  _showToast('Please check the Phone Number');
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
                                  _showToast('Please select a Blood Group');
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
                  child: TextFormField(
                    inputFormatters: [CapitalizeFirstLetterInputFormatter()],
                    controller: hospital,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      label: Text("Hospital"),
                      labelStyle: const TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontFamily: "poppins",
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        _showToast('Please check the Hospital');
                        return 'Please enter hospital properly';
                      }
                      return null;
                    },
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
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
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
                    onTap: () {
                      _submitForm();
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
    );
  }
}
