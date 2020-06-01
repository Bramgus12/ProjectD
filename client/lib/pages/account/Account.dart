import 'package:flutter/material.dart';
import 'package:plantexpert/AccountFunctions.dart';
import 'package:plantexpert/api/User.dart';
import 'package:plantexpert/pages/account/LoginTab.dart';
import 'package:plantexpert/pages/account/RegisterTab.dart';

enum _Status {
  loading,
  loggedin,
  loggedout
}

class Account extends StatefulWidget{
  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  _Status status = _Status.loading;
  String loggedInUser;

  @override void initState() {
    super.initState();
    getLoggedInUser().then((value){
      setState(() {
        loggedInUser = value;
        status = value == null ? _Status.loggedout : _Status.loggedin;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Account', style: TextStyle(fontFamily: 'Libre Baskerville')),
          centerTitle: true,
          bottom: status == _Status.loggedout ? TabBar(tabs: [
            Tab(
              icon: Icon(Icons.account_box),
              text: "Login"
            ),
            Tab(
              icon: Icon(Icons.add_box),
              text: "Registreer"
            )
          ]) : null,
        ),
        body: Center(
          child: (){ 
            if(status == _Status.loggedout)
              return TabBarView(
                children: [
                LoginTab(),
                RegisterTab()
                ]
              );
            else if(status == _Status.loggedin) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Ingelogd als '$loggedInUser'"),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: RaisedButton(
                      onPressed: logout,
                      child: Text("Uitloggen"),
                    ),
                  )
                ],
              );
            }
            else {
              return CircularProgressIndicator();
            }
          }()
        ) 
      )
    );
  }

  void logout() {
    userLogout();
    setState(() {
      loggedInUser = null;
      status = _Status.loggedout;
    });
  }
}