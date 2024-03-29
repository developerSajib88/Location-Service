import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:location/location.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});




  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  Location location =  Location();
  bool? _serviceEnabled;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;
  String addressName = "";



  void initLocation()async{
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled!) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled!) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await location.getLocation();
    location.enableBackgroundMode(enable: true);
    location.onLocationChanged.listen((LocationData currentLocation){
      _locationData = currentLocation;
    });

    addressName = await getLocationName(_locationData?.latitude ?? 0.00, _locationData?.longitude ?? 0.00);
    setState(() {});

  }


  Future<String> getLocationName(double latitude, double longitude) async {
    try {
      List<geocoding.Placemark> placeMarks = await geocoding.placemarkFromCoordinates(latitude, longitude);
      geocoding.Placemark place = placeMarks[0];
      return "${place.street}${place.thoroughfare}, ${place.subLocality}, ${place.locality}-${place.postalCode}, ${place.country}";
    } catch (e) {
      return "Location not found";
    }
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initLocation();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Location Service"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Latitude: ${_locationData?.latitude ?? ""}",
            ),
            Text(
              "Longitude: ${_locationData?.longitude ?? ""}",
            ),
            Text("Altitude: ${_locationData?.altitude ?? ""}"),

            Text("Accuracy: ${_locationData?.accuracy ?? ""}"),

            Text("Address: $addressName")
          ],
        ),
      ),

    );
  }
}
