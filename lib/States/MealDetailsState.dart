

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mymenu/Home/CheckOut.dart';

import 'package:mymenu/Maps/Requests/GoogleMapsServices.dart';
import 'package:mymenu/Models/Shop.dart';

class MealDetailState{

 Future<double> calculateDelivery(Shop shop)async{
  print("SHOP Here : $shop");
   dynamic latitude = shop.latitude;
   dynamic longitude = shop.longitude;
   Position customerLocation = await Geolocator().getCurrentPosition(
       desiredAccuracy: LocationAccuracy.high);
   double km = 0.00;
   String carRouteDistance = await GoogleMapsServices()
       .getRouteCoordinates(
       LatLng(latitude, longitude),
       LatLng(customerLocation.latitude, customerLocation.longitude));
  carRouteDistance = carRouteDistance.replaceAll(",", "");
   km = double.parse(carRouteDistance)/1000;

   if(km<5){
     return 10.00;
   }
   else if(km>5 && km<10){
     return 15.00;
   }
   else{
     return 2.00;
   }



 }


















}