

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mymenu/Authenticate/Auth.dart';
import 'package:mymenu/Models/ConfirmCheckOut.dart';
import 'package:mymenu/Models/PromoCheckOut.dart';
import 'package:mymenu/Models/Promotion.dart';
import 'package:mymenu/Shared/Database.dart';
import 'package:mymenu/Shared/Price.dart';

class CheckOutState with ChangeNotifier{

  List<ConfirmCheckOut> orders = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final price = Price();
  double promo=0;

  CheckOutState(){
  }
  List<ConfirmCheckOut> _ordersFromSnapshot(DocumentSnapshot snapshot) {
    snapshot.data.keys.forEach((element) {
      try {
        if(snapshot[element]["inActive"]==1 && snapshot[element]["checkOut"]!="Yes"){

          ConfirmCheckOut confirmCheckOut = ConfirmCheckOut(
              title:snapshot[element]["title"],
              price:snapshot[element]["price"],
              quantity: snapshot[element]["quantity"],
              time: snapshot[element]["date"],
              shop:snapshot[element]["shop"],
              mealOptions: snapshot[element]["selectedOptions"] ?? []
          );

          //log('THOSE OPTIONS ${confirmCheckOut.mealOptions}');
          //print(confirmCheckOut.mealOptions);

          orders.add(confirmCheckOut);
          notifyListeners();


        }
      }
      catch(e){
        print(e);
      }
    });
    return orders;
  }

  Future userID() async {
    final FirebaseUser user = await _auth.currentUser();
    return user.uid;
  }


  Stream<List<ConfirmCheckOut>> myOrders(String uid){
    return Firestore.instance.collection("OrdersRefined").document(uid).snapshots().map(_ordersFromSnapshot);
  }

  checkOutApproved(List<ConfirmCheckOut> orders) async{
    for(int i =0;i<orders.length;i++){
      FirebaseAnalytics().logEvent(name: "OrderPlaced",parameters: {
        "title":orders[i].title,
        "price":orders[i].price,
        "shop":orders[i].shop,
        "date":orders[i].time,
        "quantity":orders[i].quantity,
      });
      //await Auth().checkOutApproved(orders[i]);
    }
  }

  sendLocation()async{
    Position position = await Geolocator().getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    await Database().loadLocation(position.latitude, position.longitude);
  }

  deleteItem(ConfirmCheckOut order)async{
    await Auth().deleteFromDb(
        order.title);
    notifyListeners();

  }

  double calculateTotal(List<ConfirmCheckOut> ordersSelected,String paymentMethod){
    try {

      return double.parse(
          (price.calculatePrice(ordersSelected,paymentMethod))
              .toStringAsFixed(2));
    }
    catch(e){

    }
  }

  Future<Map<String,dynamic>> _getPromosFromUser()async{
    dynamic uid = await Auth().inputData();
     DocumentSnapshot user =await Firestore.instance.collection("Users").document(uid).get();
      return user['promotions'];
  }

  Future<PromoCheckOut> shopPromo(String shop)async{
    Map<String,dynamic> userPromos = await _getPromosFromUser();
    QuerySnapshot promoQuery = await Firestore.instance.collection("Promotions").getDocuments();
    List<DocumentSnapshot> promos = promoQuery.documents;
    PromoCheckOut promoCheckOut;
    List<String> userPromoKey = userPromos.keys.toList();
    if(userPromoKey.isNotEmpty) {
      for (int i = 0; i < userPromoKey.length; i++) {
        for (int j = 0; j < promos.length; j++) {
          if (promos[j].data['promoCode'] == userPromos[userPromoKey[i]]["promoCode"] &&
              userPromos[userPromoKey[i]]["used"] == "No" &&
              promos[j].documentID == shop) {
            promoCheckOut = PromoCheckOut(
                promoValue: promos[j].data['promoValue'],
                index: userPromoKey[i],
                price: promos[j].data['price'].toDouble() ?? 0
            );
            return promoCheckOut;
          }
        }
      }
    }
    return null;
  }
}