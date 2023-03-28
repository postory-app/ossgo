import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef ImageEditViewExport = Future<Uint8List?> Function();

class ImageEditViewController {
  late ImageEditViewExport export;
}

class ImageEditView extends StatefulWidget {
  final ImageEditViewController? controller;
  final String? coverImage;
  final Uint8List? belowImage;
  final bool editable;
  const ImageEditView({Key? key, this.controller, this.coverImage, this.belowImage, this.editable = true}) : super(key: key);

  @override
  State<ImageEditView> createState() => _ImageEditViewState();
}

class _ImageEditViewState extends State<ImageEditView> {
  bool? _isReady = false;

  Size? _coverImageSize;
  Rect? _coverImageRect;
  Size? _belowImageSize;
  Rect? _belowImageRect;
  Rect? _belowImageDefaultRect;
  Uint8List? _belowImage;
  Rect? _startScaleBelowImageRect;

  bool _isOnTapDown = false;
  int? _dragPointerCount;
  Offset? _dragLastPistion;

  final GlobalKey _belowImageKey = GlobalKey();

  double? _touchInImgOffsetRatioX;
  double? _touchInImgOffsetRatioY;

  Uint8List? _resultImage;
  ui.Image? _coverImage;

  @override
  void initState() {
    super.initState();

    if (widget.controller != null) {
      widget.controller!.export = _exportPhoto;
    }

    if (widget.belowImage == null) {
      _loadTestImage().then((value) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
          await _getCoverImageSize();
          await _getBelowImageSize();
          setState(() {
            _isReady = true;
          });
        });
      });

      //Test _exportPhoto
      // Future.delayed(const Duration(seconds: 10), () {
      //   _exportPhoto();
      // });
    } else {
      _belowImage = widget.belowImage;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        await _getCoverImageSize();
        await _getBelowImageSize();
        setState(() {
          _isReady = true;
        });
      });
    }
  }

  @override
  void didUpdateWidget(ImageEditView oldWidget) {
    if (widget.controller != null) {
      widget.controller!.export = _exportPhoto;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _isReady == false
          ? const Center(
              child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFFFD24A),
              ),
            ))
          : LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                double paddingTop = 10;
                if (_belowImageSize == null || _coverImageSize == null) return const SizedBox.shrink();
                if (_coverImageRect == null && _belowImageDefaultRect == null && _belowImageRect == null) {
                  FittedSizes fittedSizes = applyBoxFit(
                    BoxFit.contain,
                    Size(
                      _coverImageSize!.width.toDouble(),
                      _coverImageSize!.height.toDouble(),
                    ),
                    Size(constraints.maxWidth, constraints.maxHeight - paddingTop),
                  );
                  _coverImageRect = Alignment.center.inscribe(fittedSizes.destination, Offset(0, paddingTop) & Size(constraints.maxWidth, constraints.maxHeight - paddingTop));

                  //預設位置
                  if (_belowImageSize != null && _belowImageDefaultRect == null) {
                    FittedSizes fittedSizes2 = applyBoxFit(
                      BoxFit.contain,
                      Size(
                        _belowImageSize!.width.toDouble(),
                        _belowImageSize!.height.toDouble(),
                      ),
                      Size(_coverImageRect!.width, _coverImageRect!.height),
                    );
                    // debugPrint("_coverImageRect w=${_coverImageRect!.width}, h=${_coverImageRect!.height}");
                    _belowImageDefaultRect = Alignment.center.inscribe(fittedSizes2.destination, _coverImageRect!);
                    _belowImageRect = _belowImageDefaultRect;
                  }
                }

                return IgnorePointer(
                  ignoring: widget.coverImage == null,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTapDown: (t) {
                      setState(() {
                        _isOnTapDown = true;
                      });
                    },
                    onTapCancel: () {
                      setState(() {
                        _isOnTapDown = false;
                      });
                    },
                    onTapUp: (t) {
                      setState(() {
                        _isOnTapDown = false;
                      });
                    },
                    onScaleStart: (ScaleStartDetails s) {
                      _onScaleStart(s);
                    },
                    onScaleUpdate: (ScaleUpdateDetails s) {
                      _onScaleUpdate(s);
                    },
                    onScaleEnd: (ScaleEndDetails s) {
                      _onScaleEnd(s);
                    },
                    child: Stack(
                      clipBehavior:Clip.none,
                      children: [
                        Positioned(
                          left: _coverImageRect!.left,
                          top: _coverImageRect!.top,
                          child: Container(
                            width: _coverImageRect!.width,
                            height: _coverImageRect!.height,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              children: [
                                Positioned(
                                    left: _belowImageRect!.left - _coverImageRect!.left,
                                    top: _belowImageRect!.top - _coverImageRect!.top,
                                    child: Opacity(
                                      opacity: 1,
                                      child: Container(
                                        key: _belowImageKey,
                                        width: _belowImageRect!.width,
                                        height: _belowImageRect!.height,
                                        child: Image.memory(_belowImage!, fit: BoxFit.fill),
                                      ),
                                    ))
                              ],
                            ),
                          ),
                        ),

                        Positioned(
                            left: _belowImageRect!.left,
                            top: _belowImageRect!.top,
                            child: AnimatedOpacity(
                              opacity: (_dragPointerCount != null || _isOnTapDown == true) ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 200),
                              child: Container(
                                width: _belowImageRect!.width,
                                height: _belowImageRect!.height,
                                child: Image.memory(_belowImage!, fit: BoxFit.fill),
                              ),
                            )),

                        //cover
                        if (widget.coverImage != null)
                          Positioned(
                            left: _coverImageRect!.left,
                            top: _coverImageRect!.top,
                            child: IgnorePointer(
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 200),
                                opacity: (_dragPointerCount != null || _isOnTapDown == true) ? 0.8 : 1.0,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(9), //不要設定10,避免下面照片出現在彎角邊緣
                                  child: Container(
                                    width: _coverImageRect!.width,
                                    height: _coverImageRect!.height,
                                    child: Image.asset('assets/images/${widget.coverImage}'),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        //test show result image
                        // if (widget.belowImage == null && _resultImage != null)
                        //   Positioned(
                        //     left: 0,
                        //     right: 0,
                        //     bottom: 0,
                        //     child: Image.memory(
                        //       _resultImage!,
                        //       fit: BoxFit.fitWidth,
                        //       width: _coverImageRect!.width,
                        //     ),
                        //   ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  _onScaleStart(ScaleStartDetails s) {
    _dragLastPistion = s.focalPoint;
    _startScaleBelowImageRect = _belowImageRect;
    if (s.pointerCount == 1) {
      _dragPointerCount = 1;
    } else if (s.pointerCount == 2) {
      _dragPointerCount = 2;
      RenderBox? belowImageBox = _belowImageKey.currentContext?.findRenderObject() as RenderBox?;
      final Offset? touchPositionInImg = belowImageBox?.globalToLocal(s.focalPoint);
      if (touchPositionInImg != null && belowImageBox != null) {
        _touchInImgOffsetRatioX = touchPositionInImg.dx / belowImageBox.size.width;
        _touchInImgOffsetRatioY = touchPositionInImg.dy / belowImageBox.size.height;
      }
    }

    setState(() {});
  }

  _onScaleUpdate(ScaleUpdateDetails s) {
    if (s.pointerCount == 1) {
      if (_dragLastPistion != null) {
        Offset dalta = s.focalPoint - _dragLastPistion!;
        setState(() {
          _belowImageRect = ((dalta + _belowImageRect!.topLeft) & _belowImageRect!.size);
        });
      }
    } else if (s.pointerCount == 2) {
      if (_startScaleBelowImageRect != null && _touchInImgOffsetRatioX != null && _touchInImgOffsetRatioY != null) {
        Size newSize = _startScaleBelowImageRect!.size * s.scale;

        //check size
        // double maxWidth = _belowImageSize!.width * 1.5;
        // double minWidth = _belowImageSize!.width * 0.25;
        double maxWidth = _coverImageRect!.width * 2;
        double minWidth = _coverImageRect!.width * 0.5;
        if (newSize.width > maxWidth) {
          newSize = Size(maxWidth, maxWidth / _belowImageDefaultRect!.width * _belowImageDefaultRect!.height);
        }

        if (newSize.width < minWidth) {
          newSize = Size(minWidth, minWidth / _belowImageDefaultRect!.width * _belowImageDefaultRect!.height);
        }
        double dx = newSize.width * _touchInImgOffsetRatioX!;
        double dy = newSize.height * _touchInImgOffsetRatioY!;
        _belowImageRect = Rect.fromLTWH(s.localFocalPoint.dx - dx, s.localFocalPoint.dy - dy, newSize.width, newSize.height);
        setState(() {});
      }
    }
    _dragLastPistion = s.focalPoint;
  }

  _onScaleEnd(ScaleEndDetails s) {
    int safeArea = 50;

    if (_dragPointerCount == 1) {
      if (_belowImageRect!.right < _coverImageRect!.left + safeArea) {
        _belowImageRect = Rect.fromLTWH(
          (_coverImageRect!.left + safeArea - _belowImageRect!.width).floorToDouble(),
          _belowImageRect!.top.floorToDouble(),
          _belowImageRect!.size.width.floorToDouble(),
          _belowImageRect!.size.height.floorToDouble(),
        );
      }

      if (_belowImageRect!.left > _coverImageRect!.right - safeArea) {
        _belowImageRect = Rect.fromLTWH(
          _coverImageRect!.right - safeArea.floorToDouble(),
          (_belowImageRect!.top).floorToDouble(),
          _belowImageRect!.size.width.floorToDouble(),
          _belowImageRect!.size.height.floorToDouble(),
        );
      }

      if (_belowImageRect!.bottom < _coverImageRect!.top + safeArea) {
        _belowImageRect = Rect.fromLTWH(
          _belowImageRect!.left.floorToDouble(),
          (_coverImageRect!.top + safeArea - _belowImageRect!.size.height).floorToDouble(),
          _belowImageRect!.size.width.floorToDouble(),
          _belowImageRect!.size.height.floorToDouble(),
        );
      }

      if (_belowImageRect!.top > _coverImageRect!.bottom - safeArea) {
        _belowImageRect = Rect.fromLTWH(
          _belowImageRect!.left.floorToDouble(),
          (_coverImageRect!.bottom - safeArea).floorToDouble(),
          _belowImageRect!.size.width.floorToDouble(),
          _belowImageRect!.size.height.floorToDouble(),
        );
      }
    }

    setState(() {
      _dragLastPistion = null;
      _dragPointerCount = null;
      _touchInImgOffsetRatioX = null;
      _touchInImgOffsetRatioY = null;
    });
  }

  _getCoverImageSize() async {
    // 無cover image
    if (widget.coverImage == null) {
      //預設size
      _coverImageSize = const Size(1825, 1311);
    } else {
      final Image image = Image(image: AssetImage('assets/images/${widget.coverImage}'));
      Completer<ui.Image> completer = Completer<ui.Image>();
      image.image.resolve(const ImageConfiguration()).addListener(ImageStreamListener((ImageInfo image, bool _) {
        completer.complete(image.image);
      }));
      ui.Image uiImage = await completer.future;
      _coverImage = uiImage;
      _coverImageSize = Size(uiImage.width.toDouble(), uiImage.height.toDouble());
    }
  }

  _getBelowImageSize() async {
    ui.Image image = await decodeImageFromList(_belowImage!);
    _belowImageSize = Size(image.width.toDouble(), image.height.toDouble());
    setState(() {});
  }

  Future _loadTestImage() async {
    final ByteData bytes = await rootBundle.load("assets/images/test_image_3.jpg");
    _belowImage = bytes.buffer.asUint8List();
    setState(() {});
  }

  Future<Uint8List?> _exportPhoto() async {
    ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    Canvas canvas = Canvas(pictureRecorder);

    Size canvasSize = Size(_coverImageSize?.width ?? 0, _coverImageSize?.height ?? 0);

    Paint bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height), bgPaint);

    if (_belowImage != null) {
      final ui.Image belowUiImage = await decodeImageFromList(_belowImage!);
      Size drawSize = Size(canvasSize.width / _coverImageRect!.width * _belowImageRect!.width, canvasSize.height / _coverImageRect!.height * _belowImageRect!.height);
      double scaleRatio = canvasSize.width / _coverImageRect!.width;
      Offset drawPosition = Offset((_belowImageRect!.left - _coverImageRect!.left) * scaleRatio, (_belowImageRect!.top - _coverImageRect!.top) * scaleRatio);
      canvas.drawImageRect(belowUiImage, Rect.fromLTWH(0, 0, belowUiImage.width.toDouble(), belowUiImage.height.toDouble()), Rect.fromLTWH(drawPosition.dx, drawPosition.dy, drawSize.width, drawSize.height), Paint()..filterQuality = FilterQuality.high);
    }

    if (_coverImage != null) {
      canvas.drawImageRect(
          _coverImage!,
          Rect.fromLTWH(0, 0, _coverImage!.width.toDouble(), _coverImage!.height.toDouble()),
          Rect.fromLTWH(
            0,
            0,
            canvasSize.width,
            canvasSize.height,
          ),
          Paint());
    }

    ui.Image image = await pictureRecorder.endRecording().toImage(canvasSize.width.toInt(), canvasSize.height.toInt());
    ByteData? pngBytes = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List? uint8List = pngBytes?.buffer.asUint8List();

    //test
    // if (widget.belowImage == null) {
    //   setState(() {
    //     _resultImage = uint8List;
    //   });
    // }

    image.dispose();

    return uint8List;
  }
}
