
import 'package:flutter/material.dart';
import 'package:mymenu/Home/messageDriver.dart';
import 'package:mymenu/Models/ConfirmOrder.dart';
import 'package:mymenu/Shared/Loading.dart';
import 'package:mymenu/States/ConfirmOrderScreenState.dart';
class OrderPlaced extends StatefulWidget {
  @override
  _OrderPlacedState createState() => _OrderPlacedState();
}

class _OrderPlacedState extends State<OrderPlaced> {
  @override
  Widget build(BuildContext context) {
    List<ConfirmOrder> orders = [];
    ConfirmOrderScreenState()
        .confirmOrders()
        .then((value){
            setState(() {
              orders = value;
            });
        });


    return orders ==[] ? Loading():Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title:Text(
            "Delivering your order",
        ),
        centerTitle: true,
      ),
      body:Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(30),
            child: Center(
              child: FlatButton.icon(

                  onPressed: (){
                    setState(() {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => messageDriver())
                      );
                    });
                  },
                  icon: Icon(Icons.message),
                  label: Text(
                      "Message Driver",
                    style:TextStyle(
                      fontSize: 18
                    ) ,
                  )),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: orders.length,
              itemBuilder: (context,index){
              return Card(
                child: Column(
                  children: [
                    Text(orders[index].orderName),
                  ],
                ),
              );
              })
        ],
      )
    );
  }
}
