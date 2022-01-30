
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mymenu/Home/Description.dart';
import 'package:mymenu/Models/FoodItem.dart';

class MyListViewPhone extends StatefulWidget {
  List<FoodItem> foodAndConnect;
  String category;
  MyListViewPhone({this.foodAndConnect,this.category});
  @override
  _MyListViewPhoneState createState() => _MyListViewPhoneState();
}

class _MyListViewPhoneState extends State<MyListViewPhone> {

  void _showSettingsPanel(FoodItem food){
    showModalBottomSheet(context: context, builder:(context){
      //builder shows widget tree to display in bottom sheet
      return Container(
        padding:EdgeInsets.symmetric(vertical: 20,horizontal: 60),
        child:Description(food:food, category : widget.category),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Expanded(
      child: Container(
        height:screenSize.height*0.7,


        child:ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: widget.foodAndConnect.length,
            itemBuilder: (context,index){
              return Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20,20),
                child: Container(
                  //height: 220,
                  //height: screenSize.height*0.3,

                  // width:300,
                  width:screenSize.width*0.1,
                  child: GestureDetector(
                    onTap: (){

                      _showSettingsPanel(widget.foodAndConnect[index]);
                    },
                    child: Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.fromLTRB(20, 20, 0,0),
                            padding: const EdgeInsets.all(1.0),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black,width:7)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image(
                                  image: NetworkImage(widget.foodAndConnect[index].image),
                                  fit:BoxFit.cover,
                                  height: 200,
                                  width: 200,
                              ),
                            ),
                            height: 100,
                            width: MediaQuery.of(context).size.width * 0.30,
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(0, 20, 0,0),
                            padding: const EdgeInsets.all(1.0),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black,width:7)
                            ),
                            height: 100,
                            width: 180,
                             child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(widget.foodAndConnect[index].title,style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        ),
                                        Text(widget.foodAndConnect[index].price.toStringAsFixed(2)),
                                        TextButton(
                                          style: ButtonStyle(
                                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(18),
                                                  side: BorderSide(color: Colors.red)
                                              ),
                                            ),
                                            backgroundColor : MaterialStateProperty.all<Color>(Colors.black),
                                          ),
                                          onPressed: () {
                                              _showSettingsPanel(widget.foodAndConnect[index]);
                                          },
                                          child: Text('Add',style: TextStyle(
                                            color: Colors.white,
                                          ),
                                          ),
                                        )

                                      ],
                                    ),
                                  )
                                ],
                              ),
                           ),
                        ],
                      ),
                    ) ,
                  ),
                ),

              );
            }
        ),
      ),
    );

  }
}
