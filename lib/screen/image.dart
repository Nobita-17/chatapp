import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';


class Imagepicker extends StatefulWidget {
  const Imagepicker({super.key, required this.onpickedImage});

 final void Function(File pickedImage) onpickedImage;  // we used this funcation to send or set the value of picked image

  @override
  State<Imagepicker> createState() => _ImagepickerState();
}

class _ImagepickerState extends State<Imagepicker> {
  File? previw;
  void _pickimage() async {
   final pickImage=await ImagePicker().pickImage(source: ImageSource.camera,imageQuality: 50,maxWidth: 150);
    if(pickImage==null)
      {
        return;
      }
    setState(() {
      previw=File(pickImage.path);
    });
    widget.onpickedImage(previw!);
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage: previw != null ? FileImage(previw!) : null,
        ),
        TextButton.icon(
          onPressed: _pickimage,
          icon: Icon(Icons.camera_alt),
          label: Text('Open Camera',style: TextStyle(color: Colors.red),),
        ),
      ],
    );
  }
}
