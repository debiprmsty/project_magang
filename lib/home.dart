import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_magang/addImage.dart';
import 'package:project_magang/api/galleryApi.dart';
import 'package:project_magang/model/gallery.dart';
import 'package:project_magang/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Gallery> photos = [];
  GalleryController _galleryController = GalleryController();
  int reqPage = 1;
  
  Future getData() async {
    final response = await _galleryController.fetchGallery(reqPage.toString());
    List<Gallery> newData = response;
    setState(() {
      photos.addAll(newData);
    });
  }

  void getNewData() async {
    await getData();
  } 

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: coklat,
        title: Text("GALLERY", style: lato.copyWith(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {
                setState(() {
                  reqPage++;
                });
                getNewData();
                print(reqPage);
              }, 
              icon: Icon(Icons.refresh),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: width,
          height: height,
          color: coklatmuda,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          child: photos.length > 0 ? GridView.builder(
            padding:  EdgeInsets.only(bottom: 100),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 3/3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10
            ),
            itemCount: photos!.length,
            itemBuilder: (BuildContext context, int index) {
              Gallery gallery = photos[index];
              return Image.network("https://galleryapi.000webhostapp.com/api/gallery/image/${gallery.images}", fit: BoxFit.cover,);
            },
          ) :  Center(
            child: CircularProgressIndicator(),
          )
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: coklat,
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return const AddImagePage();
          }));
        },
        child: Icon(Icons.add, color: Colors.white,),
      ),
    );
  }
}