import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;

class LocationSelectionMap extends StatefulWidget {
  static LocationData lastLocationData;
  final double initialLatitude;
  final double initialLongitude;
  final bool buttonOnly;
  final Function(LatLng) onConfirm;
  final Function(double latitude, double longitude) onLocationChanged;
  final String title;

  LocationSelectionMap({this.initialLatitude, this.initialLongitude, this.buttonOnly=false, this.onConfirm, this.onLocationChanged, this.title="Kaart"});

  @override
  _LocationSelectionMapState createState() => _LocationSelectionMapState();
}

enum _LocationStatus { 
  unknown, 
  disabled, 
  denied, 
  working 
}

enum _MyLocationStatus {
  loading,
  ready
}

class _LocationSelectionMapState extends State<LocationSelectionMap> with AutomaticKeepAliveClientMixin {
  static final CameraPosition _defaultCameraPosition = CameraPosition(
    target: LatLng(52.100833, 5.646111),
    zoom: 7,
  );

  final Location location = Location();
  _LocationStatus _locationStatus = _LocationStatus.unknown;
  _MyLocationStatus _myLocationStatus = _MyLocationStatus.ready;
  String address = "Nog geen locatie geselecteerd.";
  
  Completer<GoogleMapController> _controller = Completer();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Marker selectionMarker;
  static int _nextMarkerId = 0;

  @override
  void initState() {
    super.initState();

    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      setSelectionMarker(LatLng(widget.initialLatitude, widget.initialLongitude), moveCamera: true, animateCamera: false);
    }
    else if (LocationSelectionMap.lastLocationData != null &&
        LocationSelectionMap.lastLocationData.time > DateTime.now().millisecondsSinceEpoch - Duration(minutes: 5).inMilliseconds ) {
      setSelectionMarker(LatLng(LocationSelectionMap.lastLocationData.latitude, LocationSelectionMap.lastLocationData.longitude), moveCamera: true, animateCamera: false);
    }
    else {
      enableLocation(false).then((_LocationStatus newLocationStatus) async {
        if (newLocationStatus == _LocationStatus.working) {
          if (!this.mounted)
            return;
          setState(() {
            _myLocationStatus = _MyLocationStatus.loading;
          });
          LocationData locationData = await location.getLocation();
          LocationSelectionMap.lastLocationData = locationData;
          setSelectionMarker(LatLng(locationData.latitude, locationData.longitude), moveCamera: true, animateCamera: false);        
          if (!this.mounted)
            return;
          setState(() {
            _myLocationStatus = _MyLocationStatus.ready;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    print("disposed location selection widget");
  }

  Marker setSelectionMarker(LatLng location, {bool moveCamera=false, bool animateCamera=true}) {
    final MarkerId markerId = MarkerId((_nextMarkerId++).toString());

    final Marker marker = Marker(
      markerId: markerId,
      position: location,
    );

    markers.clear();
    if (!this.mounted)
      return null;
    setState(() {
      selectionMarker = marker;
      markers[markerId] = selectionMarker;
    });

    setAddressFromLocation(location);

    if (widget.onLocationChanged != null)
      widget.onLocationChanged(location.latitude, location.longitude);

    if (!moveCamera || widget.buttonOnly)
      return marker;
    
    _controller.future.then((GoogleMapController mapController){
      if (mapController == null)
        return null;

      CameraUpdate cameraUpdate = CameraUpdate.newCameraPosition(
        CameraPosition(
          target: location,
          zoom: 18
        )
      );

      if (animateCamera) {
        mapController.animateCamera(cameraUpdate);
      }
      else {
        mapController.moveCamera(cameraUpdate);
      }

      return mapController;
    });
    return marker;
  }

  void setAddressFromLocation(LatLng location) async {
    address = "Locatie naam wordt achterhaald...";
    final Coordinates coordinates = new Coordinates(location.latitude, location.longitude);
    List<Address> addresses;
    // https://github.com/aloisdeniel/flutter_geocoder/issues/29
    // A while loop is used here because sometimes Geocode throws a platform exception.
    // However after waiting a couple milliseconds it works again.
    // It's not pretty but it works.
    bool addressFound = false;
    int maxTries = 200;
    int tryCount = 0;
    while(!addressFound){
      try {
        if (tryCount > maxTries){
          setState(() {
            address = "Kon locatie naam niet achterhalen.";
          });
          return;
        }
        tryCount++;
        addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
        addressFound = true;
      } catch(e) {
        if(!mounted)
          return;
        sleep(Duration(milliseconds: 20));
      }
    }
    if(addresses.length == 0 || !mounted)
      return;
    if(addresses.first.subAdminArea == null)
      print(location);
    setState(() {
      address = addresses.first.subAdminArea;
    });
  }

  void onMyLocationButton() async {
    setState(() {
      _myLocationStatus = _MyLocationStatus.loading;
    });

    _LocationStatus newLocationStatus = await enableLocation(true);

    if(newLocationStatus != _LocationStatus.working) {
      if (!this.mounted)
        return;
      setState(() {
        _myLocationStatus = _MyLocationStatus.ready;
      });
      return;
    }

    LocationData locationData = await location.getLocation();
    LocationSelectionMap.lastLocationData = locationData;

    setSelectionMarker(LatLng(locationData.latitude, locationData.longitude), moveCamera: true);

    if (!this.mounted)
      return;
    setState(() {
      _myLocationStatus = _MyLocationStatus.ready;
    });
  }

  void confirmSelection() {
    if(widget.onConfirm != null)
      widget.onConfirm(selectionMarker.position);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return widget.buttonOnly ? 
    OutlineButton(
      padding: EdgeInsets.symmetric(vertical: 20),
      borderSide: BorderSide(
        color: theme.accentColor
      ),
      onPressed: openFullMapPage,
      child: Text(address),
      // child: Text("Text"),
    )
    : Stack(children: [
      GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _defaultCameraPosition,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        onTap: setSelectionMarker,
        markers: Set<Marker>.of(markers.values),
        compassEnabled: true,
        indoorViewEnabled: true,
        buildingsEnabled: true,
        cameraTargetBounds: CameraTargetBounds(LatLngBounds(
          southwest: LatLng(50.803721015, 3.31497114423),
          northeast: LatLng(53.5104033474, 7.09205325687))),
        zoomControlsEnabled: false,
        minMaxZoomPreference: MinMaxZoomPreference(7, 50),
      ),
      Align(
        alignment: Alignment.bottomRight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20),
              child: FloatingActionButton(
                child: _myLocationStatus == _MyLocationStatus.loading ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ) : Icon(
                  Icons.my_location
                ),
                onPressed: onMyLocationButton,
                heroTag: "myLocationButton",
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: FloatingActionButton.extended(
                onPressed: confirmSelection,
                backgroundColor: selectionMarker == null ? theme.disabledColor : null,
                label: Text("Selecteer"),
                icon: Icon(Icons.check),
              ),
            ),
          ],
        ),
      ),
      Align(
        alignment: Alignment.topCenter,
          child: Padding(
          padding: const EdgeInsets.all(15),
          child: Text(address),
        ),
      ),
    ]);
  }

  Future<_LocationStatus> enableLocation(bool promptUser) async {
    // Check if location service is enabled
    bool locationServiceEnabled = await location.serviceEnabled();
    if (!locationServiceEnabled) {
      if (promptUser) locationServiceEnabled = await location.requestService();
      if (!locationServiceEnabled) {
        if(promptUser)
          Scaffold.of(context).showSnackBar( SnackBar(content: Text("Locatie service is uitgeschakeld.\nDe huidige locatie kan niet worden achterhaald.\n\nZet locatie toestemming aan in het instellingen scherm.")));
        setState(() {
          _locationStatus = _LocationStatus.disabled;
        });
        return _locationStatus;
      }
    }

    // Check if location permission is granted
    PermissionStatus locationPermission = await location.hasPermission();
    if (locationPermission != PermissionStatus.granted) {
      locationPermission = await location.requestPermission();
      if (locationPermission != PermissionStatus.granted) {
        if (promptUser)
          showSnackbarForLocationPermission("De app heeft geen toestemming om de locatie service te gebruiken.\nDe huidige locatie kan niet worden achterhaald.\n\nZet locatie toestemming aan in het instellingen scherm.");
        setState(() {
          _locationStatus = _LocationStatus.denied;
        });
        return _locationStatus;
      }
    }

    // Location service is enabled and permission is granted
    setState(() {
      _locationStatus = _LocationStatus.working;
    });
    return _locationStatus;
  }

  void showSnackbarForLocationPermission(String message) {
    Scaffold.of(context).showSnackBar( SnackBar(
      content: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text(message)
          ),
          Expanded(
            flex: 1,
            child: RaisedButton(
              onPressed: permission_handler.openAppSettings,
              child: Text("Instellingen"),
            ),
          )
        ],
      ))
    );
  }

  void openFullMapPage() async {
    LatLng newLocation = await Navigator.push(context, MaterialPageRoute(builder: (context) => LocationSelectionMapPage(
      initialLatitude: selectionMarker == null ? null : selectionMarker.position.latitude, 
      initialLongitude: selectionMarker == null ? null : selectionMarker.position.longitude,
      title: widget.title,
    )));
    if (newLocation != null) {
      setSelectionMarker(newLocation, moveCamera: true, animateCamera: false);
    }
  }

  @override
  bool get wantKeepAlive => true;
}

class LocationSelectionMapPage extends StatelessWidget {

  final double initialLatitude;
  final double initialLongitude;
  final String title;

  LocationSelectionMapPage({this.initialLatitude, this.initialLongitude, this.title="Kaart"});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: TextStyle(fontFamily: 'Libre Baskerville')),
        centerTitle: true,
      ),
      body: LocationSelectionMap(initialLatitude: initialLatitude, initialLongitude: initialLongitude, onConfirm: (LatLng location) {
        Navigator.pop(context, location);
      },)
    );
  }

}
