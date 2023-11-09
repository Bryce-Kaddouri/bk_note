import 'package:bk_note/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/route_manager.dart';
import '../repository/auth_repository.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  User? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  void getCurentUser() {
    _user = AuthRepository.instance.currentUser;
    notifyListeners();
  }

  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }

  bool get isLoggedIn => _user != null;

  Future<void> login(String email, String password) async {
    try {
      UserCredential userCredential =
          await AuthRepository.instance.login(email, password);
      _user = userCredential.user;
      notifyListeners();
      Navigator.pushReplacement(Get.context!,
          MaterialPageRoute(builder: (context) => const MyHomePage()));
      Get.snackbar(
        'Success',
        "Login Successful",
        margin: EdgeInsets.all(10),
        icon: Icon(Icons.check, color: Colors.white, size: 30),
        borderRadius: 10,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        shouldIconPulse: true,
        duration: Duration(seconds: 3),
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Error',
        "${e.message}",
        margin: EdgeInsets.all(10),
        icon: Icon(Icons.error, color: Colors.white, size: 30),
        borderRadius: 10,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        shouldIconPulse: true,
        duration: Duration(seconds: 3),
      );
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      UserCredential userCredential =
          await AuthRepository.instance.signUp(email, password);
      _user = userCredential.user;
      notifyListeners();
      Get.snackbar(
        'Success',
        "Sign Up Successful",
        margin: EdgeInsets.all(10),
        icon: Icon(Icons.check, color: Colors.white, size: 30),
        borderRadius: 10,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        shouldIconPulse: true,
        duration: Duration(seconds: 3),
      );
    } on FirebaseAuthException catch (e) {
      // show error message
      Get.snackbar(
        'Error',
        "${e.message}",
        margin: EdgeInsets.all(10),
        icon: Icon(Icons.error, color: Colors.white, size: 30),
        borderRadius: 10,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        shouldIconPulse: true,
        duration: Duration(seconds: 3),
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await AuthRepository.instance.logout();
      _user = null;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await AuthRepository.instance.resetPassword(email);
      Get.snackbar(
        'Success',
        "Reset Password Email Sent",
        margin: EdgeInsets.all(10),
        icon: Icon(Icons.check, color: Colors.white, size: 30),
        borderRadius: 10,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        shouldIconPulse: true,
        duration: Duration(seconds: 3),
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Error',
        "${e.message}",
        margin: EdgeInsets.all(10),
        icon: Icon(Icons.error, color: Colors.white, size: 30),
        borderRadius: 10,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        shouldIconPulse: true,
        duration: Duration(seconds: 3),
      );
      rethrow;
    }
  }
}
