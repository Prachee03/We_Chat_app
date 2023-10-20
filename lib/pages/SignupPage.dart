import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_chat_app/pages/CompleteProfile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/UserModel.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  TextEditingController emailController=TextEditingController();
  TextEditingController passController=TextEditingController();
  TextEditingController cPassController=TextEditingController();

  void checkValues(){

    String email=emailController.text.trim();
    String password=passController.text.trim();
    String cpassword=cPassController.text.trim();

    if(email==""|| password==""||cpassword==""){
      print("Please enter all fields");
    }
    else if(password!=cpassword){
      print("Passwords do not match");
    }
    else
      {
        signUp(email, password);
      }
  }

  void signUp(String email,String password) async{
      UserCredential? credential;
      try{
        credential=await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      } on FirebaseAuthException catch(e){
        print(e.code.toString());
      }
      if(credential!=null)
        {
          String uid=credential.user!.uid;
          UserModel newUser=UserModel(
            uid: uid,
            email: email,
            fullname: "",
            profilepic: "",
          );
          await FirebaseFirestore.instance.collection("users").doc(uid).set(newUser.toMap()).
          then((value) =>
               print("New user created"));
               Navigator.popUntil(context, (route) => route.isFirst);
               Navigator.pushReplacement(
                   context,
                   MaterialPageRoute(builder: (context){

                    return CompleteProfile(userModel: newUser,firebaseUser:credential!.user! );
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

                  SizedBox(height: 10,),

                  TextField(
                    controller: cPassController,
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: "Confirm Password"
                    ),
                  ),

                  SizedBox(height: 20,),

                  CupertinoButton(
                      child: Text("Signup"),
                      onPressed:(){
                        checkValues();
                      },
                      color:Theme.of(context).colorScheme.secondary

                  ),

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
            Text("Already have an account?",style: TextStyle(
              fontSize: 16,
            ),),
            CupertinoButton(
              child: Text("Login",style:TextStyle(
                fontSize: 16,
              )),
              onPressed:(){
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
