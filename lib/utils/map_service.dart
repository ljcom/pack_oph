import 'package:flutter/material.dart';
import 'package:location/location.dart';
//import 'package:google_maps/google_maps.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pack_oph/models/preset.dart';
import '../models/oph.dart';
import 'package:geocoder/geocoder.dart';
import '../global.dart' as g;

class MapxPage extends StatefulWidget {
  MapxPage(
      this.f, //this.addressField,
      this.title,
      this.preset);
  //this.onChanged);
  final FrmField f;
  final Preset preset;
  //final FrmField addressField;
  //final LatLng presetLoc;
  final String title;
  //final Function onChanged;
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapxPage> {
  LatLng curLoc;
  LatLng newLoc;
  Set<Marker> _markers = {};
  double scrw = 0;
  double scrh = 0;
  List<Address> addresses = [];
  @override
  void initState() {
    super.initState();
    getLoc();
  }

  void getLoc() async {
    bool getDV = false;
    /*
    if (widget.f.controller.text != '' &&
        widget.f.value.split(',').length < 2) {
      List<Address> x = await Geocoder.google(g.apiKey)
          .findAddressesFromQuery(widget.f.controller.text);
      if (x.length > 0) {
        curLoc = LatLng(x[0].coordinates.latitude, x[0].coordinates.longitude);
        newLoc = curLoc;
        getDV = true;
      }
    } else*/
    if (widget.f != null && widget.f.value.split(',').length == 2) {
      //6°09'02.0"S 106°52'47.0"E -6.150562, 106.879728
      curLoc = LatLng(
          double.tryParse(widget.f.value.split(',')[0]) ?? -6.150562,
          double.tryParse(widget.f.value.split(',')[1]) ?? 106.879728);
      newLoc = curLoc;
      getDV = true;
    }

    if (!getDV) {
      LocationData l = await determinePosition();
      newLoc = LatLng(l.latitude, l.longitude);
      //newLoc = curLoc;
    }

    /*
    _markers.add(
      Marker(
        markerId: MarkerId(widget.title),
        position: curLoc,
        icon: BitmapDescriptor.defaultMarker,
      ),
    );
    */
    //setNewMarker();
    /*
    if (newLoc != null) {
      Geocoder.google(g.apiKey)
          .findAddressesFromCoordinates(
              Coordinates(newLoc.latitude, newLoc.longitude))
          .then((v) {
        addresses = v;
        if (mounted) setState(() {});
      });
    }
*/
    setState(() {});
  }

  Future<LocationData> determinePosition() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        //return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        //return;
      }
    }

    _locationData = await location.getLocation();
    return _locationData;
  }

  void setNewMarker() {
    _markers.clear();
    _markers.add(Marker(
      markerId: MarkerId(widget.title),
      icon: BitmapDescriptor.defaultMarker,
      position: newLoc,
    ));
  }

  Widget bodyWidget() {
    return Stack(children: [
      GoogleMap(
        mapType: MapType.normal,
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        initialCameraPosition: CameraPosition(target: newLoc, zoom: 18),

        onCameraMove: (newPos) {
          newLoc = newPos.target;
          setNewMarker();
          setState(() {});
        },
        //onMapCreated: (GoogleMapController controller) {
        //_controller.complete(controller);
        //},
        markers: _markers,
        onTap: (position) {
          newLoc = position;
          setNewMarker();

/*
        Geocoder.google(g.apiKey)
            .findAddressesFromCoordinates(
                Coordinates(newLoc.latitude, newLoc.longitude))
            .then((v) {
          addresses = v;
          //popupWidget();
          setState(() {});
        });
*/
          //if (onChange != null) onChange();
        },
      ),
      Positioned(
        top: (scrh - 50) / 2,
        right: (scrw - 50) / 2,
        child: new Icon(Icons.person_pin_circle, size: 50, color: Colors.red),
      )
    ]);
  }

  void saveAndBack(String coord, String address) {
    //widget.onChanged([coord, address]);
    Navigator.pop(context, [coord, address]);
  }

/*
  Future<void> popupWidget() async {
    //var addresses = await Geocoder.local.findAddressesFromQuery(query);
    List<Widget> w = [];
    addresses.forEach((a) {
      w.add(Padding(
          padding: EdgeInsets.all(10),
          child: InkWell(
              child: Text(a.addressLine.toString()),
              onTap: () {
                String coord = a.coordinates.latitude.toString() +
                    ',' +
                    a.coordinates.longitude.toString();
                Navigator.pop(context);
                saveAndBack(coord, coord); //a.addressLine.toString());
              })));
    });

    await showDialog<void>(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text('Select your location'),
            children: w,
          );
        });
  }
*/
  Widget bottomWidget() {
    return Container(
        width: scrw,
        padding: EdgeInsets.all(10),
        child: ElevatedButton(
            //elevation: 0,
            //color: g.color1,
            //textColor: Colors.white,
            child: Text('Set this location'),
            onPressed: () {
              String coord = newLoc.latitude.toString() +
                  ',' +
                  newLoc.longitude.toString();

              saveAndBack(coord, coord);
            }));
  }

  @override
  Widget build(BuildContext context) {
    scrw = MediaQuery.of(context).size.width;
    scrh = MediaQuery.of(context).size.height - 100;
    return MaterialApp(
        home: Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(36.0),
          child: AppBar(
            elevation: 0,
            backgroundColor: widget.preset.color2,
            title:
                const Text('Choose Location', style: TextStyle(fontSize: 16)),
          )),
      body: newLoc == null ? Center(child: Text('Loading...')) : bodyWidget(),
      bottomSheet: bottomWidget(),
    ));
  }
}
