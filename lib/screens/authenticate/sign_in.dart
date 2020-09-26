import 'package:flutter/rendering.dart';
import 'package:lifebalance/screens/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:lifebalance/screens/services/loadingwidget.dart';

class SignIn extends StatefulWidget {

  final Function toggleView;
  SignIn({ this.toggleView });

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;   //show loading widget if true
  String error = '';

  // text field state
  String email = '';    //replace with user email/password input and store into value
  String password = '';

  Widget build(BuildContext context) {
    return loading ? LoadingWidget() : Scaffold(    //if loading = true (validating credentials), show widget, else if error, show scaffold (sign in screen)
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        toolbarHeight: 80.0,
        title: Text('Sign In',
        style: TextStyle (
          color: Colors.black,
          fontSize: 30.0,
        )),
        centerTitle: true,
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(Icons.person),
            label: Text('Sign Up',
            style: TextStyle (
              color: Color(0XFFF2994A),
            ),),
            onPressed: () => widget.toggleView(),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
                  filled: true,
                  fillColor: Color(0XFFF6F6F6),
                  contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                  enabledBorder: OutlineInputBorder (
                      borderSide: BorderSide(color: Color(0xFFE8E8E8)),
                      borderRadius: BorderRadius.circular(7.0)
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color:Colors.grey[400])
                  ),
                ),
                validator: (val) => val.isEmpty ? 'Enter an email' : null,
                onChanged: (val) {
                  setState(() => email = val);  //store input email to val
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
                  filled: true,
                  fillColor: Color(0XFFF6F6F6),
                  contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                  enabledBorder: OutlineInputBorder (
                      borderSide: BorderSide(color: Color(0xFFE8E8E8)), 
                      borderRadius: BorderRadius.circular(7.0)
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color:Colors.grey[400])
                  ),
                ),
                obscureText: true,
                validator: (val) => val.length < 6 ? 'Enter a password 6+ chars long' : null,
                onChanged: (val) {
                  setState(() => password = val); //store input password to val
                },
              ),
              SizedBox(height: 35.0),
              Container(
                width: 350.0,
                height: 45.0,
                child: RaisedButton(
                  color: Color(0xFF5E7A6C),
                  child: Text(
                    'Sign In',
                    style: TextStyle(color: Colors.white),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  onPressed: () async {
                    if(_formKey.currentState.validate()){
                      setState(() => loading = true);     //show loading widget when validating credentials
                      dynamic result = await _auth.signInWithEmailAndPassword(email, password);
                      if(result == null) {
                        setState(() {
                          error = 'Could not sign in with those credentials';
                          loading = false;                //credentials error, stop showing loading widget
                        });
                      }
                    }
                  }
              ),
              ),
              SizedBox(height: 12.0),
              Text(
                error,
                style: TextStyle(color: Colors.red, fontSize: 14.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}