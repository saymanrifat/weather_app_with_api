import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:weather_app_with_api/model/getting_icon.dart';
import 'package:weather_app_with_api/model/weather_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<WeatherData> weatherData = [];
  bool inProgress = false;

  var myCityName = "Loading";

  @override
  void initState() {
    super.initState();
    //Getting Location Permission
    _determinePosition();

    print('call the api');
    getLocation();
  }

  getLocation() async {
    inProgress = true;

    setState(() {});
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    print(position.latitude);
    print(position.longitude);
    List<Placemark> placemark =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    print(placemark[0].street);
    myCityName = placemark[0].street.toString();

    late Response response;

    try {
      response = await get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude.toString()}&lon=${position.longitude.toString()}&appid=48529ee6ace6bc66d6df70d8ec41fdd0'));
    } catch (error) {
      print('Faild to Fatch Data');
    }

    Map<String, dynamic> decodedResponse = jsonDecode(response.body);

    print(decodedResponse);

    if (response.statusCode == 200) {
      weatherData.clear();

      weatherData.add(WeatherData(
        decodedResponse['weather'][0]['description'],
        getTime(),
        convertTemp(decodedResponse['main']['temp']),
        convertTemp(decodedResponse['main']['temp_max']),
        convertTemp(decodedResponse['main']['temp_min']),
        decodedResponse['weather'][0]['icon'].toString(),
      ));

      print(decodedResponse['main']['temp_max']);
      print(decodedResponse['main']['temp_min']);
      print(decodedResponse['main']['temp']);
    }
    inProgress = false;
    setState(() {});
  }

  String getTime() {
    return DateFormat.jm().format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ostad Weather"),
        actions: [
          IconButton(
              onPressed: () {
                getLocation();
              },
              icon: const Icon(Icons.refresh)),
        ],
        backgroundColor: Colors.red,
      ),
      body: inProgress
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.red, Colors.orange, Colors.yellow]),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    myCityName,
                    style: const TextStyle(
                        fontSize: 38, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Updated: ${weatherData[0].time}",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w200,
                        color: Colors.white),
                  ),
                  const Gap(50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        LoadIcons.loadIcon(weatherData[0].iconCode),
                        height: 50,
                        width: 50,
                      ),
                      const Gap(30),
                      Text(
                        weatherData[0].temp + " \u00b0",
                        style: const TextStyle(
                          fontSize: 42,
                          color: Colors.white,
                        ),
                      ),
                      const Gap(30),
                      Column(
                        children: [
                          Text("Max: ${weatherData[0].maxTemp}",
                              style: const TextStyle(fontSize: 18)),
                          Text("Min: ${weatherData[0].minTemp}",
                              style: const TextStyle(fontSize: 18)),
                        ],
                      ),
                    ],
                  ),
                  Gap(30),
                  Text(
                    weatherData[0].weatherDesc,
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w200,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  String convertTemp(temp) {
    int newTemp = temp.toInt();

    var sum = newTemp - 273.15;

    var result = sum.toInt().toString();

    return result;
  }
}
