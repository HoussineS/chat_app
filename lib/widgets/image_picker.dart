import 'dart:io';

import 'package:image_picker/image_picker.dart' as imagePicker;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePicker extends StatefulWidget {
  const ImagePicker({super.key, required this.onPickedImage});

  final void Function(File pikedImage) onPickedImage;

  @override
  State<ImagePicker> createState() => _ImagePickerState();
}

class _ImagePickerState extends State<ImagePicker> {
  File? _selectedFile;
  void _pickImage(imagePicker.ImageSource source) async {
    final picker = imagePicker.ImagePicker();
    // Pick an image.
    final image = await picker.pickImage(source: source, maxWidth: 300);
    if (image != null) {
      setState(() {
        _selectedFile = File(image.path);
      });
      widget.onPickedImage(_selectedFile!);
    }
  }

  void _showImageDialog() {
    showBottomSheet(
      context: context,
      builder: (bc) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text("Take image"),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text("selecte a image"),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: _selectedFile == null
              ? AssetImage("assets/images/user.png") as ImageProvider
              : FileImage(_selectedFile!),
        ),
        TextButton.icon(
          onPressed: _showImageDialog,
          label: Text("Pick image"),
          icon: Icon(Icons.upload),
        ),
      ],
    );
  }
}
