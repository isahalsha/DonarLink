import 'package:flutter/material.dart';

class HomeProvider with ChangeNotifier {
  String _searchQuery = '';
  String _selectedGroup = 'All';
  bool _isSearchFocused = false;
  List<Map<String, dynamic>> _users = [];
  String get searchQuery => _searchQuery;
  String get selectedGroup => _selectedGroup;
  bool get isSearchFocused => _isSearchFocused;
  List<Map<String, dynamic>> get users => _users;
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedGroup(String group) {
    _selectedGroup = group;
    notifyListeners();
  }

  void setIsSearchFocused(bool isFocused) {
    print("Setting isSearchFocused to: $isFocused");
    _isSearchFocused = isFocused;
    notifyListeners();
  }

  void setUsers(List<Map<String, dynamic>> users) {
    _users = users;
    notifyListeners();
  }
}
