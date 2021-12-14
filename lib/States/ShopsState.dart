import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as l2;
import 'package:location/location.dart' as l;
import 'package:mymenu/Maps/Requests/GoogleMapsServices.dart';
import 'package:mymenu/Models/FoodItem.dart';
import 'package:mymenu/Models/Option.dart';
import 'package:mymenu/Models/Restuarant.dart';
import 'package:mymenu/Models/Shop.dart';




class ShopsState with ChangeNotifier{

  List<FoodItem> food =[];
  final double CUTOFFDISTANCE = 400.00;

  //constructor
  ShopsState();


// GETS Shop MENU

  List<FoodItem> _shopChosenFromSnapshot(QuerySnapshot snapshot){

    try {
      for (int data = 0; data < snapshot.documents.length; data++) {

        food.add(FoodItem(
          id:snapshot.documents[data]["id"],
          title: snapshot.documents[data]["title"],
          image: snapshot.documents[data]["image"],
          price: snapshot.documents[data]["price"],
          category: snapshot.documents[data]["category"],
          shop: snapshot.documents[data]["shop"] ?? "shop",
          inStock: snapshot.documents[data]["inStock"] ?? true,
          //inStock : snapshot.documents[data]["inStock"] ?? true
        ));
      }
    }
    catch(e){
    }
    return food;
  }

  Stream<List<FoodItem>> shopChosen({String category,String shopChosen}){
    //returns snapshot of database and tells us of any changes [provider]
    return Firestore.instance.collection("Options").document(category).collection(category).document(shopChosen).collection("Items").snapshots().map(_shopChosenFromSnapshot);
  }


  // RETURNS ALL RESTAURANTS IN DATABASE

  List<Restaurant> _numRestaurants(QuerySnapshot snapshot){
    return snapshot.documents.map((doc){

      print("categories______________________-${doc.data["categories"]}");
      // returning a brew object for each document
      return Restaurant(
          restaurantName: doc.documentID,
          restaurantBackground: doc.data["picture"],
          categories: doc.data["categories"]
      );
    }).toList();
  }

  Stream<List<Restaurant>> numberRestaurants(){
    //returns snapshot of database and tells us of any changes [provider]
    return Firestore.instance.collection("Restaurants").snapshots().map( _numRestaurants);
  }

  logShopSelected(String shop) {
    FirebaseAnalytics().logEvent(name: "Selected Shop", parameters: {
      "Shop": shop,
    });
  }

  Stream<List<Shop>> getShops({String category,Position currentUserPosition}) async* {
    List<Shop> shops = [];
      CollectionReference collectionReference =  Firestore.instance.collection("Options").document(category).collection(category); //.//snapshots();
       Future<QuerySnapshot> fquerySnapshot = collectionReference.getDocuments();

       QuerySnapshot snapshot = await fquerySnapshot; //.then((snapshot) async {
    try {
      for (int shop = 0; shop < snapshot.documents.length; shop++) {
        double lat = snapshot.documents[shop].data["latitude"];
        double long = snapshot.documents[shop].data["longitude"];

        DateTime currentTime = DateTime.now();
        int Year = currentTime.year;
        int Day = currentTime.day;
        int Month = currentTime.month;

        DateTime _CurrentTime = new DateTime(Year,Month,Day, currentTime.hour,currentTime.minute);
        DateTime openingTime = snapshot.documents[shop].data["OpeningTime"].toDate();
        DateTime _OpeningTime = new DateTime(Year,Month,Day, openingTime.hour,openingTime.minute);
        DateTime closingTime = snapshot.documents[shop].data["ClosingTime"].toDate();
        DateTime _ClosingTime =  new DateTime(Year,Month,Day, closingTime.hour, closingTime.minute);
        bool isShopOperating = _CurrentTime.isAfter(_OpeningTime)  && _CurrentTime.isBefore(_ClosingTime);

        final l2.Distance distance = new l2.Distance();
        double km = 0.00;
        String carRouteDistance = await GoogleMapsServices()
            .getRouteCoordinates(
            LatLng(currentUserPosition.latitude, currentUserPosition.longitude),
            LatLng(lat, long));

        print("-------------------------------- Car Route Distance           ------------------");
        print(carRouteDistance);
        print("-------------------------------- Car Route Distance Printed   ------------------");

        km = double.parse(carRouteDistance) / 1000;
        if (km <= CUTOFFDISTANCE) {
          shops.add(Shop(
            shopName: snapshot.documents[shop].data["name"],
            shopBackground: snapshot.documents[shop].data["background"],
            categories: snapshot.documents[shop].data["categories"],
            category: snapshot.documents[shop].data["category"],
            longitude: long,
            latitude: lat,
            isShopOperating: isShopOperating,
            openingTime : _OpeningTime.toString(),
            closingTime : _ClosingTime.toString(),
          ));
        }
      }
    }
    catch(a,e){
      print(e);
      print(a);
    }

       yield shops;
    }
}