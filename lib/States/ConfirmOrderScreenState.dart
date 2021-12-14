

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mymenu/Authenticate/Auth.dart';
import 'package:mymenu/Models/ConfirmOrder.dart';

class ConfirmOrderScreenState{

  List<ConfirmOrder> _ordersPlaced(DocumentSnapshot snapshot){
    print("There");
    print("You have ordered ${snapshot.data.length} Items");
    return null;
  }



  Future confirmOrders()async{
    List<ConfirmOrder> confirmOrders = [];
    dynamic uid = await Auth().inputData();
    await Firestore.instance
        .collection("OrdersShops")
        .document("OrdersShops")
        .collection("Food and Connect")
        .document(uid)
        .snapshots()
        .forEach((element) {
              element.data.forEach((key, value) {
                //print(" key = $key : value = ${value["title"]}");
                confirmOrders.add(
                    ConfirmOrder(
                        orderName: value['title'],
                        price: value['price'].toDouble(),
                        quantity: value['quantity'],
                        date: value['date'].toDate(),
                        shopName: "Food and Connect"
                    )
                );
              });
              print(element.data.length);
        });

    await Future.delayed(const Duration(seconds: 1), () => "1");
    return confirmOrders;
  }
}