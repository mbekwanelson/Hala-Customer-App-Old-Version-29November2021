import 'package:flutter/material.dart';
import 'package:mymenu/Authenticate/Auth.dart';
import 'package:mymenu/Home/initMapScene.dart';
import 'package:mymenu/Models/FoodItem.dart';
import 'package:mymenu/Models/example_page.dart';
import 'package:mymenu/OzowPayment/OzowPayment.dart';
import 'package:mymenu/ProgressBar/OrderProgress.dart';
import 'package:mymenu/States/AfterCheckOutState.dart';
import 'package:provider/provider.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AfterCheckOut extends StatefulWidget {
  @override
  _AfterCheckOutState createState() => _AfterCheckOutState();
}

class _AfterCheckOutState extends State<AfterCheckOut> {
  String shopName;
  String progressUpdate;
  String uid;

  @override
  void initState() {
    // TODO: implement initState
    Auth().inputData().then((value){
      setState(() {
        uid = value;
      });
    });
    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    print(uid);
    print(shopName);
    /// Example 02
    final shopsSeen = Provider.of<List<String>>(context);
    var customWidth02 = CustomSliderWidths(
        trackWidth: 1, progressBarWidth: 2);
    var customColors02 = CustomSliderColors(
        trackColor: Colors.white,
        progressBarColor: Colors.orange,
        hideShadow: true);
    var info02 = InfoProperties(
        bottomLabelStyle: TextStyle(
            color: Colors.orangeAccent,
            fontSize: 20,
            fontWeight: FontWeight.w600),
        topLabelText: shopName,
        bottomLabelText: progressUpdate,
        mainLabelStyle: TextStyle(
            color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w100),
        // modifier: (double value) {
        //   final budget = (value).toInt();
        //   return '\$ $budget';
        // }
        );
    CircularSliderAppearance appearance02 = CircularSliderAppearance(
        customWidths: customWidth02,
        customColors: customColors02,
       // infoProperties: info02,
        startAngle: 180,
        angleRange: 270,
        size: 500.0,
        animationEnabled: false);
    var viewModel02 = ExampleViewModel(
        appearance: appearance02,
        min: 0,
        max: 100,
        value: 8,
        pageColors: [Colors.black, Colors.black87]);
    var example02 = ExamplePage(
      viewModel: viewModel02,
    );



    void updateShop() {
      for (String string in shopsSeen) {
        setState(() {
          shopName = string.split('*')[0];
          progressUpdate = string.split('*')[1];
        });
      }
    }

    if (shopsSeen == null ){
      return Scaffold(

          appBar: AppBar(
            title: Text(
              "Order progress",
              style: TextStyle(
                  letterSpacing: 2
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.black,
          ),
          body: Column(

            children: [
              Padding(
                padding: const EdgeInsets.all(60),
                child: Center(
                  child:Text(
                    "Place your order",
                    style: TextStyle(
                      fontSize: 30
                    ),
                  )
                ),
              ),
              Center(
                child:  Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                   child: Container(
                      height: MediaQuery.of(context).size.height*0.4,
                       width: MediaQuery.of(context).size.width*0.6,

                      child:Image(
                       image: AssetImage(
                           "Picture/preparingOrder.gif"
                        ),
                        fit: BoxFit.cover,
                      )

                  ),
                ),
              )
            ],
          )
      );
    }else if (shopsSeen==[] || shopsSeen.length == 0 ){
      return Scaffold(

          appBar: AppBar(
            title: Text(
              "Order progress",
              style: TextStyle(
                  letterSpacing: 2
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.black,
          ),
          body: Column(

            children: [
              Padding(
                padding: const EdgeInsets.all(60),
                child: Center(
                    child:Text(
                      "Preparing your order",
                      style: TextStyle(
                          fontSize: 30
                      ),
                    )
                ),
              ),
              Center(
                child:  Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Container(
                      height: MediaQuery.of(context).size.height*0.4,
                      width: MediaQuery.of(context).size.width*0.6,

                      child:Image(
                        image: AssetImage(
                            "Picture/preparingOrder.gif"
                        ),
                        fit: BoxFit.cover,
                      )

                  ),
                ),
              )
            ],
          )
      );
    }
    else {

      updateShop();
      return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: Text(
              "Shop progress",
              style: TextStyle(
                  letterSpacing: 2
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.black,
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 500,
                child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: shopsSeen.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          IgnorePointer(
                            ignoring:true,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Container(
                              decoration: BoxDecoration(
                              gradient: LinearGradient(
                              colors: viewModel02.pageColors,
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                              tileMode: TileMode.clamp)),
                              child: Center(
                              child: SleekCircularSlider(
                              onChangeStart: (double value) {

                              },
                              onChangeEnd: (double value) {

                              },
                                onChange: (double value){

                                },
                              innerWidget: viewModel02.innerWidget,
                              appearance: CircularSliderAppearance(
                              customWidths: customWidth02,
                              customColors: customColors02,
                              infoProperties:  InfoProperties(
                                  topLabelStyle: TextStyle(
                                      color:Colors.cyan, fontSize: 20, fontWeight: FontWeight.w600,letterSpacing: 2),
                              bottomLabelStyle: TextStyle(
                              color: Colors.orangeAccent, fontSize: 15, fontWeight: FontWeight.w600,letterSpacing: 2),
                              topLabelText: "${shopsSeen[index].split('*')[0]} ", // shop name
                              bottomLabelText: "${shopsSeen[index].split('*')[1]} ", // shop progress update
                              mainLabelStyle: TextStyle(
                              color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w100),

                              // modifier: (double value) {
                              // final budget = (value).toInt();
                              // return ' $budget';
                              // }
                      ),
                          startAngle: 180,
                          angleRange: 270,
                          size: 400.0,
                          animationEnabled: true
                      ), min: viewModel02.min,
                       max: viewModel02.max, initialValue:double.parse(shopsSeen[index].split('*')[2]) , // progress level
                              )),
                              ),
                            ),
                          ),
                          SpinKitPouringHourglass(
                            color: Colors.white,
                            size: 60.0,
                          ),
                        ],
                      );
                    }
                ),
              ),


            ],
          )
      );
    }
  }
}
