import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lifebalance/Chat/conversationscreen.dart';
import 'package:lifebalance/Objects/calender.dart';
import 'package:lifebalance/Objects/user.dart';
import 'package:lifebalance/auth/authService.dart';
import 'package:lifebalance/auth/signIn.dart';
import 'package:lifebalance/screens/CalenderExpandedView.dart';
import 'package:lifebalance/screens/friends_page.dart';
import 'package:lifebalance/theme/colors/light_colors.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:lifebalance/theme/colors/light_colors.dart';
import 'package:lifebalance/widgets/gradient_appbar.dart';
import 'package:lifebalance/widgets/theme.dart';

class CommunityPage extends StatefulWidget {
  @override
  CommunityPageState createState() => CommunityPageState();
}

class CommunityPageState extends State<CommunityPage> with SingleTickerProviderStateMixin {
  TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = new TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new GradientAppBar(
        title: 'Community',
        gradientBegin: theme.green,
        gradientEnd: theme.darkergreen,
      ),
      body: new Column(
        children: <Widget>[
          new Container(
            decoration: new BoxDecoration(
              color: theme.green),
            child: new TabBar(
              controller: _controller,
              labelColor: LightColors.kDarkYellow,
              unselectedLabelColor: Colors.white,
              indicatorColor: LightColors.test4,
              tabs: [
              new Tab(
                text: "Calendars",
              ),
              new Tab(
                text: "Friends",
              ),
              new Tab(
                text: "People",
              ),
              ],
            )
          ),
          new Expanded(
            
            child: new TabBarView(
              controller: _controller,
              children: [
                AllCalenders(),
              AllFriends(),
              AllUsers(),
              ]
              )
          )
        ],),
    );
}}

class AllUsers extends StatefulWidget {
  @override
  _AllUsersState createState() => _AllUsersState();
}

class _AllUsersState extends State<AllUsers> {
  @override
  Widget build(BuildContext context) {
    /// this is paginate firestore form the paginate firestore package, it reads 15 documents at a time from firebase, based on the query we provide it
    /// in this case, it is fetching all registered users so we can add whoever we want.
    return PaginateFirestore(
        itemBuilder: (index, context, doc) {
          var friend = User.fromJson(doc.data);
          return ListTile(
            leading: friend.imageUrl.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                    friend.imageUrl,
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ))
                : CircleAvatar(
                    backgroundColor: myPink,
                    child: Text(friend.name[0].toUpperCase()),
                  ),
            title: Text(friend.name),
            subtitle: Text(friend.email),
            trailing: currentUser.uid != friend.uid
                ? FlatButton(
                    padding: EdgeInsets.all(8.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.lightGreen[300])),
                    onPressed: () async {
                      if (currentUser.friendList.contains(friend.uid)) {
                        await doc.reference.setData({
                          'friendList':
                              FieldValue.arrayRemove([currentUser.uid])
                        }, merge: true);
                        await currentUserDocumentReference.setData({
                          'friendList': FieldValue.arrayRemove([friend.uid])
                        }, merge: true);
                        setState(() {});
                      } else {
                        await doc.reference.setData({
                          'friendList': FieldValue.arrayUnion([currentUser.uid])
                        }, merge: true);
                        await currentUserDocumentReference.setData({
                          'friendList': FieldValue.arrayUnion([friend.uid])
                        }, merge: true);
                        setState(() {});
                      }
                    },
                    child: currentUser.friendList.contains(friend.uid)
                        ? Text("Remove",
                            style: TextStyle(
                                color: Color(0xFF800000).withOpacity(0.6)))
                    //original: 0xFFB71C1C
                        : Text("Add",
                            style: TextStyle(color: Color(0xFF558B2F))))
                : null,
          );
        },
        query: Firestore.instance.collection('/users').orderBy('email'),
        // this is the query and above is what to build. so above is the widget it should build based on teh adta it reads from the databse.
        itemBuilderType: PaginateBuilderType.listView);
  }
}

class AllCalenders extends StatefulWidget {
  @override
  _AllCalendersState createState() => _AllCalendersState();
}

class _AllCalendersState extends State<AllCalenders> {
  int reloader = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
        stream: Stream.value(reloader),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return PaginateFirestore(
              /// same thing again but this time we fetch all calenders so user can join whichever he wants. He cannot join his own calender.
              query: Firestore.instance
                  .collectionGroup('userCalenders')
                  .where('isPrivate', isEqualTo: false)
                  .orderBy('participantCount', descending: true),
              itemBuilderType: PaginateBuilderType.listView,
              itemBuilder: (index, context, doc) {
                var calenderObj = CalenderObject.fromJson(doc.data);
                return Container(
                    padding: EdgeInsets.only(top: 2.0, left: 4, right: 4),
                    child: SizedBox(
                      height: 140,
                      child: Card(
                        color: Color(0xFFdaccc4),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CalenderExpandedView(
                                        calenderDocRef: doc.reference,
                                      )),
                            );
                          },
                          title: Text(calenderObj.calenderTitle,
                              style: TextStyle(
                                  fontFamily: 'Courgette',
                                  fontWeight: FontWeight.bold,
                                  height: 2,
                                  fontSize: 18,
                                  color: Color(0xFF43301D))),
                          subtitle: Text(calenderObj.calenderDescription,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF431D1D).withOpacity(0.6))),
                          trailing: calenderObj.creatorID != currentUser.uid

                          //  padding: EdgeInsets.all(8.0),
                        //  shape: RoundedRectangleBorder(
                           //   borderRadius: BorderRadius.circular(10),
                           //   side: BorderSide(color: Colors.lightGreen[300])),

                              ? FlatButton(
                              padding: EdgeInsets.all(8.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(color: LightColors.kGreen)),

                         //     ? MaterialButton(
                         //         minWidth: 0,
                         //         height: 0,
                          //        padding: EdgeInsets.all(8.0),
                          //        shape: RoundedRectangleBorder(
                           //           borderRadius: BorderRadius.circular(10),
                            //          side: BorderSide(
                           //                color: LightColors.kGreen)),
                                  child: currentUser.joinedCalenderPaths
                                          .contains(doc.reference.path)
                                      ? Text("Leave",
                                          style: TextStyle(
                                         //     color: Color(0xFF963B20)
                                         //         .withOpacity(1)))
                                                color: Color(0xFF800000)
                                                    .withOpacity(0.6)))
                                      : Text("Join",
                                          style: TextStyle(
                                              color: Color(0xFF3A5B41))),
                                  onPressed: () {
                                    if (!currentUser.joinedCalenderPaths
                                        .contains(doc.reference.path)) {
                                      WriteBatch writeBatch =
                                          Firestore.instance.batch();
                                      writeBatch.setData(
                                          currentUserDocumentReference,
                                          {
                                            'joinedCalenderPaths':
                                                FieldValue.arrayUnion(
                                                    [doc.reference.path])
                                          },
                                          merge: true);

                                      writeBatch.setData(
                                          doc.reference,
                                          {
                                            'participantCount':
                                                FieldValue.increment(1)
                                          },
                                          merge: true);

                                      writeBatch.setData(
                                          doc.reference,
                                          {
                                            'participantList':
                                                FieldValue.arrayUnion(
                                                    [currentUser.uid])
                                          },
                                          merge: true);
                                      writeBatch.commit().then((value) {
                                        setState(() {});
                                      });
                                    } else {
                                      WriteBatch writeBatch =
                                          Firestore.instance.batch();
                                      writeBatch.setData(
                                          currentUserDocumentReference,
                                          {
                                            'joinedCalenderPaths':
                                                FieldValue.arrayRemove(
                                                    [doc.reference.path])
                                          },
                                          merge: true);

                                      writeBatch.setData(
                                          doc.reference,
                                          {
                                            'participantCount':
                                                FieldValue.increment(-1)
                                          },
                                          merge: true);

                                      writeBatch.setData(
                                          doc.reference,
                                          {
                                            'participantList':
                                                FieldValue.arrayRemove(
                                                    [currentUser.uid])
                                          },
                                          merge: true);
                                      writeBatch.commit().then((value) {
                                        setState(() {});
                                      });
                                      // currentUser.joinedCalenderPaths
                                      //     .remove(doc.reference.path);
                                      // currentUserDocumentReference.setData({
                                      //   'joinedCalenderPaths': currentUser.joinedCalenderPaths
                                      // }, merge: true).then((value) {
                                      //   setState(() {});
                                      // });
                                    }
                                  },
                                )
                              : FlatButton.icon(
                                  onPressed: () {
                                    showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        child: AlertDialog(
                                          content:
                                              Text("Deleting, please wait.."),
                                        ));
                                    print(doc.reference.path);
                                    doc.reference
                                        .collection('events')
                                        .getDocuments()
                                        .then((value) {
                                      print(value.documents.length);
                                      value.documents.forEach((element) async {
                                        await element.reference.delete();
                                      });
                                      doc.reference.delete().then((value) {
                                        setState(() {
                                          reloader = 2;
                                        });
                                      });
                                    }).whenComplete(() {
                                      Navigator.of(context).pop();
                                    });
                                  },
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  label: Text(
                                    "Delete",
                                    style: TextStyle(color: Colors.red),
                                  )),
                        ),
                      ),
                    ));
              },
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}

class AllFriends extends StatefulWidget {
  @override
  _AllFriendsState createState() => _AllFriendsState();
}

class _AllFriendsState extends State<AllFriends> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('/users')
          .document(currentUser.uid)
          .snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasData) {
          return Container(
            child: ListView.builder(
              itemCount: currentUser.friendList.length,

              /// here we display a user's friends based on the list of friends that he had added.
              itemBuilder: (BuildContext context, int index) {
                return StreamBuilder<DocumentSnapshot>(
                    stream: Firestore.instance
                        .collection('/users')
                        .document(currentUser.friendList[index])
                        .snapshots(),
                    builder: (context, friendsnapshot) {
                      if (friendsnapshot.hasData &&
                          friendsnapshot.data.exists) {
                        var friend = User.fromJson(friendsnapshot.data.data);
                        return ListTile(
                          onLongPress: () async {
                            await currentUserDocumentReference.setData({
                              'friendList': FieldValue.arrayRemove([friend.uid])
                            }, merge: true);
                            setState(() {});
                          },
                          trailing: FlatButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ConverstationScreen(
                                            name: friend.name,
                                            userID: friend.uid,
                                          )),
                                );
                              },
                              child: Text("Message")),
                          leading: friend.imageUrl.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                  friend.imageUrl,
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                ))
                              : CircleAvatar(
                                  backgroundColor: myPink,
                                  child: Text(friend.name[0].toUpperCase()),
                                ),
                          title: Text(friend.name),
                          subtitle: Text(friend.email),
                        );
                      } else {
                        return Container();
                      }
                    });
              },
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
