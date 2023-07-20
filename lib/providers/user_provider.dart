import 'package:flutter/widgets.dart';
import 'package:instagram_flutter/data/auth.dart';
import 'package:instagram_flutter/models/user.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  final Authentication _auth = Authentication();

  User get getUser => _user!;

  Future<void> refreshUser() async {
    User user = await _auth.getUserDetails();
    _user = user;
    notifyListeners();
  }
}
