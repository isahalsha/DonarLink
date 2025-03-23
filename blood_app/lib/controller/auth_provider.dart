import 'package:blood_app/screens/sigin_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For ChangeNotifier
import 'package:blood_app/functions/auth.dart'; // Ensure this exists and is correctly implemented.

enum Authstatus {
  notDetermined,
  notSignedIn,
  signedInAndVerified,
  signedInButNotVerified,
  loading,
  error,
}

class Donor {
  String? name;
  String? phone;
  String? location;

  String? gender;
  String? group;
  String? dateofbirth;
  String? age;
  String? district;

  Donor({
    this.name,
    this.phone,
    this.location,

    this.gender,
    this.group,
    this.dateofbirth,
    this.age,
    this.district,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'location': location,

      'gender': gender,
      'group': group,
      'dateofbirth': dateofbirth,
      'age': age,
      'district': district,
    };
  }

  factory Donor.fromMap(Map<String, dynamic> data) {
    return Donor(
      name: data['name'],
      phone: data['phone'],
      location: data['location'],

      gender: data['gender'],
      group: data['group'],
      dateofbirth: data['dateofbirth'],
      age: data['age'],
      district: data['district'],
    );
  }
}

class AuthPvdr with ChangeNotifier {
  final AuthService _authService = AuthService();
  Authstatus _authstatus = Authstatus.notDetermined;
  User? _user;
  Donor? _donor;
  String? _errorMessage;

  Authstatus get authStatus => _authstatus;
  User? get user => _user;
  Donor? get donor => _donor;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _getcurrentUser();
  }

  Future<void> _getcurrentUser() async {
    _authstatus = Authstatus.loading;
    notifyListeners();
    _user = _authService.getCurrentUser();
    if (_user == null) {
      _authstatus = Authstatus.notSignedIn;
      _donor = null;
    } else {
      await _checkEmailVerification();
      await fetchdetails();
    }
    notifyListeners();
  }

  Future<void> _checkEmailVerification() async {
    if (_user != null) {
      await _user!.reload();
      if (_user!.emailVerified) {
        _authstatus = Authstatus.signedInAndVerified;
      } else {
        _authstatus = Authstatus.signedInButNotVerified;
      }
    }
  }

  Future<void> signup(String email, String password) async {
    _authstatus = Authstatus.loading;
    notifyListeners();
    try {
      _user = await _authService.signUpWithEmailAndPassword(email, password);
      if (_user != null) {
        await _checkEmailVerification();
      }
    } catch (e) {
      _authstatus = Authstatus.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> completesignup(Donor donor) async {
    _authstatus = Authstatus.loading;
    notifyListeners();
    if (_user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('donor')
            .doc(_user!.uid)
            .set(donor.toMap());
        _donor = donor;
        _authstatus = Authstatus.signedInAndVerified;
        await fetchdetails();
      } catch (e) {
        _authstatus = Authstatus.error;
        _errorMessage = e.toString();
      } finally {
        notifyListeners();
      }
    }
  }

  Future<void> login(String email, String password) async {
    _authstatus = Authstatus.loading;
    notifyListeners();
    try {
      _user = await _authService.signInWithEmailAndPassword(email, password);
      if (_user != null) {
        await _checkEmailVerification();
        await fetchdetails();
      }
    } catch (e) {
      _authstatus = Authstatus.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> logout(BuildContext context) async {
    // Add BuildContext
    _authstatus = Authstatus.loading;
    notifyListeners();
    try {
      await _authService.signOut();
      _user = null;
      _donor = null;
      _authstatus = Authstatus.notSignedIn;
      // Navigation to sign-in page:
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SiginPage(),
        ), // Replace 'SignInPage' with your actual sign-in page widget.
      );
    } catch (e) {
      _authstatus = Authstatus.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchdetails() async {
    if (_user != null) {
      try {
        DocumentSnapshot snapshot =
            await FirebaseFirestore.instance
                .collection('donor')
                .doc(_user!.uid)
                .get();
        if (snapshot.exists) {
          _donor = Donor.fromMap(snapshot.data() as Map<String, dynamic>);
        } else {
          _donor = null;
        }
      } catch (e) {
        _errorMessage = e.toString();
      } finally {
        notifyListeners();
      }
    }
  }
}
