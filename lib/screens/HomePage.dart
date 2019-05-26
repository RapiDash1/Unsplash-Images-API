import 'dart:math';
import './MoreInfo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'tags_list.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appWidth = MediaQuery.of(context).size.width;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.black,
        middle: Text(
          'Unsplash Image Api',
          style: TextStyle(color: Colors.white),
        ),
        leading: Container(
          child: Icon(
            Icons.account_circle,
            size: appWidth/12,
            color: Colors.black,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        trailing: GestureDetector(
          onTap: () {
            showSearch(
              context: context,
              delegate: ProfileSearch(),
            );
          },
          child: Icon(
            Icons.search,
            color: Colors.white,
            size: appWidth / 12,
          ),
        ),
      ),
      child: StaggeredView('happy'),// default page will display 'happy' page of the unsplash api
    );
  }
}

class StaggeredView extends StatefulWidget {
  var Query;
  StaggeredView(this.Query);
  
  @override
  _StaggeredViewState createState() => _StaggeredViewState(Query);
}

var image_query; //Variable to take in query input
var page = 0; //Page number variable 

//Function to get images from unsplash api, which returns a Future list of Image info
Future<List<UImage>> UnsplashImages(image_query) async {

    //if query is not null then get the info of images
    if(image_query != null){
      var source = await http.get(
          'https://api.unsplash.com/search/photos?page=${page}&query=${image_query}&per_page=15&client_id=6afce23445904aebe8ef6e597340247cf1357b4ca8b439283a48eea3c4fa9247');
      var jsonData = jsonDecode(source.body);

      List<UImage> Images_Info = [];

      for (var image in jsonData['results']) {
        var tags = [];
        for (var i in image['tags']) {
          tags.add(i['title']);
        }
        var Image_info = UImage(image['user']['name'], image['user']['username'], image['description'],
            image['alt_description'], image['urls']['small'], image['urls']['regular'], tags,image['user']['profile_image']['small']);
        Images_Info.add(Image_info);
      }
      return Images_Info;//return image info
  }
   }
  var x = []; //variable to update the image info as scrolling reaches max extent for 'happy' page
  var y = []; //variable to update the image info as the scrolling reaches max extent for all not 'happy' page

  //function to update the variables when scrolling reaches max extent
  UpdatedInfo(Query) async {
    page = page +1;

    
      if(Query != 'happy'){
        y = y + await UnsplashImages(Query);
        return y;
      }
      else{
        x = x + await UnsplashImages(Query);
        return x;
      }
      
    }
  

class _StaggeredViewState extends State<StaggeredView> {
  var Query;
  _StaggeredViewState(this.Query);
  @override
    void initState() {
    super.initState();
    //update UnsplashImages function and app new page to list
    UnsplashImages(Query);
    _scrollController.addListener((){
      if(_scrollController.position.maxScrollExtent == _scrollController.offset){
        setState(() {
           UpdatedInfo(Query); 
          });
      }
    });
  }

  var _scrollController = ScrollController();

  //dispose scroll controller
  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  
  //Generate random number to vary size of image in staggered grid view
  var rnd = Random();
  var RndNum;

  @override
  Widget build(BuildContext context) {

    var appHeight = MediaQuery.of(context).size.height;
    var appWidth = MediaQuery.of(context).size.width;

    //function to build the staggered grid
    buildGrid(){
      return FutureBuilder(
      future: UpdatedInfo(Query),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return Center(
            child: SpinKitWave(
              size: appWidth/15,
              color: Colors.black,
            ),
          );
        } 
        else {
          return StaggeredGridView.countBuilder(
            controller: _scrollController,
            crossAxisCount: 3,
            addRepaintBoundaries: true,
            itemCount: snapshot.data.length,
            staggeredTileBuilder: (_) => StaggeredTile.fit(1),
            itemBuilder: (context, index) {
              RndNum = rnd.nextInt(3);
              return GestureDetector(
                child: Card(
                  child: Container(
                    height: (RndNum == 1)
                        ? (appHeight / 3)
                        : (RndNum == 2)
                            ? (appHeight / 4)
                            : (RndNum == 3) ? (appHeight / 5) : (appHeight / 6),
                    //using cached images to load them faster
                    child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: snapshot.data[index].url,
                        errorWidget: (context, url, error){
                          Icon(Icons.error);
                        },
                      ),
                  ),
                ),
                onTap: () {
                  //onTap navigate to a page which has more information about the image
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) {
                        return MoreInfo(
                            snapshot.data[index].user_name,
                            snapshot.data[index].website_user_name,
                            snapshot.data[index].url,
                            snapshot.data[index].description,
                            snapshot.data[index].alt_description,
                            snapshot.data[index].regular_image_url,
                            snapshot.data[index].tags,
                            snapshot.data[index].profile_image,
                            );
                      },
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
    };
    return buildGrid();
  }
  
}

//class to represent the image info
class UImage {
  final String user_name;
  final String website_user_name;
  final String description;
  final String alt_description;
  final String url;
  final List tags;
  final String profile_image;
  final String regular_image_url;

  UImage(this.user_name, this.website_user_name, this.description, this.alt_description, this.url, this.regular_image_url,
      this.tags, this.profile_image);
}
 
//adding search to the app
class ProfileSearch extends SearchDelegate<Container> {

  var tagsList = tags_list;
  var defaultList = ['New This Week', 'Undisturbed Pattern Wallpapers', 'Patterns and Textures',
                    'Dark and Moody', 'Rainy Days', 'Denim for Days', 'Blurred/in motion', 
                    'Floral Beauty', 'Summer Tones', 'International Women’s Day 2019 — Editorial Selects',
                    "International Women's Day", 'Light-Washed Tones', 'Dark Portraits', 
                    'Double Exposure', 'Flowers Contained'];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear, color: Colors.red,),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios, color: Colors.black,),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    y = [];
    return StaggeredView(query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    var appHeight = MediaQuery.of(context).size.height;
    var appWidth = MediaQuery.of(context).size.width;

    final suggestionsList = tagsList.where((p) => p.toLowerCase().startsWith(query.toLowerCase())).toList();
    
    //return listview of 15 elements or less with appropriate results
    return Container(
      child: ListView.builder(
        itemCount: (suggestionsList.length < 16)?suggestionsList.length:15,
        itemBuilder: (context, index){
          return GestureDetector(
              child: Container(
              margin: EdgeInsets.only(left: appWidth/60,top: appHeight/100,right: appWidth/60),
              height: appHeight/6,
              child: Row(
                children: <Widget>[
                  Expanded(child: Text(suggestionsList[index])),
                  Expanded(
                    child: Container(
                    child: FutureBuilder(
                      future: UnsplashImages(suggestionsList[index]),
                      builder: (context, snapshot){
                        if(snapshot.data == null){
                          return Container();
                        }
                        else{
                          //listview to show sample images of each query
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 5,
                            itemBuilder: (context, index){
                              return Container(
                                width: appWidth/4,
                                child: Image(image: NetworkImage(snapshot.data[index].url),fit: BoxFit.cover,),
                                padding: EdgeInsets.only(left: appWidth/80,bottom: appHeight/100),
                              );
                            },
                          );
                        }
                      },
                    ),
                      ),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(width: appWidth/2000))
              ),
            ),
            onTap: (){
              query = suggestionsList[index];
              showResults(context);
            },
          );
        },
      ),
    );
  }
  }
