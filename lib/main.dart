import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_chat_app/models/FirebaseHelper.dart';
import 'package:my_chat_app/models/UserModel.dart';
import 'package:my_chat_app/pages/CompleteProfile.dart';
import 'package:my_chat_app/pages/HomePage.dart';
import 'package:my_chat_app/pages/LoginPage.dart';
import 'package:my_chat_app/pages/SignupPage.dart';
import 'package:uuid/uuid.dart';


var uuid=Uuid();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  User? currentUser=FirebaseAuth.instance.currentUser;

  if(currentUser!=null)
    {
      UserModel? thisuserModel=await FirebaseHelper.getUserModelById(currentUser.uid);
      if(thisuserModel!=null)
        {
          runApp(MyAppLoggedIn(userModel: thisuserModel, firebaseuser: currentUser));
        }
      else
        {
          runApp(MyApp());
        }

    }
  else
    {
      runApp(MyApp());
    }

}

//not logged in
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

//logged in
class MyAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseuser;

  const MyAppLoggedIn({super.key, required this.userModel, required this.firebaseuser});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(userModel: userModel, firebaseuser: firebaseuser),
    );
  }
}

