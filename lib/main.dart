import 'dart:convert';

import 'package:flutter/material.dart';
import  'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int temprature = 0;
  var loc = 'London';
  var woeid = 44418;
  String weather = "clear";
  String abr = '';
  String error = '';

  String locationApiUrl = "https://www.metaweather.com/api/location/";
  String searchapiurl="https://www.metaweather.com/api/location/search/?query=";

  initState(){
    super.initState();
    fetchLoc();
  }


  Future<void> fetchSearch(String input) async {
    try {
      var searchResult = await http.get(searchapiurl+input);
      var result = json.decode(searchResult.body)[0];
      setState(() {
        loc=result['title'];
        woeid = result['woeid'];
        error='';
      });
    }catch (e) {
      setState(() {
        error="Sorry we don't have such kind of data";
      });
    }
  }

  Future<void> fetchLoc() async {
    var locResult = await http.get(locationApiUrl+woeid.toString());
    var resultLoc = json.decode(locResult.body);
    var consolatedWeather = resultLoc["consolidated_weather"];
    var data = consolatedWeather[0];
    setState(() {
      temprature = data["the_temp"].round();
      weather = data["weather_state_name"].replaceAll(' ','').toLowerCase();
      abr = data['weather_state_abbr'];
    });
  }

  Future<void> onTextFieldSubmitted(String input) async {
    await fetchSearch(input);
    await fetchLoc();
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("images/$weather.png"),
              fit: BoxFit.cover
          ),
        ),
        child: temprature==null?
        Center(child: CircularProgressIndicator(),):
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Center(
                    child: Image.network('https://www.metaweather.com/static/img/weather/png/'+abr+'.png',
                    width: 100,
                    ),
                  ),
                  Center(
                    child: Text(
                      temprature.toString() + "C",
                      style: TextStyle(color: Colors.white,fontSize: 50),
                    ),
                  ),
                  Center(
                    child: Text(
                      loc,
                      style: TextStyle(color: Colors.white,fontSize: 50),
                    ),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  Container(
                    width: 300,
                    child: TextField(
                      onSubmitted: (String input){
                        onTextFieldSubmitted(input);
                      },
                      style: TextStyle(color: Colors.white,fontSize: 30),
                      decoration: InputDecoration(
                      hintText: "Search For Another Location",
                      hintStyle: TextStyle(fontSize: 20,color: Colors.white),
                      prefixIcon: Icon(Icons.search),
                    ),
                    ),
                  ),
                  Text(
                    error,textAlign: TextAlign.center,style: TextStyle(
                      fontSize: 20,
                      color: Colors.red),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
