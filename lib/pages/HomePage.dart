import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_chat_app/models/UserModel.dart';
import 'package:my_chat_app/pages/SearchPage.dart';

class HomePage extends StatefulWidget{

  final UserModel userModel;
  final User firebaseuser;

  const HomePage({super.key, required this.userModel, required this.firebaseuser});


  @override
  _HomePageState createState()=>_HomePageState();
}

class _HomePageState extends State<HomePage>{

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("We chat"),
      ),
      body: SafeArea(
        child: Container(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context){
                return SearchPage(userModel:widget.userModel, firebaseuser:widget.firebaseuser);
              }));
        },
        child: Icon(Icons.search),
      ),
    );
  }
}