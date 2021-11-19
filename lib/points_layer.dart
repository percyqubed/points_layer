library points_layer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

part 'point_data.dart';

class PointsLayer extends StatefulWidget {
  PointsLayer({
    Key? key,
    required this.imagePath,
    required this.size,
    required this.points,
    this.onTap,
  }) : super(key: key);

  final double size;
  final String imagePath;
  final List<PointData> points;
  final ValueChanged<String>? onTap;

  @override
  _PointsLayerState createState() => _PointsLayerState();
}

class _PointsLayerState extends State<PointsLayer> {
  List<PointData>? _points;
  @override
  void initState() {
    super.initState();
    _points = widget.points;
  }

  _onChanged(String partId) {
    if (widget.onTap != null) {
      widget.onTap!(partId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<double>>(
      future: _imageSize(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var width = snapshot.data![0];
          var height = snapshot.data![1];
          return Container(
            width: width,
            height: height,
            child: Stack(
              children: [
                Image(
                  image: AssetImage(widget.imagePath),
                  fit: BoxFit.contain,
                  width: width,
                  height: height,
                ),
                ..._populatePoints(width: width, height: height),
              ],
            ),
          );
        }
        return SizedBox();
      },
    );
  }

  List<Widget> _populatePoints({required double width, required double height}) {
    List<Widget> widgets = [];
    _points!.forEach((pointData) {
      widgets.add(
        GestureDetector(
          onTap: () {
            _onChanged(pointData.id!);
          },
          child: ClipPath(
            clipper: ClickableClipper(
              points: _generatePoints(
                points: pointData.points!,
                width: width,
                height: height,
              ),
            ),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
      );
    });
    return widgets;
  }

  List<Offset> _generatePoints({
    required List<List<double>> points,
    required double width,
    required double height,
  }) {
    List<Offset> offsets = [];
    points.forEach((element) {
      var x = element[0] * width;
      var y = element[1] * height;
      offsets.add(Offset(x, y));
    });
    return offsets;
  }

  Future<List<double>> _imageSize() async {
    ByteData imageData = await rootBundle.load(widget.imagePath);
    var decodedImage = await decodeImageFromList(imageData.buffer.asUint8List());
    double width = 0;
    double height = 0;

    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    var size = screenWidth > screenHeight ? screenHeight * widget.size : screenWidth * widget.size;

    var originalImageHeight = decodedImage.height.toDouble();
    var originalImageWidth = decodedImage.width.toDouble();

    if (originalImageWidth > originalImageHeight) {
      double aspectRatio = originalImageHeight / originalImageWidth;
      width = size;
      height = aspectRatio * width;
    } else {
      double aspectRatio = originalImageWidth / originalImageHeight;
      height = size;
      width = aspectRatio * height;
    }

    return [width, height];
  }
}

class ClickableClipper extends CustomClipper<Path> {
  final List<Offset> points;

  ClickableClipper({required this.points});

  @override
  Path getClip(Size size) {
    Path path = Path();
    var offset = points.first;
    path.moveTo(offset.dx, offset.dy);
    points.forEach((offset) {
      path.lineTo(offset.dx, offset.dy);
    });
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
