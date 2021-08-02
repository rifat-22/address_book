class PlaceAutofill{
  final String description;
  final String placeId;

  PlaceAutofill({this.description,this.placeId});

  factory PlaceAutofill.fromJson(Map<String, dynamic> json){
    return PlaceAutofill(
        description: json['description'],
        placeId: json['place_id']
    );
  }
}