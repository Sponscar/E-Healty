import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? photoPath;
  final String? photoBase64;
  final VoidCallback onTap;

  const ProfileAvatar({
    super.key,
    this.photoPath,
    this.photoBase64,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;

    if (photoBase64 != null && photoBase64!.isNotEmpty) {
      try {
        imageProvider = MemoryImage(base64Decode(photoBase64!));
      } catch (e) {
        debugPrint("Error decode base64: $e");
      }
    }

    else if (photoPath != null && photoPath!.isNotEmpty) {
      imageProvider = FileImage(File(photoPath!));
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 55,
            backgroundColor: Colors.transparent,
            backgroundImage: imageProvider,
            child: imageProvider == null
                ? CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Icon(Icons.person, size: 60, color: Colors.white),
                  )
                : null,
          ),

          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 18,
              ),
            ),
          )
        ],
      ),
    );
  }
}
