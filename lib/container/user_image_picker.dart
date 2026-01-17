import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:event_planning_app/appwrite.dart';
import 'package:event_planning_app/constants/user_image_utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

final account = Account(client);

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({
    super.key,
    required this.onPickImage,
    required this.storage,
    required this.onImageUploaded,
  });

  final void Function(File pickedImage) onPickImage;
  final Storage storage;

  final void Function(String imageId) onImageUploaded;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImageFile;

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text("Take a Photo"),
                onTap: () async {
                  Navigator.of(context).pop();
                  await pickAndUploadImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose from Gallery"),
                onTap: () async {
                  Navigator.of(context).pop();
                  await pickAndUploadImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> pickAndUploadImage(ImageSource source) async {
    final image = await pickImage(source); // From user_image_utils.dart
    if (image == null) return null;

    setState(() {
      _pickedImageFile = image;
    });

    widget.onPickImage(image);

    final imageId = await uploadUserImage(
        image, widget.storage, account); // From user_image_utils.dart
    if (imageId != null) {
      print('Image uploaded with ID: $imageId');
      return imageId;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage:
              _pickedImageFile != null ? FileImage(_pickedImageFile!) : null,
          child: _pickedImageFile == null
              ? const Icon(Icons.person, size: 40, color: Colors.white)
              : null,
        ),
        TextButton.icon(
          onPressed: _showImageSourceDialog,
          icon: const Icon(Icons.image),
          label: Text(
            'Add Profile Picture',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ],
    );
  }
}
