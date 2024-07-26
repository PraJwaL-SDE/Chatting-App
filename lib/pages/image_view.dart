import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageView extends StatefulWidget {
  final String imageUrl;
  const ImageView({super.key, required this.imageUrl});

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PhotoView(
            imageProvider: NetworkImage(widget.imageUrl),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
            backgroundDecoration: BoxDecoration(
              color: Colors.black,
            ),
            loadingBuilder: (context, event) {
              if (event == null) {
                return Center(child: CircularProgressIndicator());
              }
              return Center(child: CircularProgressIndicator(value: event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1)));
            },
            errorBuilder: (context, error, stackTrace) {
              return Center(child: Icon(Icons.error, color: Colors.red));
            },
          ),
          Positioned(
            top: 40, // Adjust the position as needed
            left: 10, // Adjust the position as needed
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
