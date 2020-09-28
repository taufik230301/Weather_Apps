import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int temprature;
  String location = "New York";
  int woeid = 44418;
  String weather = "clear";
  String abbreviation = '';
  String errorMessage = '';

  String serachAPIUrl =
      'https://www.metaweather.com/api/location/search/?query=';
  String locationAPIUrl = 'https://www.metaweather.com/api/location/';

  @override
  void initState() {
    super.initState();
    fetchLocation();
  }

  void fetchSearch(String input) async {
    try {
      var searchResult = await http.get(serachAPIUrl + input);
      var result = json.decode(searchResult.body)[0];

      setState(() {
        location = result["title"];
        woeid = result["woeid"];
        errorMessage = '';
      });
    } catch (error) {
      setState(() {
        errorMessage = 'Maaf!!!, Kota yang anda tujukan tidak dikenal';
      });
    }
  }

  void fetchLocation() async {
    var locationResult = await http.get(locationAPIUrl + woeid.toString());
    var result = json.decode(locationResult.body);
    var consolatedweather = result["consolidated_weather"];
    var data = consolatedweather[0];

    setState(() {
      temprature = data["the_temp"].round();
      weather = data["weather_state_name"].replaceAll(' ', '').toLowerCase();
      abbreviation = data["weather_state_abbr"];
    });
  }

  void onTextSubmitted(String input) async {
    // ignore: await_only_futures
    await fetchSearch(input);
    // ignore: await_only_futures
    await fetchLocation();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/$weather.png'), fit: BoxFit.cover)),
        child: temprature == null
            ? Center(child: CircularProgressIndicator())
            : Scaffold(
                backgroundColor: Colors.transparent,
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Center(
                          child: Image.network(
                            'https://www.metaweather.com/static/img/weather/png/$abbreviation.png',
                            width: 100,
                          ),
                        ),
                        Center(
                            child: Text(temprature.toString() + 'C',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 60))),
                        Center(
                            child: Text(
                          location,
                          style: TextStyle(color: Colors.white, fontSize: 60),
                        ))
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Container(
                          width: 300,
                          child: TextField(
                            onSubmitted: (String input) {
                              onTextSubmitted(input);
                            },
                            style: TextStyle(color: Colors.white, fontSize: 25),
                            decoration: InputDecoration(
                                hintText: 'Cari location ...',
                                hintStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.white,
                                )),
                          ),
                        ),
                        Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red, fontSize: 20),
                        )
                      ],
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
