// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   late File _image = File('');
//   final picker = ImagePicker();
//   late String _category = '';

//   Future getImage() async {
//     final pickedFile = await picker.getImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       _image = File(pickedFile.path);
//       String base64Image = base64Encode(_image.readAsBytesSync());

//       var url = 'http://10.0.2.2:5000/';
//        //var url = 'http://192.168.0.104:5000/';
//       final response = await http.post(
//         Uri.parse(url),
//         body: jsonEncode({'image': base64Image}),
//         headers: {'Content-Type': "application/json"},
//       );

//       print('StatusCode : ${response.statusCode}');
//       print('Return Data : ${response.body}');

//       if (response.statusCode == 200) {
//         Map<String, dynamic> responseData = jsonDecode(response.body);
//         String category = '';
//         if (responseData.containsKey('category')) {
//           category = responseData['category']['category'];
//           print('Category: $category');
//         }

//         setState(() {
//           _image = _image;
//           _category = category;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(''),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Expanded(
//               child: ListView(
//                 shrinkWrap: true,
//                 children: [
//                   if (_image == null || _image.path.isEmpty)
//                     Container(
//                       alignment: Alignment.center,
//                       child: Column(
//                         children: [
//                           Image.asset('assets/logo.png', fit: BoxFit.fill),
//                           SizedBox(height: 20),
//                           Text(
//                             'Categories',
//                             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                           ),
//                           SizedBox(height: 10),
//                           Container(
//                             alignment: Alignment.center,
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 CategoryItem(name: 'Category 1', range: '0-50'),
//                                 CategoryItem(name: 'Category 2', range: '50-150'),
//                                 CategoryItem(name: 'Category 3', range: '150-255'),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     )
//                   else
//                     Column(
//                       children: [
//                         Image.file(_image, fit: BoxFit.fill),
//                         SizedBox(height: 10),
//                         Text('Category: $_category'),
//                       ],
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: getImage,
//         tooltip: 'Pick Image',
//         child: Icon(Icons.add_a_photo),
//       ),
//     );
//   }
// }

// class CategoryItem extends StatelessWidget {
//   final String name;
//   final String range;

//   CategoryItem({required this.name, required this.range});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 60,
//       width: 250,
//       padding: EdgeInsets.all(8),
//       margin: EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         color: Colors.grey[200],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             name,
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//           Text(
//             'Range: $range',
//             style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//           ),
//         ],
//       ),
//     );
//   }
// }
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
  List<File> _images = [];
  final picker = ImagePicker();
  late String _category = '';
  bool _uploadButtonEnabled = true;
  int _remainingImages = 10;

  Future getImage() async {
    if (_remainingImages > 0) {
      final pickedFile = await picker.getImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _images.add(File(pickedFile.path));
          _remainingImages--;

          if (_remainingImages == 0) {
            _uploadImages();
          } else {
            // Show a SnackBar with remaining images
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$_remainingImages more image${_remainingImages != 1 ? 's' : ''} to click'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        });
      }
    }
  }

  void _uploadImages() async {
    setState(() {
      _uploadButtonEnabled = false;
    });

    List<String> base64Images = [];
    for (var image in _images) {
      String base64Image = base64Encode(image.readAsBytesSync());
      base64Images.add(base64Image);
    }

    var url = 'http://10.0.2.2:5000/';
    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode({'images': base64Images}),
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
        _category = category;
      });
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
                  if (_images.isEmpty)
                    Container(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Image.asset('assets/logo.png', fit: BoxFit.fill),
                          SizedBox(height: 20),
                          Text(
                            'Note: Take 10 images of the same leaf.',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                          // Display TextField when no more images to be clicked
                          if (_remainingImages == 0)
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Enter your text here',
                                  labelText: 'Text Box',
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: [
                        for (var image in _images) Image.file(image, fit: BoxFit.fill),
                        if (_category.isNotEmpty)
                          Text('It belongs to : $_category'), // Display category as text
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _uploadButtonEnabled
          ? FloatingActionButton(
              onPressed: getImage,
              tooltip: 'Take Image',
              child: Icon(Icons.add_a_photo),
            )
          : null,
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
