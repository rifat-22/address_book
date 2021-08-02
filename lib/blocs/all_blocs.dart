import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map/models/geometry.dart';
import 'package:google_map/models/location.dart';
import 'package:google_map/models/place.dart';
import 'package:google_map/models/place_autofill.dart';
import 'package:google_map/services/geolocator_service.dart';
import 'package:google_map/services/markers_service.dart';
import 'package:google_map/services/places_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AllBlocs with ChangeNotifier{
  final serviceGeolocator = GeoLocatorService();
  final servicePlaces = PlacesService();
  final markerService = MarkerService();
  StreamController<Place> selectedLocation = StreamController<Place>();
  StreamController<LatLngBounds> bounds = StreamController<LatLngBounds>();
  String placeType;
  Place selectedLocationStatic;

  Position currentLocation;
  List<PlaceAutofill> searchResults;
  List<Marker> markers = List<Marker>();



  AllBlocs(){
    setCurrentLocation();
  }

  setCurrentLocation() async {
    currentLocation = await serviceGeolocator.getCurrentLocation();
    selectedLocationStatic = Place(name: null, geometry: Geometry(location:
    Location(lat: currentLocation.latitude, lng: currentLocation.longitude),),);
    notifyListeners();
  }

  searchPlaces(String searchTerm) async {
    searchResults = await servicePlaces.getAutocomplete(searchTerm);
    notifyListeners();
  }

  setSelectedLocation(String placeId) async {
    var sLocation = await servicePlaces.getPlace(placeId);
    selectedLocation.add(sLocation);
    selectedLocationStatic = sLocation;
    searchResults = null;
    notifyListeners();
  }
  togglePlaceType(String value, bool selected) async {
    if (selected) {
      placeType = value;
    } else {
      placeType = null;
    }

    if (placeType != null) {
      var places = await servicePlaces.getPlaces(
          selectedLocationStatic.geometry.location.lat,
          selectedLocationStatic.geometry.location.lng, placeType);
      markers= [];
      if (places.length > 0) {
        var newMarker = markerService.createMarkerFromPlace(places[0],false);
        markers.add(newMarker);
      }

      var locationMarker = markerService.createMarkerFromPlace(selectedLocationStatic,true);
      markers.add(locationMarker);

      var _bounds = markerService.bounds(Set<Marker>.of(markers));
      bounds.add(_bounds);

      notifyListeners();
    }
  }
  @override
  void dispose() {
    selectedLocation.close();
    bounds.close();
    super.dispose();
  }

}