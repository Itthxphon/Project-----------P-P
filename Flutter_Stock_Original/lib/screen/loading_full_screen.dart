import 'package:flutter/material.dart';

class LoadingFullScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      color: Colors.black.withOpacity(0.8),
      width: double.infinity,
      height: double.infinity,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
