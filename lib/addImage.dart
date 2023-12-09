import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui' show Codec, FrameInfo, ImageByteFormat, instantiateImageCodec;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:project_magang/api/galleryApi.dart';
import 'package:project_magang/home.dart';
import 'package:project_magang/theme.dart';

class AddImagePage extends StatefulWidget {
  const AddImagePage({super.key});

  @override
  State<AddImagePage> createState() => _AddImagePageState();
}

class _AddImagePageState extends State<AddImagePage> {
  final imageController = TextEditingController();
  File? _getImage;
  bool _isImageResized = false;
  bool _isLoading = false;
  bool _isSubmitting = false;

  GalleryController _galleryController = GalleryController();

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _isLoading = true;
    });

    final pickedFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: 50, // Sesuaikan kualitas gambar sesuai kebutuhan
    );

    if (pickedFile != null) {
      // Baca gambar
      List<int> imageBytes = await pickedFile.readAsBytes();
      img.Image image = img.decodeImage(Uint8List.fromList(imageBytes))!;

      // Resize gambar sesuai kebutuhan (contoh: lebar 800px)
      img.Image resizedImage = img.copyResize(image, width: 800);

      // Simpan kembali sebagai file
      List<int> resizedBytes = img.encodePng(resizedImage);
      String tempImagePath = pickedFile.path + "_resized.png";
      await File(tempImagePath).writeAsBytes(resizedBytes);

      setState(() {
        _getImage = File(tempImagePath);
        imageController.text = _getImage!.path; // Isi nilai TextFormField
        _isImageResized = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: coklatmuda,
      appBar: AppBar(
        backgroundColor: coklat,
        title: Text(
          "ADD IMAGE",
          style: lato.copyWith(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      color: coklat,
                      height: 115.0,
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.camera_alt, color: Colors.white),
                            title: Text(
                              'Kamera',
                              style: lato.copyWith(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            onTap: () {
                              _pickImage(ImageSource.camera);
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.photo_library, color: Colors.white),
                            title: Text(
                              'Galeri',
                              style: lato.copyWith(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            onTap: () {
                              _pickImage(ImageSource.gallery);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Container(
                width: width,
                height: 45,
                decoration: BoxDecoration(
                  color: coklat,
                  borderRadius: BorderRadius.circular(20)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, color: Colors.white),
                    const SizedBox(
                      width: 10,
                    ),
                    Text("UPLOAD", style: lato.copyWith(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),)
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Container(
              width: width,
              height: 500,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: coklat,
                  width: 1.5,
                ),
              ),
              child: _getImage == null
                ? Center(
                    child: _isLoading
                        ? CircularProgressIndicator() // Show loading indicator
                        : Text(
                            "Belum ada gambar",
                            style: lato.copyWith(fontSize: 18, color: Colors.grey),
                          ),
                  )
              : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.file(_getImage!, fit: BoxFit.cover, height: 450,),
                  if (_isImageResized)
                    Text(
                      'Gambar telah diresize',
                      style: lato.copyWith(fontSize: 14, color: Colors.green),
                    ),
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            SizedBox(
              width: width,
              height: 45,
              child: FilledButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(coklat),
                ),
                onPressed: () async {
                  setState(() {
                    _isSubmitting = true;
                  });

                  String image = imageController.text;

                  await _galleryController.addImage(image).then((value) => {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Data berhasil ditambah', style: lato,),
                        duration: Duration(seconds: 2), // Durasi notifikasi
                      ),
                    ),
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                      return HomePage();
                    })),
                  }).whenComplete(() {
                    setState(() {
                      _isSubmitting = false;
                    });
                  });
                },
                child: _isSubmitting
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : Text(
                    "SUBMIT",
                    style: lato.copyWith(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
              ),
            )
          ],
        ),
      )
    );
  }
}
