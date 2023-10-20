import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_chat_app/models/UserModel.dart';
import 'package:my_chat_app/pages/HomePage.dart';

class CompleteProfile extends StatefulWidget {
  final UserModel? userModel;
  final User? firebaseUser;

  const CompleteProfile({super.key, required this.userModel,required this.firebaseUser});



  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {

  File? imageFile;
  TextEditingController fnameController=TextEditingController();

  void selectImage(ImageSource source) async{
    XFile? pickedFile=await ImagePicker().pickImage(source: source);

    if(pickedFile!=null)
      {
        cropImage(pickedFile);
      }
  }
  void cropImage(XFile file) async{
    CroppedFile? croppedImage=await ImageCropper().cropImage(
       sourcePath: file.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 40);
   if(croppedImage !=null)
     {
       setState(() {
         imageFile=File(croppedImage.path);
       });
     }
  }

  void showPhotoOptions(){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text("Upload profile photo"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap: (){
                Navigator.pop(context);
                selectImage(ImageSource.gallery);
              },
              leading: Icon(Icons.photo_album),
              title: Text("Select from gallery"),
            ),
            ListTile(
              onTap: (){
                Navigator.pop(context);
                selectImage(ImageSource.camera);
              },
              leading: Icon(Icons.camera_alt),
              title: Text("Take a photo"),
            ),
          ],
        ),
      );
    });
  }

  void checkValues(){
    String fullName=fnameController.text.trim();
    if(fullName==""||imageFile==null)
      {
        print("Please enter all the fields");
      }
    else
      {
        uploadData();
      }
  }

  void uploadData() async{

    UploadTask uploadTask=FirebaseStorage.instance.ref("profilepictures").
    child(widget.userModel!.uid.toString()).putFile(imageFile!);

    TaskSnapshot snapshot=await uploadTask;

    String? imageUrl=await snapshot.ref.getDownloadURL();
    String? fullName=fnameController.text.trim();

    widget.userModel!.fullname=fullName;
    widget.userModel!.profilepic=imageUrl;

    await FirebaseFirestore.instance.collection("users").doc(widget.userModel!.uid).set(widget.userModel!.toMap()).
    then((value){
      print("data uploaded");
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
          context,
           MaterialPageRoute(builder: (context){
             return HomePage(userModel: widget.userModel!, firebaseuser: widget.firebaseUser!);
           }));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text("Complete profile"),
      ),
      body:SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 40
          ),
          child:ListView(
            children: [
              SizedBox(height: 20),

              CupertinoButton(
                onPressed: (){
                  showPhotoOptions();
                },
                padding:EdgeInsets.all(0),
                child:CircleAvatar(
                  radius: 60,
                  backgroundImage:(imageFile!=null)? FileImage(imageFile!):null,
                  child:(imageFile==null)? Icon(Icons.person,size: 60,):null,
                ),
              ),


              SizedBox(height: 20),

              TextField(
                controller: fnameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                ),
              ),

              SizedBox(height: 20),

              CupertinoButton(child: Text("Submit"),
                  onPressed:(){
                    checkValues();
                  },
                  color:Theme.of(context).colorScheme.secondary),
            ],
          ),
        ),
      ),
    );
  }
}
