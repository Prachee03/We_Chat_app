import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_chat_app/models/UserModel.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseuser;

  const SearchPage({super.key, required this.userModel, required this.firebaseuser});


  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search"),
        
      ),
      body:SafeArea(
        child: Container(),
      )
    );
  }
}
