import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class PreviewCircularAvatar extends StatelessWidget {
  const PreviewCircularAvatar({super.key, this.imageFile, this.imageUrl});
  final File? imageFile;
  final String? imageUrl;
  final double avatarRadius = 40;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircleAvatar(
        radius: avatarRadius * 1.04,
        backgroundColor: buttonColors,
        child: imageFile != null
            ? CircleAvatar(
                backgroundColor: Colors.grey.shade200,
                radius: avatarRadius,
                backgroundImage: FileImage(imageFile!),
              )
            : imageUrl != null && imageUrl!.isNotEmpty
                ? CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    radius: avatarRadius,
                    backgroundImage: NetworkImage(imageUrl!),
                  )
                : CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    radius: avatarRadius,
                    child: FittedBox(
                      child: Text(
                        'Preview',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: Colors.black54,
                            ),
                      ),
                    ),
                  ),
      ),
    );
  }
}

class CustomNetworkAvatar extends StatelessWidget {
  const CustomNetworkAvatar(
      {super.key, required this.radius, required this.imageUrl, this.onTap});
  final double radius;
  final String imageUrl;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: Theme.of(context).primaryColor),
          boxShadow: const [
            BoxShadow(blurRadius: 2, offset: Offset(1, 1)),
          ],
        ),
        height: radius,
        width: radius,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.fill,
            progressIndicatorBuilder: (context, url, progress) => Center(
              child: CircularProgressIndicator(
                value: progress.downloaded.toDouble(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
