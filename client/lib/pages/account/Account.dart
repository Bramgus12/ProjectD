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
  User loggedInUser;

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
          bottom: status != _Status.loading ? TabBar(tabs: [
            Tab(
              icon: Icon(Icons.account_box),
              text: loggedInUser == null ? "Login" : "Uitloggen"
            ),
            Tab(
              icon: Icon(loggedInUser == null ? Icons.add_box : Icons.edit),
              text: loggedInUser == null ? "Registreer" : "Aanpassen"
            )
          ]) : null,
        ),
        body: Center(
          child: (){ 
            if (status == _Status.loading) {
              return CircularProgressIndicator();
            }
            else
              return TabBarView(
                children: [
                status == _Status.loggedout ? LoginTab() :
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Ingelogd als '${loggedInUser.username}'"),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: RaisedButton(
                        onPressed: logout,
                        child: Text("Uitloggen"),
                      ),
                    )
                  ],
                ),
                RegisterTab(loggedInUser: this.loggedInUser)
                ]
              );
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