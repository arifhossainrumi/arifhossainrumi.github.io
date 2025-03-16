import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';

import 'function/locations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dhaka House Rent Predictor',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: RentPredictionScreen(),
    );
  }
}

class RentPredictionScreen extends StatefulWidget {
  @override
  _RentPredictionScreenState createState() => _RentPredictionScreenState();
}

class _RentPredictionScreenState extends State<RentPredictionScreen> {
  final TextEditingController areaController = TextEditingController();
  final TextEditingController bedController = TextEditingController();
  final TextEditingController bathController = TextEditingController();
  String? predictedPrice;
  String? selectedLocation;
  bool isLoading = false;



  Future<void> predictRent() async {
    setState(() {
      isLoading = true;
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Taking longer than expected. Please wait...",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.all(16),
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            action: SnackBarAction(
              label: "OK",
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    });

    final url =
        Uri.parse('https://house-rent-prediction-eg9o.onrender.com/predict');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "Area": int.parse(areaController.text),
        "Bed": int.parse(bedController.text),
        "Bath": int.parse(bathController.text),
        "Location": selectedLocation
      }),
    );

    final data = jsonDecode(response.body);
    setState(() {
      predictedPrice = data['predicted_price'] != null
          ? "Predicted Rent: ${data['predicted_price']} BDT"
          : "Error: ${data['error']}";
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dhaka House Rent Predictor')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: areaController,
                decoration: InputDecoration(labelText: 'Area (sqft)'),
                keyboardType: TextInputType.number),
            TextField(
                controller: bedController,
                decoration: InputDecoration(labelText: 'Number of Beds'),
                keyboardType: TextInputType.number),
            TextField(
                controller: bathController,
                decoration: InputDecoration(labelText: 'Number of Baths'),
                keyboardType: TextInputType.number),
            SizedBox(height: 10),
            DropdownSearch<String>(
              popupProps: const PopupProps.menu(
                title: Text(
                  'Supported Areas',
                  textAlign: TextAlign.center,
                ),
                fit: FlexFit.loose,
                showSearchBox: true,
                showSelectedItems: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    hintText: "Type location name...",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              items: locations,
              onSaved: (value) => selectedLocation = value!,
              dropdownDecoratorProps: const DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Location",
                  border: OutlineInputBorder(),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  selectedLocation = value;
                });
              },
              selectedItem: selectedLocation,
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: predictRent, child: Text('Predict Rent')),
            SizedBox(height: 20),
            if (predictedPrice != null)
              Text(predictedPrice!,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }
}
