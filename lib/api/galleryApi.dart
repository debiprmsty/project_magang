import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:project_magang/model/gallery.dart';

class GalleryController{
  final dio = Dio();
  final baseUrl = "https://galleryapi.000webhostapp.com/api/";

  Future<List<Gallery>> fetchGallery(String page) async {
    final url = "$baseUrl" + 'gallery?page=$page';
    Response response = await dio.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = response.data;

      if (responseData.containsKey('data')) {
        dynamic data = responseData['data']['data'];
        List<Gallery> galleryList = List<Gallery>.from(data.map((json) => Gallery.fromJson(json)));
        return galleryList;
      } else {
        print('Key "data" tidak ditemukan dalam respon API');
        return [];
      }
    } else {
      print('Gagal mengambil data dari API');
      throw Exception('Gagal mengambil data dari API');
    }
  }

  Future<void> addImage(String image) async {
  final url = "$baseUrl" + 'gallery';

  var formData = FormData.fromMap({
    'images': await MultipartFile.fromFile(image, filename: 'images'),
  });

  try {
      var response = await dio.post(
        url,
        data: formData,
        options: Options(
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          },
          headers: {
            "Accept": "application/json",
          },
        ),
      );

      print(response.data);
      // Add logic for handling successful response or failure, if needed.
    } catch (error) {
      print('Error: $error');
      // Add error handling logic as needed.
    }
  }


  

}