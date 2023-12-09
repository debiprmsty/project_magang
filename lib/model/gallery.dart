class Gallery{
  int id;
  String images;

  Gallery({
    required this.id,
    required this.images
  });

  factory Gallery.fromJson(Map<String, dynamic> json){
    return Gallery(
      id: json['id'],
      images: json['images'],
    );
  }
}