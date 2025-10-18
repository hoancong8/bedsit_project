import 'package:flutter/material.dart';
import 'package:panorama_viewer/panorama_viewer.dart';


void main(){
  runApp(MaterialApp(home: PanoramaScreen(),));
}

class PanoramaScreen extends StatelessWidget {
  const PanoramaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xem ảnh 360°')),
      body: PanoramaViewer(
        child: Image.asset(
          'assets/image/canh1.jpg', // hoặc Image.network('URL_ẢNH_360')
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
