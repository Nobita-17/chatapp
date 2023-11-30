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
  File? selectedImage;

  Future<void> submit() async {
    final isvalid = _formKey.currentState!.validate();
    if (!isvalid) {
      return;
    }
    _formKey.currentState!.save();

    if (islogin) {
      try {
        final usercredentials = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
        // print('sucessfull logggen in');
        // print(usercredentials);
      } on FirebaseAuthException catch (error)
        {
          if (error.code == 'user-not-found') {
            ScaffoldMessenger.of(context).clearSnackBars();    //?? using this means if this is null the ove to nexr
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error.message ?? 'No user found')));
          }
        }

    } else {
      //logic to create accuont for user
      try {
        final usercredentials = await _firebaseAuth
            .createUserWithEmailAndPassword(email: email, password: password);
        // print(usercredentials);
      } on FirebaseAuthException catch (error) {
        if (error.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).clearSnackBars();    //?? using this means if this is null the ove to nexr
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error.message ?? 'Email Alredy exist')));
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
                          if(!islogin)
                            Imagepicker(),
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
                          SizedBox(
                            height: 40,
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
