import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? image;
  final _picker = ImagePicker();
  bool showSpiner = false;

  Future getImage() async {
    final pickedfile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedfile != null) {
      image = File(pickedfile.path);
      setState(() {
        uploadImage();
      });
    } else {
      print("No Image Selected");
    }
  }

  Future<void> uploadImage() async {
    setState(() {
      showSpiner = true;
    });
    var headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjoyLCJ0aW1lIjoxNjk4OTAzMjAxfQ.WNljZRXXQ9RnGDnYCU4jSqoiGWh7db_PtAVfgo0LBCA'
    };
    var request = http.MultipartRequest(
        "PUT", Uri.parse('https://staging.simmpli.com/api/v1/profiles/2.json'));

    request.files.add(
        await http.MultipartFile.fromPath('profile[profile_pic]', image!.path));
    request.headers.addAll(headers);
    var response = await request.send().timeout(const Duration(seconds: 30));

    print("responsce :${response.statusCode}");
    if (response.statusCode == 201 || response.statusCode == 200) {
      print("responsce :$response ");
      setState(() {
         showSpiner = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpiner,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("image example"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  getImage();
                },
                child: Container(
                    child: image == null
                        ? const Center(
                            child: Text('pick Image'),
                          )
                        : Container(
                            child: Center(
                              child: Image.file(
                                File(image!.path).absolute,
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )),
              ),
              SizedBox(
                height: 150,
              ),
              GestureDetector(
                onTap: () {
                  // uploadImage();
                },
                child: Container(
                  height: 50,
                  color: Colors.amber,
                  child: Text('Upload'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
