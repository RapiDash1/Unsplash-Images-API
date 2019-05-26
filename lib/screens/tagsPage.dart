//this file displays the related images on more info page
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:staggered_grid/screens/MoreInfo.dart';
import 'HomePage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

//function which returns image info
Future<List<UImage>> TagDetails(image_query) async {
  if (image_query != null) {
    var source = await http.get(
        'https://api.unsplash.com/search/photos?page=1&query=${image_query}&per_page=2&client_id=3a8857dd4ff1aac2ae6e93c0de8eaa5485974bd57fe0ce0b83945f9a9e6ca0e0');
    var jsonData = jsonDecode(source.body);

    List<UImage> Images_Info = [];

    for (var image in jsonData['results']) {
      var tags = [];
      for (var i in image['tags']) {
        tags.add(i['title']);
      }
      //parameters that are required to display image
      var Image_info = UImage(
          image['user']['name'],
          image['user']['username'],
          image['description'],
          image['alt_description'],
          image['urls']['small'],
          image['urls']['regular'],
          tags,
          image['user']['profile_image']['small']);
      Images_Info.add(Image_info);
    }
    return Images_Info;
  }
}

//generate random so that it can pick a random image from each tag page and return it so that it can be displayed on the more ingo page
var rnd = Random();

class tagsPage extends StatelessWidget {
  var tags;
  tagsPage(this.tags);
  @override
  Widget build(BuildContext context) {
    var RndNumber = rnd.nextInt(1) + 1;
    var appHeight = MediaQuery.of(context).size.height;
    var appWidth = MediaQuery.of(context).size.width;
    return Container(
      height: appHeight / 4,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tags.length,
        itemBuilder: (builder, index) {
          return FutureBuilder(
            future: TagDetails(tags[index]),
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return Container();
              } else {
                return GestureDetector(
                  child: Container(
                    child: Image(
                      image: NetworkImage(snapshot.data[RndNumber].url),
                      fit: BoxFit.cover,
                    ),
                    height: appHeight / 5,
                    width: appWidth / 3,
                    margin: EdgeInsets.only(
                        top: appHeight / 70, left: appWidth / 70),
                  ),
                  onTap: (){
                    //onTap of each message, go to moreinfo page
                    Navigator.push(context, CupertinoPageRoute(builder: (context){
                      return MoreInfo(
                            snapshot.data[RndNumber].user_name,
                            snapshot.data[RndNumber].website_user_name,
                            snapshot.data[RndNumber].url,
                            snapshot.data[RndNumber].description,
                            snapshot.data[RndNumber].alt_description,
                            snapshot.data[RndNumber].regular_image_url,
                            snapshot.data[RndNumber].tags,
                            snapshot.data[RndNumber].profile_image,
                            );
                    }),);
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}
