// user_image_utils.dart

import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:image_picker/image_picker.dart';

Future<File?> pickImage(ImageSource source) async {
  final pickedImage = await ImagePicker().pickImage(
    source: source,
    requestFullMetadata: true,
    imageQuality: 50,
    maxWidth: 150,
  );

  if (pickedImage == null) return null;

  return File(pickedImage.path);
}

Future<String?> uploadUserImage(
    File imageFile, Storage storage, Account account) async {
  try {
    final user = await account.get();
    final userId = user.$id;

    final result = await storage.createFile(
      bucketId: '680fb7b70018d4081a4f',
      fileId: ID.unique(),
      file: InputFile.fromPath(
        path: imageFile.path,
        filename: "profile_${DateTime.now().millisecondsSinceEpoch}.jpg",
      ),
      permissions: [
        Permission.read('user:$userId'),
        Permission.write('user:$userId'),
      ],
    );

    print("Image uploaded with ID: ${result.$id}");
    return result.$id;
  } on AppwriteException catch (e) {
    print("Upload failed: ${e.message}");
    return null;
  }
}
