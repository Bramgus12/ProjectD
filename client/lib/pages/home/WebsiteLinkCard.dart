import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WebsiteLinkCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {  
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset("assets/images/by_living_art_logo_large.png"),
            ),
            title: Text("By Living Art"),
            subtitle: Text("Bezoek de website."),
            trailing: RaisedButton(
              onPressed: openUrl,
              child: Text(
                "Open",
                style: TextStyle(
                  color: Colors.white
                ),
              ),
              color: Theme.of(context).accentColor,
            ),
          ),
        ],
      )
    );
  }

  void openUrl() async {
    const url = "https://www.bylivingart.com/";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }
}