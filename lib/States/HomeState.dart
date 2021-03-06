import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:mymenu/Authenticate/Auth.dart';
import 'package:mymenu/Models/FoodItem.dart';
import 'package:mymenu/Models/Meal.dart';
import 'package:mymenu/Models/MealOption.dart';
import 'package:mymenu/Models/Shop.dart';

class HomeState with ChangeNotifier{
  List<Meal> meals =[];
  List<FoodItem> food = [];
  List<FoodItem> pizzas =[];
  List<FoodItem> desserts = [];
  List<FoodItem> drinks = [];
  int tab = 0;
  List<FoodItem> selectedCategory = [];

  category(Shop shop, String category)async{
    //selectedCategory = [];
    tab=1;

   await Firestore.instance.collection("Options").document(shop.category).collection(shop.category)
          .document(shop.shopName).collection("Items")
          .where("category",isEqualTo:category)
          .getDocuments().then((QuerySnapshot categoryItems){
      selectedCategory= [];
      for(int item =0;item<categoryItems.documents.length;item++){
        selectedCategory.add(
            FoodItem(
                title :categoryItems.documents[item].data["title"]?? "no",
                image:categoryItems.documents[item].data["image"] ?? "https://cdn.pixabay.com/photo/2018/03/04/20/08/burger-3199088__340.jpg",
                price : categoryItems.documents[item].data["price"] ?? 0,
                id :categoryItems.documents[item].data["id"] ?? "ai",
                category :categoryItems.documents[item].data["category"] ?? "nja",
                shop: shop.shopName,
                inStock: categoryItems.documents[item].data["inStock"] ?? true
            )
        );
      }
      notifyListeners();


   });

    await Future.delayed(const Duration(seconds: 1), () => "1");

    notifyListeners();

  }

  Future<List<Meal>> allMeals(Shop shop, String category) async {
    List<MealOption> options = [];
    Meal meal;
    List<dynamic> compulsoryOptions = [];
    Map<dynamic,dynamic> numberPerOption = {};
    meals = [];

    await Firestore.instance.collection("Options").document(shop.category).collection(shop.category)
        .document(shop.shopName).collection("Meals").getDocuments().then((value){

          value.documents.forEach((doc) {
            doc.data.forEach((key, value) {
              if(key == 'compulsoryOptions'){
                compulsoryOptions = value.toList();
              }
            });

            meal = Meal(
              shop: shop.shopName,
                title: doc.data['title'],
                initialPrice: doc.data['initial Price'].toDouble(),
                image: doc.data['image']
            );

            doc.data.forEach((key, value) {
              if(key=='Options'){
                // Different options
                for(int optionName = 0;optionName<compulsoryOptions.length;optionName++){
                  numberPerOption = value[compulsoryOptions[optionName]];
                  for(int optionValue =1;optionValue< numberPerOption.length +1;optionValue++){
                    options.add(
                        MealOption(
                            title: doc.data['Options'][compulsoryOptions[optionName]]['Item $optionValue']['title'],
                            price: doc.data['Options'][compulsoryOptions[optionName]]['Item $optionValue']['price'].toDouble(),
                            category:compulsoryOptions[optionName]
                        )
                    );
                  }
                  meal.addOption(options);
                  options = [];
                }
              }
            });
            meals.add(meal);
          });
    });
    tab=2;
    notifyListeners();
    return meals;
  }
}