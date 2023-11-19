import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String apiUrl = 'https://api.logmeal.es/v2/image/recognition/type';
  final String apiUserToken = 'c286007d2b9a1e3bdef227faa4f7d0a93ed7e5c8';
  String imagePath = '';
  String recognizedMeal = '';

  Future<void> recognizeMeal(String imagePath) async {
    Dio dio = Dio();
    dio.options.headers['Authorization'] = 'Bearer $apiUserToken';

    try {
      Uint8List bytes = await File(imagePath).readAsBytes();
      FormData formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(
          bytes,
          filename: 'image.jpg',
        ),
      });

      Response response = await dio.post(apiUrl, data: formData);

      if (response.statusCode == 200) {
        // Directly use the response data, as it's already decoded JSON
        print('Raw API Response: ${response.data}');

        // Parse and display the recognized meal information
        Map<String, dynamic> data = response.data;
        setState(() {
          recognizedMeal = 'Recognized meal: ${data['food_types'][0]['name']}';
        });
      } else {
        // Handle errors
        setState(() {
          recognizedMeal = 'Failed to recognize the meal';
        });

        // Print the error to the console
        print('Error: ${response.statusCode} - ${response.data}');
      }
    } catch (error) {
      // Handle exceptions
      setState(() {
        recognizedMeal = 'Error: $error';
      });

      // Print the exception to the console
      print('Exception: $error');
    }
  }

  Future<void> pickImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
        recognizedMeal = ''; // Clear previous recognition result
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Recognition App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            imagePath.isNotEmpty
                ? Image.file(
              File(imagePath),
              height: 200.0,
              width: 200.0,
              fit: BoxFit.cover,
            )
                : Container(),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: pickImage,
              child: Text('Pick Image'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                if (imagePath.isNotEmpty) {
                  recognizeMeal(imagePath);
                } else {
                  // Handle case where no image is selected
                  setState(() {
                    recognizedMeal = 'Please pick an image first';
                  });
                }
              },
              child: Text('Recognize Meal'),
            ),
            SizedBox(height: 20.0),
            Text(
              recognizedMeal,
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
