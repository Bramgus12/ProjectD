import 'package:flutter/material.dart';
import 'package:plantexpert/pages/account/LoginTab.dart';
import 'package:plantexpert/pages/account/RegisterTab.dart';

class Account extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Login', style: TextStyle(fontFamily: 'Libre Baskerville')),
          centerTitle: true,
          bottom: TabBar(tabs: [
            Tab(icon: Icon(Icons.account_box)),
            Tab(icon: Icon(Icons.add_box))
          ]),
        ),
        body: Center(
          child: TabBarView(
            children: [
            LoginTab(),
            RegisterTab()
            ]
          ),
        ),
      ),
    );
  }

}