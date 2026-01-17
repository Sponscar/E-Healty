import 'dart:io';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? photoPath;
  final VoidCallback onTap;

  const ProfileAvatar({
    super.key,
    required this.photoPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 55,
            backgroundColor: Colors.blue.shade100,
            backgroundImage: photoPath != null && photoPath!.isNotEmpty
                ? FileImage(File(photoPath!))
                : null,
            child: photoPath == null
                ? const Icon(Icons.person, size: 60, color: Colors.blue)
                : null,
          ),

          // icon kamera kecil
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
