import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_color_picker/child_size_notifier.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_pixels/image_pixels.dart';
import 'package:collection/collection.dart';

extension HexColor on Color {
  String toHex() => '#'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

class EverythingWidget extends StatefulWidget {
  const EverythingWidget({Key? key}) : super(key: key);

  @override
  _EverythingWidgetState createState() => _EverythingWidgetState();
}

class _EverythingWidgetState extends State<EverythingWidget> {
  Color? _color;
  ImageProvider? _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ImagePixels(
            imageProvider: _image,
            defaultColor: Colors.grey,
            builder: (context, img) {
              if (!img.hasImage) {
                return const Text('no image Selected');
              } else {
                return ChildSizeNotifier(
                  builder: (_, size, __) {
                    return GestureDetector(
                        onTapDown: (details) {
                          final alignment = Alignment(
                              ((details.localPosition.dx.toInt() / size.width) *
                                      2) -
                                  1,
                              ((details.localPosition.dy.toInt() /
                                          size.height) *
                                      2) -
                                  1);

                          setState(() {
                            _color = img.pixelColorAtAlignment!(alignment);
                          });
                        },
                        child: Image(
                          width: 300,
                          image: _image!,
                        ));
                  },
                );
              }
            },
          ),
          ElevatedButton(
              onPressed: _uploadImage, child: const Text('upload image')),
          if (_image != null && _color == null)
            const Text('no color selected; click on the image'),
          if (_image != null && _color != null) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('selected color hex is ${_color!.toHex()}'),
                GestureDetector(
                    onTap: () => Clipboard.setData(
                        ClipboardData(text: _color!.toHex().substring(1))),
                    child: const Icon(Icons.copy))
              ],
            ),
            Text(
                'selected color RGB is R: ${_color!.red} G: ${_color!.green} B: ${_color!.blue}'),
            Container(width: 100, height: 100, color: _color!)
          ]
        ],
      ),
    );
  }

  Future<void> _uploadImage() async {
    final XFile? image =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image == null) {
      return;
    }

    image.readAsBytes().then((value) => setState(() {
          _image = MemoryImage(value);
        }));
  }
}
