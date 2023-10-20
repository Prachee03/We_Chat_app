import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_chat_app/main.dart';
import 'package:my_chat_app/models/ChatRoomModel.dart';
import 'package:my_chat_app/models/UserModel.dart';
import 'package:my_chat_app/pages/ChatRoomPage.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseuser;

  const SearchPage({super.key, required this.userModel, required this.firebaseuser});


  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  
  TextEditingController searchController=TextEditingController();

  Future<ChatRoomModel?>getChatRoomModel(UserModel targetUser) async{
    ChatRoomModel chatRoom;

    QuerySnapshot snapshot= await FirebaseFirestore.instance.collection("chatrooms").where
      ("participants.${widget.userModel.uid}",isEqualTo:true).where
      ("participants.${targetUser.uid}",isEqualTo:true).get();

    if(snapshot.docs.length>0)
      {
        var docData=snapshot.docs[0].data();
        ChatRoomModel existingChatroom=ChatRoomModel.fromMap(docData as Map<String,dynamic>);
        chatRoom=existingChatroom;
      }
    else
      {
        ChatRoomModel newChatRoom=ChatRoomModel(
          chatroomid: uuid.v1(),
          lastMessage:"",
          participants: {
            widget.userModel.uid.toString():true,
            targetUser.uid.toString():true
          }
        );
        await FirebaseFirestore.instance.collection("chatrooms").doc
          (newChatRoom.chatroomid).set(newChatRoom.toMap());
        chatRoom=newChatRoom;
        print("new chatroom created");
      }
    return chatRoom;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search"),
        
      ),
      body:SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          child:Column(
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: "Email Address"
                ),
              ),
              
              SizedBox(height: 20,),
              
              CupertinoButton(
                  child: Text("Search"),
                  onPressed: (){
                    setState(() {

                    });
                  },
                   color: Theme.of(context).colorScheme.secondary),

              SizedBox(height: 20,),
              
              StreamBuilder(
                stream:FirebaseFirestore.instance.collection("users").
                where("email",isEqualTo:searchController.text).snapshots() ,
                builder:(context,snapshot){
                  if(snapshot.connectionState==ConnectionState.active)
                    {
                      if(snapshot.hasData)
                        {
                          QuerySnapshot dataSnapshot=snapshot.data as QuerySnapshot;

                          if(dataSnapshot.docs.length>0)
                            {
                              Map<String,dynamic> userMap=dataSnapshot.docs[0].data() as Map<String,dynamic>;

                              UserModel searchedUser=UserModel.fromMap(userMap);

                              return ListTile(
                                onTap: ()async{

                                 ChatRoomModel? chatRoomModel=await getChatRoomModel(searchedUser);
                                 if(chatRoomModel!=null)
                                   {
                                     Navigator.pop(context);
                                     Navigator.push(
                                       context,
                                     MaterialPageRoute(builder: (context){
                                       return ChatRoomPage(
                                         targetUser: searchedUser,
                                         userModel: widget.userModel,
                                         firebaseuser: widget.firebaseuser,
                                         chatroom: chatRoomModel,
                                       );
                                     }));

                                   }

                                },
                                leading:
                                CircleAvatar(
                                  backgroundImage: NetworkImage(searchedUser.profilepic!),
                                  backgroundColor: Colors.grey[500],
                                ),
                                title: Text(searchedUser.fullname.toString()),
                                subtitle: Text(searchedUser.email.toString()),
                                trailing: Icon(Icons.keyboard_arrow_right),


                              );
                            }
                          else
                            {
                              return Text("Person not found");
                            }

                        }
                      else if(snapshot.hasError)
                        {
                          return Text("An error occured!");
                        }
                      else
                        {
                          return Text("Person not found");
                        }
                    }
                  else
                    {
                      return CircularProgressIndicator();
                    }
                } ),
            ],
          )
        ),
      )
    );
  }
}
