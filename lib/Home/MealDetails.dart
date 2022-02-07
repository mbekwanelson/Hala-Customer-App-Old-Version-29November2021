import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mymenu/Authenticate/Auth.dart';
import 'package:mymenu/Home/AfterCheckOut.dart';
import 'package:mymenu/Models/ConfirmCheckOut.dart';
import 'package:mymenu/Models/PromoCheckOut.dart';
import 'package:mymenu/Models/Promotion.dart';
import 'package:mymenu/Models/Shop.dart';
import 'package:mymenu/Models/cardPaymentDetail.dart';
import 'package:mymenu/OzowPayment/OzowPayment.dart';
import 'package:mymenu/Shared/Database.dart';
import 'package:mymenu/Shared/Loading.dart';
import 'package:mymenu/States/AfterCheckOutState.dart';
import 'package:mymenu/States/MealDetailsState.dart';
import 'package:provider/provider.dart';

import 'CheckOut.dart';
class MealDetails extends StatefulWidget {
  List<ConfirmCheckOut> meals ;
  //MealDetail Object
  bool card;
  Shop shop;
  double subtotal;
  PromoCheckOut promo;
  dynamic user;
  cardPaymentDetail cardPayment;
  String promoApplied;
  String category;


  MealDetails({this.card,this.meals,this.shop,this.subtotal,this.promo,this.user,this.cardPayment,this.promoApplied,this.category});
  @override
  _MealDetailsState createState() => _MealDetailsState();
}

class _MealDetailsState extends State<MealDetails> {
  double deliveryFee;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    MealDetailState().calculateDelivery(widget.shop).then((value){
      setState(() {
        deliveryFee=value;
      });
    });

  }
  @override
  Widget build(BuildContext context) {
    double cardFee = 0.0;
    double promoValue=0.0;
    print('${widget.category} Meal Details Category');

    if(widget.card==true){
      cardFee =widget.subtotal*(0.04);
    }
    if(widget.promo.promoValue>0){
      promoValue=widget.subtotal*(widget.promo.promoValue);
    }

    return deliveryFee==null ? Loading(): Scaffold(
      appBar: AppBar(
        title:Text("Order Summary"),
        centerTitle: true,
        backgroundColor: Colors.black87,
      ),
      body:Center(
        child: Container(
          child: SingleChildScrollView(

            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Meal Items",style: TextStyle(
                  letterSpacing: 2
                ),),
                Divider(
                  color: Colors.black,
                ),
                for(ConfirmCheckOut order in widget.meals)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        Text("--- ${order.title}"),
                        Text("x ${order.quantity.toString()}"),
                        Text("R ${order.price.toStringAsFixed(2)}")
                      ],
                    ),
                  ),

                Text("Fees",style: TextStyle(
                    letterSpacing: 2
                ),),
                Divider(
                  color: Colors.black,
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("--- Delivery fee"),
                      Text("R ${deliveryFee.toStringAsFixed(2)}")
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("--- Card processing fee"),
                      Text("R ${cardFee.toStringAsFixed(2)}")
                    ],
                  ),
                ),
                Text("Discounts",style: TextStyle(
                    letterSpacing: 2
                ),),
                Divider(
                  color: Colors.black,
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("--- Promo discount"),
                      Text("R ${promoValue.toStringAsFixed(2)}")
                    ],
                  ),
                ),
                Divider(
                  color: Colors.black,
                ),
                Container(
                  height: 40,

                  color: Colors.black87,

                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical:10,horizontal:20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("--- Total",
                        style: TextStyle(
                          color:Colors.white
                        ),),
                        Text("R ${(widget.subtotal+cardFee+deliveryFee-promoValue).toStringAsFixed(2)}",
                        style: TextStyle(
                          color:Colors.white
                        ),)
                      ],
                    ),
                  ),
                ),


                OutlinedButton(
                onPressed: () async{
                          if(widget.card){

                            String isOperational = await Auth().isShopOperational(widget.shop.shopName,widget.category);

                            if(isOperational =="Closed") {
                              infoDialog(
                                  context,
                                  "${widget.shop.shopName} is Closed, Trading hours ${widget.shop.openingTime.substring(11,16)} - ${widget.shop.closingTime.substring(11,16)}",
                                  positiveAction: (){},
                                  positiveText: "Close",
                                  neutralText: "  ",
                                  negativeAction: (){},
                                  negativeText: "     "
                              );
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CheckOut(
                                          shop: widget.shop,
                                          category: widget.category)));
                            }else {
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) {
                                        return RedirectToOzow(
                                            amount: (widget.subtotal + cardFee +
                                                deliveryFee - promoValue)
                                                .toStringAsFixed(2),
                                            deliveryFee: deliveryFee,
                                            customerOrderDetail:
                                            widget.cardPayment,
                                            category: widget.category);
                                      }
                                  )
                              );
                            }
                          }
                          else{
                            Position position = await Geolocator().getCurrentPosition(
                            desiredAccuracy: LocationAccuracy.high);
                             await Database().loadLocation(position.latitude, position.longitude);

                            for (int i = 0; i < widget.meals.length; i++){

                              print('${widget.category} Category');
                              String isOperational = await Auth().isShopOperational(widget.shop.shopName,widget.category);
                              if(isOperational =="Closed"){
                                infoDialog(
                                    context,
                                    "${widget.shop.shopName} is Closed, Trading hours ${widget.shop.openingTime.substring(11,16)} - ${widget.shop.closingTime.substring(11,16)}",
                                    positiveAction: (){},
                                    positiveText: "Close",
                                    neutralText: "  ",
                                    negativeAction: (){},
                                    negativeText: "     "
                                );
                                Navigator.pop(context);
                                Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CheckOut(
                                              shop: widget.shop,
                                              category: widget.category)));
                              }else{

                                await Auth().checkOutApprovedCash(widget.meals.elementAt(i), widget.promo.price, widget.promo.index, widget.promoApplied, deliveryFee, widget.category);


                                if(widget.meals.length - i  == 1)
                                {
                                  // only after the last order has been checked out on db
                                  //await Auth().checkOutApprovedCash(widget.meals.elementAt(i), widget.promo.price, widget.promo.index, widget.promoApplied, deliveryFee, widget.category);


                                       Navigator.pop(context);
                                       Navigator.push(
                                           context,
                                           MaterialPageRoute(
                                               builder: (context) =>
                                                   StreamProvider.value(
                                                       value: AfterCheckOutState()
                                                           .getShopProgress(uid: widget.user),
                                                       child: AfterCheckOut())));


                                  }
                              }
                          }
                        }
                          },
                    child: Text("Check Out",
                    style:TextStyle(color:Colors.black87))
                )

              ],
            ),
          ),
        ),
      )
    );
  }
}
