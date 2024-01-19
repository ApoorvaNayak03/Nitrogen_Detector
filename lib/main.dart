import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late File _image = File('');
  final picker = ImagePicker();
  late String _category = '';

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      String base64Image = base64Encode(_image.readAsBytesSync());

      var url = 'http://10.0.2.2:5000/';
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({'image': base64Image}),
        headers: {'Content-Type': "application/json"},
      );

      print('StatusCode : ${response.statusCode}');
      print('Return Data : ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        String category = '';
        if (responseData.containsKey('category')) {
          category = responseData['category']['category'];
          print('Category: $category');
        }

        setState(() {
          _image = _image;
          _category = category;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  if (_image == null || _image.path.isEmpty)
                    Container(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Image.asset('assets/logo.png', fit: BoxFit.fill),
                          SizedBox(height: 20),
                          Text(
                            'Categories',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Container(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CategoryItem(name: 'Category 1', range: '0-50'),
                                CategoryItem(name: 'Category 2', range: '50-150'),
                                CategoryItem(name: 'Category 3', range: '150-255'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: [
                        Image.file(_image, fit: BoxFit.fill),
                        SizedBox(height: 10),
                        Text('Category: $_category'),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String name;
  final String range;

  CategoryItem({required this.name, required this.range});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: 250,
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            'Range: $range',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
