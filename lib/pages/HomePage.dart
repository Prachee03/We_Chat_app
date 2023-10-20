import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_chat_app/models/ChatRoomModel.dart';
import 'package:my_chat_app/models/FirebaseHelper.dart';
import 'package:my_chat_app/models/UserModel.dart';
import 'package:my_chat_app/pages/ChatRoomPage.dart';
import 'package:my_chat_app/pages/LoginPage.dart';
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
        actions: [
          IconButton(
              onPressed: () async{
               await FirebaseAuth.instance.signOut();
               Navigator.popUntil(context, (route) => route.isFirst);
               Navigator.pushReplacement(
                   context,
                   MaterialPageRoute(builder: (context){
                     return LoginPage();
                   })
               );
              },
              icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection("chatrooms").
                where("participants.${widget.userModel.uid}",isEqualTo: true).snapshots(),
            builder: (context,snapshot){
              if(snapshot.connectionState==ConnectionState.active)
                {
                  if(snapshot.hasData)
                    {
                      QuerySnapshot chatroomSnapshot=snapshot.data as QuerySnapshot;
                      return ListView.builder(
                        itemCount: chatroomSnapshot.docs.length,
                        itemBuilder: (context,index){
                          ChatRoomModel chatroommodel=ChatRoomModel.
                          fromMap(chatroomSnapshot.docs[index].data() as Map<String,dynamic>);

                          Map<String,dynamic> participants=chatroommodel.participants!;

                          List<String> participantkeys=participants.keys.toList();
                          participantkeys.remove(widget.userModel.uid);

                          return FutureBuilder(
                            future: FirebaseHelper.getUserModelById(participantkeys[0]),
                            builder: (context,userData){
                              if(userData.connectionState==ConnectionState.done)
                                {

                                  if(userData.data!=null)
                                    {
                                      UserModel targetUser=userData.data as UserModel;

                                      return ListTile(
                                        onTap: (){
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context){
                                              return ChatRoomPage(targetUser: targetUser, chatroom: chatroommodel, userModel: widget.userModel, firebaseuser: widget.firebaseuser);
                                            })
                                          );
                                        },
                                        leading: CircleAvatar(
                                          backgroundImage: NetworkImage(targetUser.profilepic.toString()),
                                        ),
                                        title: Text(targetUser.fullname.toString()),
                                        subtitle:(chatroommodel.lastMessage.toString()!="")?Text(chatroommodel.lastMessage.toString()):
                                            Text("Say Hi! To your new friend",style: TextStyle(
                                              color: Theme.of(context).colorScheme.secondary,
                                            ),),

                                      );
                                    }
                                    else
                                      {
                                        return Container();
                                      }

                                }
                              else
                                {
                                  return Container();
                                }

                            },
                          );
                        },
                      );
                    }
                  else if(snapshot.hasError)
                    {
                      return Center(
                        child: Text(snapshot.error.toString()),
                      );
                    }
                  else
                    {
                      return Center(
                        child: Text("No Chats"),
                      );
                    }
                }
              else{
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
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