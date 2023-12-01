import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'image.dart';
import 'dart:io';

//authecation screen for user
final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var islogin = true;
  final _formKey = GlobalKey<FormState>();
  var email;
  var password;
  var username;
  File? selectedImage;
  var isAuthenticating = false;

  Future<void> submit() async {
    final isvalid = _formKey.currentState!.validate();
    if (!isvalid || !islogin ) {
      ScaffoldMessenger.of(context)
          .clearSnackBars(); //?? using this means if this is null the ove to nexr
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please Fill The required Fields')));
      return;
    }
    _formKey.currentState!.save();

    if (islogin) {
      try {
        setState(() {
          isAuthenticating = true;
        });

        final usercredentials = await _firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password);
        // print('sucessfull logggen in');
        // print(usercredentials);
      } on FirebaseAuthException catch (error) {
        if (error.code == 'user-not-found') {
          ScaffoldMessenger.of(context)
              .clearSnackBars(); //?? using this means if this is null the ove to nexr
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error.message ?? 'No user found')));

          setState(() {
            isAuthenticating = false;
          });
        }
      }
    } else {
      //logic to create accuont for user
      try {
        final usercredentials = await _firebaseAuth
            .createUserWithEmailAndPassword(email: email, password: password);
        // print(usercredentials);

        final StorageRef = FirebaseStorage.instance
            .ref()
            .child('user_image')
            .child("${usercredentials.user!.uid}.jpg");
        await StorageRef.putFile(selectedImage!);
        final imageUrl = await StorageRef.getDownloadURL();

        await FirebaseFirestore.instance.collection('user').doc(usercredentials.user!.uid).set(
            {
              'username': username,
              'email': email,
              'imageurl': imageUrl,
            });

        print(imageUrl);
      } on FirebaseAuthException catch (error) {
        if (error.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context)
              .clearSnackBars(); //?? using this means if this is null the ove to nexr
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error.message ?? 'Email Alredy exist')));

          setState(() {
            isAuthenticating = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!islogin)
                            Imagepicker(
                              onpickedImage: (File pickedImage) {
                                //reciving picekd image using image picker
                                selectedImage =
                                    pickedImage; //setting the profile image
                              },
                            ),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Enter Email Address',
                              icon: Icon(Icons.email),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter validate an email address';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              email = value;
                            },
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                          ),
                          // SizedBox(
                          //   height: 40,
                          // ),
                          if (!islogin)
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Enter User Name',
                              icon: Icon(Icons.drive_file_rename_outline),
                            ),
                            enableSuggestions: false,
                            validator: (value){
                              if(value==null || value.isEmpty)
                                return;
                            },
                            onSaved: (value) {
                              username = value;
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Enter Password',
                              icon: Icon(Icons.password),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Add a passowrd of length 6';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              password = value;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (isAuthenticating) CircularProgressIndicator(),
              if (!isAuthenticating)
                ElevatedButton(
                  onPressed: submit,
                  child: Text(islogin ? 'login' : 'signup'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.amber,
                    backgroundColor:
                        Colors.black, // Text Color (Foreground color)
                  ),
                ),
              SizedBox(
                height: 10,
              ),
              if (isAuthenticating) CircularProgressIndicator(),
              if (!isAuthenticating)
                TextButton(
                  onPressed: () {
                    setState(() {
                      islogin = !islogin;
                    });
                  },
                  child: Text(
                    islogin ? 'Create account' : 'I have account',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
