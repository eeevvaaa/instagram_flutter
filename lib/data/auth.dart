import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_flutter/models/user.dart' as model;

class Authentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(documentSnapshot);
  }

  Future<String> signUp({
    required String username,
    required String email,
    required String password,
    required String bio,
    // instead of File because anything from dart:io is not accessible from the web
    // #limitation
    required Uint8List file,
  }) async {
    // inform the user whether the sign up was successful
    String res = 'Something went wrong, please try again';
    try {
      // eventho it's never gonna be null, it's a good practice to check that?
      // TODO: fact check that
      if (username.isNotEmpty ||
          email.isNotEmpty ||
          password.isNotEmpty ||
          // ignore: unnecessary_null_comparison
          file != null) {
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        // store the user in firestore database
        // difference between if use add instead of doc and set, firebase would generate a random id as the document of the collection, and the value would be different than what's in the field, which is credential.user.uid
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'username': username,
          'uid': credential.user!.uid,
          'email': email,
          'bio': bio,
          'followers': [],
          'following': []
        });
        res = 'success';
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        // logging in user with email and password
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
