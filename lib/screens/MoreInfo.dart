import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'tagsPage.dart';
import 'package:url_launcher/url_launcher.dart';


class MoreInfo extends StatelessWidget {
  final String url;
  final String description;
  final String alt_description;
  final List tags;
  final String user_name;
  final String profile_image;
  final String website_user_name;
  final String regular_image_url;

  MoreInfo(this.user_name, this.website_user_name, this.url, this.description,
      this.alt_description, this.regular_image_url, this.tags, this.profile_image);
  @override
  Widget build(BuildContext context) {

    var appHeight = MediaQuery.of(context).size.height;
    var appWidth = MediaQuery.of(context).size.width;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        actionsForegroundColor: Colors.white,
        middle: Text(
          'Post',
          style: TextStyle(color: Colors.white, fontSize: appWidth / 17),
        ),
        backgroundColor: Colors.black,
      ),
      child: Container(
        padding: EdgeInsets.all(0.0),
        child: Card(
          child: ListView(
            children: <Widget>[
              Container(
                height: appHeight / 2,
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: regular_image_url,
                  errorWidget: (context, url, error) {
                    Icon(Icons.error);
                  },
                ),
              ),
              Container(
                child: Row(
                  children: <Widget>[
                    Container(
                      child: (profile_image != null)
                          ? Image(
                              image: NetworkImage(profile_image),
                            )
                          : Icon(Icons.account_circle),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      child: (user_name != null)
                      ? GestureDetector(
                        child: Text(
                          user_name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: appWidth / 24,
                            decoration: TextDecoration.underline
                          ),
                        ),
                        //onTap open user profile through a browser
                        onTap: () async {
                        final unsplashUrl = 'https://unsplash.com/@${website_user_name}';
                        if (await canLaunch(unsplashUrl)) {
                          await launch(unsplashUrl);
                        } else {
                          print('Could not launch $unsplashUrl');
                        }
                      },
                      )
                      : Text(
                          'No UserName',
                          style: TextStyle(color: Colors.white),
                        ),
                      margin: EdgeInsets.only(left: appWidth / 40),
                    ),
                  ],
                ),
                color: Colors.black87,
                padding: EdgeInsets.all(appWidth / 80),
                height: appHeight / 15,
              ),
              Container(
                margin: EdgeInsets.only(left: appWidth / 80,),
                child: Row(
                  children: <Widget>[
                    Text('Photo on '),
                    GestureDetector(
                      child: Text(
                        'Unsplash.com',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      //Ontap open unsplash.com
                      onTap: () async {
                        final unsplashUrl = 'https://unsplash.com/';
                        if (await canLaunch(unsplashUrl)) {
                          await launch(unsplashUrl);
                        } else {
                          print('Could not launch $unsplashUrl');
                        }
                      },
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                    top: appWidth / 40,
                    left: appWidth / 80,
                    right: appWidth / 60),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: appWidth / 2000),
                  ),
                ),
                padding: EdgeInsets.only(bottom: appHeight / 100),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      Icons.insert_comment,
                      color: Colors.black87,
                    ),
                    Expanded(
                      child: Container(
                        child: (description != null)
                            ? Text(
                                description,
                                style: TextStyle(fontSize: appWidth / 25),
                              )
                            : Text(alt_description),
                        margin: EdgeInsets.only(left: appWidth / 60),
                      ),
                    ),
                  ],
                ),
              ),
              //recommendation of similar images
              Container(
                margin: EdgeInsets.only(top: appWidth / 40),
                child: Text(
                  'People also search for:',
                  style: TextStyle(
                      fontSize: appWidth / 20, fontWeight: FontWeight.w600),
                ),
              ),
              tagsPage(tags),
              (tags != null)
                  ? Container(
                      height: appHeight / 17,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: tags.length,
                        itemBuilder: (context, index) {
                          return Container(
                            color: Colors.red[600],
                            child: Text(
                              '${tags[index]}',
                              style: TextStyle(
                                  color: Colors.white, fontSize: appWidth / 22),
                            ),
                            margin: EdgeInsets.only(
                                top: appWidth / 60, right: appWidth / 120),
                            padding: EdgeInsets.all(appWidth / 60),
                          );
                        },
                      ),
                      margin: EdgeInsets.only(top: appWidth / 60),
                    )
                  : Text('No tags'),
            ],
          ),
        ),
      ),
    );
  }
}
