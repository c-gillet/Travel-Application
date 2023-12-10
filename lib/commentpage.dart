import 'package:comment_box/comment/comment.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_application/style.dart';

class Comments extends StatefulWidget {
  final String recoID;

  Comments({required this.recoID});

  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController commentController = TextEditingController();

  final _authentification = FirebaseAuth.instance;

  User? loggedUser;
  String? username;
  String? profileUrl;

  //String? recoID="hTgNNEOJ3xAtFcpjypRD";//Testing

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = _authentification.currentUser;
      if (user != null) {
        loggedUser = user;

        final currentUserInfo = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (currentUserInfo.exists) {
          setState(() {
            username = currentUserInfo.data()!['userName'];
            profileUrl = currentUserInfo.data()!['profilePictureUrl'];
            if(profileUrl==""){
              profileUrl = "assets/profile_avatar/default_profile_image.jpg";
            }
            //print(profileUrl);
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<List<Map<String, dynamic>>> fetchComments() async {
    List<Map<String, dynamic>> filedata = [];

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance
          .collection('comments')
          .where('recoID', isEqualTo: widget.recoID)
          .orderBy('experienceDate', descending: true)
          .get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> doc
      in querySnapshot.docs) {
        Map<String, dynamic> commentData = doc.data()!;
        filedata.add(commentData);
      }
    } catch (e) {
      print('Error fetching comments: $e');
    }

    return filedata;
  }

  Future<Map<String, dynamic>> fetchUserData(String userName) async {
    try {
      QuerySnapshot<
          Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userName', isEqualTo: userName)
          .limit(
          1) // Limit the result to one document, assuming 'userName' is unique
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }

    return {}; // Return an empty map if user data not found or an error occurs
  }


  Widget commentChild(List<Map<String, dynamic>> data) {
    return Container(
      child: ListView(
        children: [
          for (var i = 0; i < data.length; i++)
            Padding(
              padding: const EdgeInsets.fromLTRB(2.0, 8.0, 2.0, 0.0),
              child: ListTile(
                leading: GestureDetector(
                  onTap: () async {
                    // Display the image in large form.
                    print("Comment Clicked");
                  },
                  child: Container(
                    height: 50.0,
                    width: 50.0,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: FutureBuilder(
                      future: fetchUserData(data[i]['username']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error loading profile picture');
                        } else {
                          Map<String, dynamic> userData =
                          snapshot.data as Map<String, dynamic>;
                          String profilePicture =
                              userData['profilePictureUrl'] ?? 'assets/profile_avatar/default_profile_image.jpg';

                          return CircleAvatar(
                            radius: 50,
                            backgroundImage: CommentBox.commentImageParser(
                              imageURLorPath: profilePicture,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
                title: Text(
                  data[i]['username'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(data[i]['commentText']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(data[i]['experienceDate'],
                        style: const TextStyle(fontSize: 10)),
                    if (data[i]['username'] == username)
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 16,
                        ),
                        onPressed: () {
                          deleteComment(data[i]['commentID']);
                        },
                      ),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }


  void deleteComment(String commentId) async {
    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Delete Comment'),
            content: Text('Are you sure you want to delete this comment?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    // Close the dialog
                    Navigator.of(context).pop();

                    // Delete the comment
                    await FirebaseFirestore.instance
                        .collection('comments')
                        .doc(commentId)
                        .delete();
                    print('Comment deleted successfully');

                    // Reload comments after deleting
                    setState(() {});
                  } catch (e) {
                    print('Error deleting comment: $e');

                    // Show a snackbar with the error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting comment: $e'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                },
                child: Text('Delete'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error showing confirmation dialog: $e');
      // Handle error (show a snackbar, toast, etc.)
    }
  }


  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      child: Scaffold(
        appBar: AppBar(
          title: const Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.keyboard_control_rounded),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Comments'),
                ],
              ),
            ],
          ),
          backgroundColor: AppColor.LightBlue,
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchComments(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              List<Map<String, dynamic>> comments = snapshot.data ?? [];
              return Container(
                child: CommentBox(
                  userImage: AssetImage(profileUrl ??
                      'assets/profile_avatar/default_profile_image.jpg'),
                  labelText: 'Write a comment...',
                  errorText: 'Comment cannot be blank',
                  withBorder: false,
                  sendButtonMethod: () async {
                    if (formKey.currentState!.validate()) {
                      print(commentController.text);

                      // Get the current date and time
                      DateTime now = DateTime.now();

                      // Format the date and time as a string
                      String formattedDate = DateFormat('yyyy-MM-dd HH:mm')
                          .format(now);

                      var newComment = {
                        'recoID': widget.recoID, //Insert the Id of the place
                        'username': username,
                        'commentText': commentController.text,
                        'experienceDate': formattedDate,
                      };

                      // Add the comment to Firestore and get the DocumentReference
                      DocumentReference docRef = await FirebaseFirestore
                          .instance
                          .collection('comments')
                          .add(newComment);

                      // Get the auto-generated comment ID
                      String commentID = docRef.id;

                      // Update the newComment map with the commentID
                      newComment['commentID'] = commentID;

                      // Update Firestore with the commentID
                      await docRef.update({'commentID': commentID});

                      setState(() {
                        comments.insert(0, newComment);
                      });

                      commentController.clear();
                      FocusScope.of(context).unfocus();
                    } else {
                      print("Not validated");
                    }
                  },
                  formKey: formKey,
                  commentController: commentController,
                  backgroundColor: AppColor.LightBlue,
                  textColor: Colors.white,
                  sendWidget: const Icon(
                      Icons.send_sharp, size: 30, color: Colors.white),
                  child: comments.isNotEmpty
                      ? commentChild(comments)
                      : Center(
                    child: Text('No comments'),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}