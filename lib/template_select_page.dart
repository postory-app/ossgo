import 'dart:async';
// import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:ui/image_edit_view.dart';

class TemplateSelectPage extends StatefulWidget {
  String? defaultTamplate;

  // 轉換方法
  // XFile xfile = ...;
  // File file = File(xfile.path);
  // Uint8List bytes = file.readAsBytesSync();
  Uint8List? image;
  TemplateSelectPage({Key? key, this.image, this.defaultTamplate}) : super(key: key);

  @override
  State<TemplateSelectPage> createState() => _TemplateSelectPageState();
}

class _TemplateSelectPageState extends State<TemplateSelectPage> {
  
  final List<String> _templates = ["postcard_template_01.png", "postcard_template_02.png"];

  int? _selectedIdx;
  final ImageEditViewController _imageEditViewController = ImageEditViewController();
  bool _isExportingImage = false;
  @override
  void initState() {
    super.initState();
    if (widget.defaultTamplate != null) {
      _selectedIdx = _templates.indexOf(widget.defaultTamplate!);
      if (_selectedIdx == -1) _selectedIdx = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    double scaleRatioH = MediaQuery.of(context).size.height / 852;
    // double scaleRatioW = MediaQuery.of(context).size.height / 392;

    return Scaffold(
        backgroundColor: Colors.black.withOpacity(0.75),
        body: SingleChildScrollView(
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Container(
                          constraints: const BoxConstraints(maxWidth: 600),
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          child: ImageEditView(
                            key: _selectedIdx == null ? null : ValueKey(_selectedIdx),
                            controller: _imageEditViewController,
                            coverImage: _selectedIdx == null ? null : _templates[_selectedIdx!],
                            belowImage: widget.image,
                          )),
                    ),
                    SafeArea(
                      top: false,
                      child: Container(
                        child: Container(
                          height: scaleRatioH * 309,
                          decoration: const BoxDecoration(
                              color: Color(0xFFFFFEFA),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              )),
                          padding: EdgeInsets.only(top: 16 * scaleRatioH, bottom: 20),
                          child: Column(children: [
                            Row(
                              children: [
                                const Spacer(),
                                TextButton(
                                    style: ButtonStyle(
                                        // backgroundColor: MaterialStateProperty.all(const Color(0xFFFFD24A)),
                                        // overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.08)),
                                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                    ))),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      child: const Text(
                                        "取消",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF1F1E1C)),
                                      ),
                                    )),
                                const Spacer(
                                  flex: 20,
                                ),
                                Opacity(
                                  opacity: _selectedIdx == null ? 0.5 : 1,
                                  child: TextButton(
                                      style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all(const Color(0xFFFFD24A)),
                                          overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.08)),
                                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(18.0),
                                          ))),
                                      onPressed: _selectedIdx == null || _isExportingImage == true
                                          ? null
                                          : () async {
                                              setState(() {
                                                _isExportingImage = true;
                                              });

                                              await Future.delayed(const Duration(milliseconds: 250));

                                              Uint8List? result = await _imageEditViewController.export();

                                              setState(() {
                                                _isExportingImage = true;
                                              });

                                              await Future.delayed(const Duration(milliseconds: 250));

                                              if (mounted) {
                                                Navigator.of(context).pop(result);
                                              }
                                            },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        child: Stack(
                                          children: [
                                            Text(
                                              "套用",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _isExportingImage == true ? Colors.transparent : const Color(0xFF1F1E1C)),
                                            ),
                                            if (_isExportingImage) const Positioned.fill(child: Center(child: SizedBox(height: 15, width: 15, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))))
                                          ],
                                        ),
                                      )),
                                ),
                                const Spacer(),
                              ],
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(top: 28 * scaleRatioH),
                                child: LayoutBuilder(
                                  builder: (BuildContext context, BoxConstraints constraints) {
                                    return ListView.builder(
                                      padding: const EdgeInsets.symmetric(horizontal: 25),
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (BuildContext context, int index) {
                                        return Opacity(
                                          opacity: _selectedIdx == null
                                              ? 1
                                              : _selectedIdx == index
                                                  ? 1
                                                  : 0.3,
                                          child: Container(
                                              height: constraints.maxHeight,
                                              width: constraints.maxHeight / 1311 * 1825,
                                              child: Container(
                                                margin: const EdgeInsets.all(5),
                                                clipBehavior: Clip.antiAlias,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(6),
                                                  boxShadow: _selectedIdx == index
                                                      ? [
                                                          BoxShadow(
                                                            color: Colors.black.withOpacity(0.2),
                                                            // spreadRadius: 3,
                                                            blurRadius: 3,
                                                            offset: Offset(0, 1), // changes position of shadow
                                                          ),
                                                        ]
                                                      : null,
                                                ),
                                                child: Material(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(6),
                                                    child: Stack(
                                                      children: [
                                                        Container(
                                                          margin: EdgeInsets.all(_selectedIdx == index ? 5 : 0),
                                                          alignment: Alignment.center,
                                                          child: Image.asset(
                                                            "assets/images/${_templates[index]}",
                                                            fit: BoxFit.contain,
                                                          ),
                                                        ),
                                                        Material(
                                                          color: Colors.transparent,
                                                          child: InkWell(
                                                            onTap: () {
                                                              _selectedIdx = index;
                                                              setState(() {});
                                                            },
                                                          ),
                                                        )
                                                      ],
                                                    )),
                                              )),
                                        );
                                      },
                                      itemCount: _templates.length,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    )
                  ],
                ))));
  }
}
