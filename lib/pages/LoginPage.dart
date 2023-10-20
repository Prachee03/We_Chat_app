import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_chat_app/models/UserModel.dart';
import 'package:my_chat_app/pages/HomePage.dart';
import 'package:my_chat_app/pages/SignupPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController emailController=TextEditingController();
  TextEditingController passController=TextEditingController();

  void checkValues()
  {
    String email=emailController.text.trim();
    String password=passController.text.trim();

    if(email==""|| password==""){
      print("Please enter all fields");
    }

    else
    {
      logIn(email, password);
    }
  }

  void logIn(String email,String password) async
  {
    UserCredential? credential;
    try{
      credential=await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch(e){
      print(e.code.toString());
    }

    if(credential !=null)
      {
        String uid=credential.user!.uid;

        DocumentSnapshot userData =await FirebaseFirestore.instance.collection('users').doc(uid).get();
        UserModel userModel=UserModel.fromMap(userData.data() as
        Map<String,dynamic>);
        print("Login successful");
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context){
              return HomePage(userModel: userModel, firebaseuser: credential!.user!);
            }));
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 40,
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text("We Chat",style: TextStyle(
                    color:Theme.of(context).colorScheme.secondary,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),),

                  SizedBox(height: 10,),

                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email"
                    ),
                  ),
                  SizedBox(height: 10,),

                  TextField(
                    controller: passController,
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: "Password"
                    ),
                  ),

                  SizedBox(height: 20,),

                  CupertinoButton(
                      child: Text("Login"),
                      onPressed:(){
                        checkValues();
                        },
                      color:Theme.of(context).colorScheme.secondary),

                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Don't have an account?",style: TextStyle(
              fontSize: 16,
            ),),
            CupertinoButton(
              child: Text("Signup",style:TextStyle(
                fontSize: 16,
              )),
              onPressed:(){
                Navigator.push(context, MaterialPageRoute(builder:(context){
                  return SignUpPage();
                }
                ),);
              },
            ),
          ],
        ),
      ),
    );
  }
}
