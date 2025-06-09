import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? get user => _user;

  bool get isLoggedIn => _user != null;

  // Método para carregar o usuário logado
  Future<void> loadUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final doc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (doc.exists) {
        _user = UserModel.fromMap(doc.data()!, currentUser.uid);
        notifyListeners();
      }
    }
  }

  // Método para cadastrar novo usuário no Firestore
  Future<void> registerUser(UserModel newUser) async {
    await _firestore.collection('users').doc(newUser.uid).set(newUser.toMap());
    _user = newUser;
    notifyListeners();
  }

  // Método para logout
  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }
}
