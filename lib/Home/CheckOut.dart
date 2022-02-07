import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:mymenu/Home/AfterCheckOut.dart';
import 'package:mymenu/Home/MealDetails.dart';
import 'package:mymenu/Home/OrderPlaced.dart';
import 'package:mymenu/Home/messageDriver.dart';
import 'package:mymenu/Maps/MyMap.dart';
import 'package:mymenu/Models/ConfirmCheckOut.dart';
import 'package:mymenu/Models/Order.dart';
import 'package:mymenu/Authenticate/Auth.dart';
import 'package:mymenu/Models/PromoCheckOut.dart';
import 'package:mymenu/Models/Promotion.dart';
import 'package:mymenu/Models/Shop.dart';
import 'package:mymenu/Models/cardPaymentDetail.dart';
import 'package:mymenu/OzowPayment/OzowPayment.dart';
import 'package:mymenu/Shared/Database.dart';
import 'package:mymenu/Shared/Loading.dart';
import 'package:mymenu/Shared/Price.dart';
import 'package:mymenu/States/AfterCheckOutState.dart';
import 'package:mymenu/States/CheckOutState.dart';
import 'package:mymenu/States/MealDetailsState.dart';
import 'package:provider/provider.dart';
import 'package:commons/commons.dart';

class CheckOut extends StatefulWidget {
  @override
  _CheckOutState createState() => _CheckOutState();
  Shop shop;
  String category;
  CheckOut({this.shop,this.category});
}





class _CheckOutState extends State<CheckOut> {

  @override
  Auth _auth = Auth();
  var user;
  String shop;
  PromoCheckOut promo = PromoCheckOut();
  int promoStop = 0;
  String promoApplied;
  String dropdownValue = "Cash";
  int extraCardFee = 2;

  @override
  // ignore: must_call_super
  void initState() {
    // This is the proper place to make the async calls
    // This way they only get called once

    // During development, if you change this code,
    // you will need to do a full restart instead of just a hot reload

    // You can't use async/await here,
    // We can't mark this method as async because of the @override
    _auth.inputData().then((value) {
      // If we need to rebuild the widget with the resulting data,
      // make sure to use `setState`
      setState(() {
        user = value;
        promo.index = '';
        promo.promoValue = 0.0;
        promo.price = 0.0;
        promoApplied = "No";
      });
    });
  }



  Widget build(BuildContext context) {
    print('${widget.category} Checkout Category');

    void _showDetailsPanel(List<ConfirmCheckOut> meals,bool card,Shop shop,double subtotal,promo,user,cardPaymentDetail,isPromoApplied) {


      showModalBottomSheet(isScrollControlled:true, context: context, builder: (context) {

        //builder shows widget tree to display in bottom sheet
        return Container(
          //height:MediaQuery.of(context).size.height,
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 60),
          child: MealDetails(meals: meals,card:card,shop: widget.shop,subtotal:subtotal,promo:promo,user:user,cardPayment: cardPaymentDetail,promoApplied:isPromoApplied,category: widget.category),
        );
      });
    }
    Price price = Price();
    Auth _auth = Auth();

    double calculateTotal(List<ConfirmCheckOut> confirmCheckOut,String paymentMethod) {
      if(price.calculatePrice(confirmCheckOut,paymentMethod) > promo.price){
        if (promoStop == 0) {
          promoApplied = "Yes";
        }

        return price.calculatePrice(confirmCheckOut,paymentMethod);

      } else {
        if (promoStop == 0) {
          promoApplied = "Yes";
        }

        return price.calculatePrice(confirmCheckOut,paymentMethod);
      }
    }

    //List<Order> orders = Provider.of<List<Order>>(context);

    return StreamBuilder(
        stream: Auth().myOrders(user),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Loading();
          }
          price.promo = 0;
          if (promoStop == 0) {
            List<ConfirmCheckOut> checkout = snapshot.data;

            if (checkout.isNotEmpty) {
              CheckOutState().shopPromo(checkout[0].shop).then((value) {
                setState(() {
                  promo = value ??
                      PromoCheckOut(
                          promoValue: 0,
                          index: "0",
                          price:
                              10000.00 // a rediculous amount that should never be reached. if it is the customer needs help
                          );
                  promoStop++;
                  price.promo = promo.promoValue;
                });
              });
            }
          }
          return Container(
            color: Colors.white,
            child: SafeArea(
              child: Column(
                children: <Widget>[

                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                      color: HexColor("#393939"),
                      child: Padding(
                        padding: const EdgeInsets.all(25),
                        child: Center(
                          child: Text(
                            "Promo: ${(promo.promoValue * 100).toStringAsFixed(0)}% off",
                            style: TextStyle(
                              fontSize: 27,
                              color: Colors.white,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.black,width:7)
                                  ),
                                  child: Card(
                                      color: Colors.white,
                                      /*
                                      child: ListTile(
                                        onTap: () {},
                                        //leading:Image.network(orders[index].image),
                                        //contentPadding: EdgeInsets.all(30),
                                        trailing: FlatButton.icon(
                                            onPressed: () async {
                                              await _auth.deleteFromDb(
                                                  snapshot.data[index].title);
                                              setState(() {});
                                            },
                                            icon: Icon(
                                              Icons.delete,
                                            ),
                                            label: Text("Remove")),

                                        title: Column(
                                          children: [
                                            Text(
                                              snapshot.data[index].title ??
                                                  "No title",
                                              style: TextStyle(
                                                fontSize: 25,
                                                //color:Colors.black,
                                                //decoration: TextDecoration.underline,
                                              ),
                                            ),
                                            SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  30,
                                            ),
                                            for (dynamic option in snapshot
                                                .data[index].mealOptions)
                                              Text(option.toString() ?? "")
                                          ],
                                        ),

                                        subtitle: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 15),
                                          child: Center(
                                            child: Text(
                                              "${snapshot.data[index].quantity} X R${snapshot.data[index].price}",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black87),
                                            ),
                                          ),
                                        ),
                                      ),
                                      */
                                      child: Column(
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              Text(
                                                snapshot.data[index].title ??
                                                    "No title",
                                                style: TextStyle(
                                                  fontSize: 25,
                                                  //color:Colors.black,
                                                  //decoration: TextDecoration.underline,
                                                ),
                                              ),
                                              Text(
                                                "X ${snapshot.data[index].quantity} ",
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    color: Colors.black87),
                                              ),
                                              Text(
                                                "R${snapshot.data[index].price}",
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    color: Colors.black87),
                                              ),
                                            ],

                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 10),
                                            child: OutlinedButton.icon(
                                                onPressed: () async {
                                                  await _auth.deleteFromDb(
                                                      snapshot.data[index].title);
                                                  setState(() {});
                                                },
                                                icon: Icon(
                                                  Icons.delete,
                                                  color: Colors.black87,
                                                ),
                                                label: Text("Remove", style: TextStyle(
                                                  color: Colors.black87
                                                ),)
                                            ),
                                          )
                                        ],

                                      ),
                                      elevation: 0),
                                ),
                              ),
                            ],
                          );
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      color: Colors.black87,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: DropdownButton<String>(
                          value: dropdownValue,
                          icon: const Icon(Icons.arrow_drop_down,color: Colors.white,),
                          iconSize: 20,
                          elevation: 16,
                          focusColor: Colors.black87,
                          style: const TextStyle(color: Colors.white),
                          dropdownColor: Colors.black87,
                          onChanged: (String newValue) {
                            setState(() {
                              dropdownValue = newValue;
                            });
                          },
                          underline: SizedBox(),
                          items: <String>['Cash', 'Card']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: value == "Cash" ? Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(value),
                                  SizedBox(width: 5,),
                                  Icon(Icons.attach_money_rounded,color: Colors.white,)
                                ],
                              ) :
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(value),
                                  SizedBox(width: 5,),
                                  Icon(Icons.credit_card,color: Colors.white,),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),

                  Container(
                    height: 50,
                    color: Colors.red[900],
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: FlatButton.icon(
                              //color: Colors.green,
                              color: Colors.red[900],
                              onPressed: () async {
                                dynamic uid = await Auth().inputData();
                                shop = snapshot.data[0].shop;
                                final orders = snapshot.data;
                                final promoIndex = promo.index;
                                final isPromoApplied = promoApplied;
                                final String total =
                                    (calculateTotal(snapshot.data,dropdownValue))
                                        .toStringAsFixed(2);
                                cardPaymentDetail cardPayment =
                                    cardPaymentDetail(
                                        promoApplied: isPromoApplied,
                                        promoIndex: promoIndex,
                                        orders: orders,
                                        promoValue: promo.promoValue);

                                bool card;
                                if(dropdownValue=="Card"){
                                  card = true;
                                }
                                else{
                                  card = false;
                                }
                                double subtotal = price.calculatePrice(snapshot.data,"Cash");

                                print("Checkout Screen" + promoApplied);
                                print("Checkout Screen" + promo.promoValue.toString());
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            StreamProvider.value(
                                                value: AfterCheckOutState()
                                                    .getShopProgress(
                                                    uid: uid),
                                                child: MealDetails(meals: snapshot.data,shop: widget.shop,subtotal: subtotal, card:card,promo:promo,user:user,cardPayment:cardPayment,promoApplied:isPromoApplied,category: widget.category)))
                                );
                              },
                              icon: Icon(
                                Icons.add_shopping_cart,
                                color: Colors.white,
                                size: 30,
                              ),
                              label: Text(
                                "Check Out!",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              )),
                        ),
                      ],
                    ),
                  ), Card(
                    child: Container(
                      color: Colors.black,
                      //color:HexColor("#393939"),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 0),
                          child: Text(
                            "Sub-total = R ${(calculateTotal(snapshot.data,dropdownValue)).toStringAsFixed(2)} ",
                            style: TextStyle(
                              fontSize: 35,
                              color: Colors.white,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
