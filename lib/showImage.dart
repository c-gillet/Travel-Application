import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class YourImageWidget extends StatefulWidget {
  final String imagePath;

  YourImageWidget({required this.imagePath});

  @override
  _YourImageWidgetState createState() => _YourImageWidgetState();
}

class _YourImageWidgetState extends State<YourImageWidget> {
  late Future<String> _imageFuture;

  @override
  void initState() {
    super.initState();
    _imageFuture = _getImageUrl();
  }

  Future<String> _getImageUrl() async {
    Reference storageReference = FirebaseStorage.instance.ref().child(widget.imagePath);
    return await storageReference.getDownloadURL();
  }

  Widget _buildImageWidget(String imageUrl) {
    return Image.network(
      imageUrl,
      fit: BoxFit.contain,
      height: 400.0,
      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
        try {
          if (loadingProgress != null && loadingProgress is ImageChunkEvent) {
            if (loadingProgress.expectedTotalBytes != null &&
                loadingProgress.cumulativeBytesLoaded > loadingProgress.expectedTotalBytes!) {
              // Image is fully loaded
              return child;
            } else {
              // Image is still loading
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              );
            }
          } else {
            // If loadingProgress is not of type ImageChunkEvent, return the child directly
            return child;
          }
        } catch (e) {
          // Error occurred while loading image
          return Center(child: Text('Error loading image: $e'));
        }
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return _buildImageWidget(snapshot.data as String);
        }
      },
    );
  }
}


class FirebaseStorageImage extends StatelessWidget {
  final String imagePath;

  FirebaseStorageImage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    // Construct the Firebase Storage URL
    String storageUrl = 'https://firebasestorage.googleapis.com' + imagePath;


    return Image.network(
      storageUrl,
      fit: BoxFit.cover, // You can adjust the BoxFit as needed
      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          return child;
        } else {
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
            ),
          );
        }
      },
    );
  }
}
