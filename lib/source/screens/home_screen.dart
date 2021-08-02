
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_map/blocs/all_blocs.dart';
import 'package:google_map/models/place.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Completer<GoogleMapController> _mapController = Completer();

  StreamSubscription locationSubscription;

  StreamSubscription boundsSubscription;

  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(23.8103, 90.4125),
    zoom: 14.4746,
  );

  @override
  void initState() {
    final blocks= Provider.of<AllBlocs>(context,listen: false);
    locationSubscription = blocks.selectedLocation.stream.listen((place) {
      if (place != null){
        _goToPlace(place);
      }
    });
    boundsSubscription = blocks.bounds.stream.listen((bounds) async{
      final GoogleMapController controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50.0));
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {

    final blocks= Provider.of<AllBlocs>(context,listen: false);
    blocks.dispose();
    locationSubscription.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blocks = Provider.of<AllBlocs>(context);
    return Scaffold(
      body:(blocks.currentLocation == null)?
          Center(
            child: CircularProgressIndicator(),
          )
     : ListView(
        children: [
          Padding(
            padding:  EdgeInsets.all(8.0),
            child:  TextField(
              decoration: InputDecoration(
                hintText: 'Search Loaction', suffixIcon: Icon(Icons.search)
              ),
              onChanged: (value) => blocks.searchPlaces(value),
            ),
          ),
          Stack(
            children: [
              Container(
                height: 300,
                child: GoogleMap(
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  markers: Set<Marker>.of(blocks.markers),
                  initialCameraPosition: CameraPosition(
                      target: LatLng(blocks.currentLocation.latitude, blocks.currentLocation.longitude), zoom: 14
                  ),
                  onMapCreated: (GoogleMapController controller){
                    _mapController.complete(controller);
                  },
                ),



                ),
              if (blocks.searchResults != null &&
                  blocks.searchResults.length != 0)
                Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  backgroundBlendMode: BlendMode.darken,
                ),
              ),
              if (blocks.searchResults != null &&
                  blocks.searchResults.length != 0)
              Container(
                height: 300,
                child: ListView.builder(
                  itemCount: blocks.searchResults.length,
                    itemBuilder: (context,index){
                    return ListTile(
                      title: Text('${blocks.searchResults[index].description}',
                      style: TextStyle(color: Colors.white),
                      ),
                      onTap: (){
                        blocks.setSelectedLocation(
                        blocks.searchResults[index].placeId
                        );
                      },
                    );
                }
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Popular Places', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8.0,
              children: [
                FilterChip(
                    label: Text('Bank'),
                    onSelected: (val) => blocks.togglePlaceType('bank', val),
                  selected: blocks.placeType == 'bank',
                  selectedColor: Colors.blueGrey,
                ),
                FilterChip(
                  label: Text('Bus Station'),
                  onSelected: (val) => blocks.togglePlaceType('bus_station', val),
                  selected: blocks.placeType == 'bus_station',
                  selectedColor: Colors.blueGrey,
                ),
                FilterChip(
                  label: Text('ATM'),
                  onSelected: (val) => blocks.togglePlaceType('atm', val),
                  selected: blocks.placeType == 'atm',
                  selectedColor: Colors.blueGrey,
                ),
                FilterChip(
                  label: Text('Park'),
                  onSelected: (val) => blocks.togglePlaceType('park', val),
                  selected: blocks.placeType == 'park',
                  selectedColor: Colors.blueGrey,
                ),
                FilterChip(
                  label: Text('Hospital'),
                  onSelected: (val) => blocks.togglePlaceType('hospital', val),
                  selected: blocks.placeType == 'hospital',
                  selectedColor: Colors.blueGrey,
                ),


              ],
            ),
          )

        ],
      ),
    );
  }
  Future<void> _goToPlace(Place place) async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(
                place.geometry.location.lat, place.geometry.location.lng),
            zoom: 14.0),
      ),
    );
  }

}
