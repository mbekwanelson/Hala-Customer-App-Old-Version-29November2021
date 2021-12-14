import 'package:commons/commons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart'as http;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio/src/response.dart' as dresp;

const apiKey = "AIzaSyB6KaI6MDBB2gorARw-DpktzVRRQQTFmZ0";
class GoogleMapsServices {

  Future<String> getRouteCoordinates(LatLng l1, LatLng l2) async {

    // response = await dio.get("/test?id=12&name=wendu");
    // print(response.data.toString());
    // Optionally the request above could also be done as
    try{

      Dio dio = new Dio();
      dresp.Response response;

      /*response = await dio
        .get("https://maps.googleapis.com/maps/api/directions/json",
        queryParameters: {
          "origin": "${l1.longitude},${l2.longitude}",
          "destination": "${l1.latitude},${l2.latitude}",
          "key": apiKey });*/

      response = await dio
          .get("https://maps.googleapis.com/maps/api/directions/json?origin=${l1
          .latitude},${l1.longitude}&destination=${l2.latitude},${l2
          .longitude}&key=$apiKey");

      String resp = response.data.toString();
      String ExtractDrivingDistanceAttributes = resp.substring(resp.indexOf("distance:"), resp.indexOf("}, duration")+1);
      String ExtractDrivingDistanceTextAttributeValue =
      ExtractDrivingDistanceAttributes.substring(
          ExtractDrivingDistanceAttributes.indexOf("text:")+("text:".length),
          ExtractDrivingDistanceAttributes.indexOf("km,")
      );

      /*
        String url = "https://maps.googleapis.com/maps/api/directions/json?origin=${l1
        .latitude},${l1.longitude}&destination=${l2.latitude},${l2
        .longitude}&key=$apiKey";
      */

      // http.Response response = await http.get(url);
      // Map values = jsonDecode(response.data.toString());
      // return values["routes"][0]["legs"][0]["distance"]["value"].toString();

      return ExtractDrivingDistanceTextAttributeValue;
    } catch (e) {

      print("The exception thrown is $e");
      return "30";
    }
  }
}