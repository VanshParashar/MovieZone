import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants.dart';

class Poster extends StatelessWidget {
  final String? path;
  final double width;
  final double height;
  final String heroTag;
  final BoxFit fit;
  final BorderRadius borderRadius;

  const Poster({
    Key? key,
    required this.heroTag,
    this.path,
    this.width = 120,
    this.height = 180,
    this.fit = BoxFit.cover,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final url = path != null ? '$IMAGE_BASE_URL$path' : null;
    return Hero(
      tag: heroTag,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: url != null
              ? CachedNetworkImage(
            imageUrl: url,
            width: width,
            height: height,
            fit: fit,
            placeholder: (ctx, s) => Container(
              alignment: Alignment.center,
              child: SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
            ),
            errorWidget: (ctx, _, __) => Icon(Icons.broken_image, size: 40, color: Colors.grey[400]),
          )
              : Icon(Icons.image_not_supported_rounded, size: 48, color: Colors.grey[400]),
        ),
      ),
    );
  }
}
