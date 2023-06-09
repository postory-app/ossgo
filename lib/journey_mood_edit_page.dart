import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/*
android打滿後，退出鍵盤再叫出鍵盤，完成按鈕位置是錯的,ios正常
原因為輸入框若被keybaord遮擋，會導致整個視窗被往上抬下面會多出一段空間
*/
class JourneyMoodEditPage extends StatefulWidget {
  final String? defaultText;
  const JourneyMoodEditPage({Key? key, this.defaultText}) : super(key: key);

  //lib沒有這個字型
  //  static TextStyle textStyle = GoogleFonts.getFont(
  //   "Noto Sans TC ",
  //   letterSpacing: 1,
  //   height: 61.0.toFigmaHeight(50),
  //   fontSize: 50,
  //   fontWeight: FontWeight.w400,
  // );

  static TextStyle textStyle = TextStyle(
    letterSpacing: 1,
    height: 61.0.toFigmaHeight(50),
    fontSize: 50,
    fontWeight: FontWeight.w400,
    fontFamily: "NotoSansTC-Regular",
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  @override
  State<JourneyMoodEditPage> createState() => _JourneyMoodPageEditState();
}

class _JourneyMoodPageEditState extends State<JourneyMoodEditPage> {
  final TextEditingController _textEditingCtr = TextEditingController();

  late int _maxLines;
  int _currentLines = 1;
  double? _editAreaHeight;

  final TextStyle _titleTextStyle = const TextStyle(fontSize: 24, fontWeight: FontWeight.w400, color: Color(0xFFFFFEFA));

  String _currentText = "";

  final double _textAreaMaxWidth = 1022;
  final double _textAreaMaxHeight = 854; //1行是61,908

  double? _contentHeight;
  bool _isOverflow = false;

  // double? _keyboardHeight;

  /*
  final String _testText = '''Dear 溫度寄公司

明信片藉由紙本乘載故事、思想及心情，由郵票及郵戳印出異域文化及特色，等候寄件與收件的時間累積，創造出能真實感受的深刻回憶。明信片讓寄件者傳達獨一無二的心意，讓收件者感受實體交流的珍稀—在書桌前、房間裡、冰箱上，隨時都能體驗世上的片刻風景與記憶。在數位化的時代裡，我們能用科技的力量，讓明信片的傳遞做些什麼改變，來增進人與人之間有溫度的交流?明信片藉由紙本乘載故事、思想及心情，由郵票及郵戳印出異域文化及特色，等候寄件與收件的時間累積，創造出能真實感受的深刻回憶。明信片讓寄件者傳達獨一無二的心意，讓收件者感受實體交流。''';
  */

  @override
  void initState() {
    if (widget.defaultText != null) {
      _textEditingCtr.text = widget.defaultText!;
      _currentLines = getTextFieldLines(widget.defaultText!, JourneyMoodEditPage.textStyle, _textAreaMaxWidth);
      _currentText = widget.defaultText!;
    }

    _maxLines = _calcMaxLines();
    super.initState();
  }

  @override
  void dispose() {
    _textEditingCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // FocusScope.of(context).requestFocus(FocusNode());
      },
      child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
        _contentHeight ??= constraints.maxHeight;
        return Scaffold(
          backgroundColor: Colors.black.withOpacity(0.75),
          // resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  constraints: BoxConstraints(minHeight: _contentHeight!),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // SizedBox(height: _contentHeight! * 0.15),
                      SizedBox(height: _contentHeight! * 0.1),
                      Text(
                        "寫下旅途的心情",
                        textAlign: TextAlign.center,
                        style: _titleTextStyle,
                      ),
                      const SizedBox(height: 24),
                      Flexible(
                        child: Container(
                          constraints: BoxConstraints(
                              maxWidth: 600,
                              minHeight: () {
                                if (_editAreaHeight == null) {
                                  TextPainter textPainter = TextPainter(
                                    text: TextSpan(
                                      text: "寫下旅途的心情",
                                      style: _titleTextStyle,
                                    ),
                                    textDirection: TextDirection.ltr,
                                  );
                                  textPainter.layout();

                                  _editAreaHeight = _contentHeight! - (_contentHeight! * 0.1) - textPainter.height - 24;
                                }
                                return _editAreaHeight!;
                              }()),
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: const BoxDecoration(color: Color(0xFFFFFEFA), borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))), //Color(0xFFFFFEFA)
                          padding: const EdgeInsets.only(left: 20, top: 15, right: 20, bottom: 20),
                          child: FittedBox(
                              alignment: Alignment.topCenter,
                              fit: BoxFit.fitWidth,
                              child: Container(
                                width: _textAreaMaxWidth,
                                height: _textAreaMaxHeight,
                                color: Colors.grey.shade50,
                                child: TextField(
                                    //沒用，要搭配maxLength
                                    // maxLengthEnforcement: MaxLengthEnforcement.truncateAfterCompositionEnds,
                                    scrollPhysics: const NeverScrollableScrollPhysics(),
                                    maxLines: _maxLines,
                                    controller: _textEditingCtr,
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.all(0),
                                      hintText: "請輸入",
                                      hintStyle: TextStyle(fontSize: 50, color: Colors.grey),
                                      border: InputBorder.none,
                                      counterText: "",
                                    ),
                                    onChanged: (String text) {
                                      int currentLines = getTextFieldLines(text, JourneyMoodEditPage.textStyle, _textAreaMaxWidth);
                                      if (currentLines > _maxLines) {
                                        int currentPosition = _textEditingCtr.selection.base.offset - 1;

                                        _textEditingCtr.text = _currentText;

                                        _textEditingCtr.value = _textEditingCtr.value.copyWith(
                                          selection: TextSelection(baseOffset: currentPosition, extentOffset: currentPosition),
                                        );

                                        _isOverflow = true;

                                        // final currentPosition = _textEditingCtr.selection.base.offset - 1;
                                        // _textEditingCtr.text = _getTruncatedText();
                                        // _textEditingCtr.value = _textEditingCtr.value.copyWith(
                                        //   selection: TextSelection(baseOffset: currentPosition, extentOffset: currentPosition),
                                        // );
                                      } else {
                                        _currentText = text;
                                        _currentLines = currentLines;
                                        _isOverflow = false;
                                      }
                                      setState(() {});
                                    },
                                    style: JourneyMoodEditPage.textStyle),
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  // bottom: _keyboardHeight ?? 0, //MediaQuery.of(context).viewInsets.bottom,
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (_isOverflow)
                            Text(
                              "已達最大編輯範圍",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.red.shade300),
                            ),
                          const SizedBox(
                            width: 16,
                          ),
                          Text(
                            "$_currentLines / $_maxLines 行",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: (_isOverflow) ? Colors.red.shade300 : const Color(0xFFB3AA99)),
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          UnconstrainedBox(
                            child: TextButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(const Color(0xFFFFD24A)),
                                    overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.08)),
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                    ))),
                                onPressed: () {
                                  FocusScope.of(context).requestFocus(FocusNode());
                                  Navigator.of(context).pop(_textEditingCtr.text);
                                  // debugPrint("text:${_textEditingCtr.text}");
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  child: const Text(
                                    "完成",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF1F1E1C)),
                                  ),
                                )),
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        );
      }),
    );
  }

  String _getTruncatedText() {
    final text = _textEditingCtr.text;
    TextSpan textSpan = TextSpan(text: text, style: JourneyMoodEditPage.textStyle);
    TextPainter textPainter = TextPainter(text: textSpan, maxLines: _maxLines, textDirection: TextDirection.ltr);
    var truncatedText = "";
    for (var i = _textEditingCtr.text.length - 1; i >= 0; i--) {
      truncatedText = _textEditingCtr.text.substring(0, i);
      textPainter.text = TextSpan(
        text: truncatedText,
        style: JourneyMoodEditPage.textStyle,
      );
      textPainter.layout(maxWidth: _textAreaMaxWidth);
      if (textPainter.didExceedMaxLines) {
        continue;
      } else {
        break;
      }
    }
    // debugPrint("truncatedText=$truncatedText");
    return truncatedText;
  }

  /*
  _isOverflowTypingArea(String text) {
    TextSpan span = TextSpan(
      text: text,
      style: _textStyle,
    );

    TextPainter painter = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
    );

    painter.layout(
      maxWidth: _textAreaMaxWidth,
    );

    // debugPrint("painter.height:${painter.height}");
    double height = painter.height;
    return (height > _textAreaMaxHeight);
  }
  */

  int _calcMaxLines() {
    TextSpan span = TextSpan(
      text: "口",
      style: JourneyMoodEditPage.textStyle,
    );

    TextPainter painter = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
    );

    painter.layout(
      maxWidth: _textAreaMaxWidth,
    );

    return _textAreaMaxHeight ~/ painter.height;
  }

  //ios web計算錯誤,打滿了14行卻顯示10
  //android web正確
  //不準確
  // int getTextFieldLines() {
  //   final text = _textEditingCtr.text;
  //   if (text.isEmpty) {
  //     return 1;
  //   }
  //   return text.split('\n').length;
  // }

  //檢查是否超過行數
  /*
  bool textExceedMaxLines(String text, TextStyle textStyle, int maxLine, double maxWidth) {
    TextSpan textSpan = TextSpan(text: text, style: textStyle);
    TextPainter textPainter = TextPainter(text: textSpan, maxLines: maxLine, textDirection: TextDirection.ltr);
    textPainter.layout(maxWidth: maxWidth);
    print(textPainter.height);
    if (textPainter.didExceedMaxLines) {
      return true;
    }
    return false;
  }
  */

  int getTextFieldLines(String text, TextStyle style, double textFieldWidth) {
    final textSpan = TextSpan(text: text, style: style);
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: textFieldWidth);

    final lines = textPainter.computeLineMetrics();
    return lines.length;
  }

  //ios計算錯誤
  //android正確
  // int _calcCurrentRow(String text) {
  //   TextSpan span = TextSpan(
  //     text: "口",
  //     style: _textStyle,
  //   );
  //   TextPainter painter = TextPainter(
  //     text: span,
  //     textDirection: TextDirection.ltr,
  //   );
  //   painter.layout(
  //     maxWidth: _textAreaMaxWidth,
  //   );

  //   TextSpan span2 = TextSpan(
  //     text: text,
  //     style: _textStyle,
  //   );

  //   TextPainter painter2 = TextPainter(
  //     text: span2,
  //     textDirection: TextDirection.ltr,
  //   );

  //   painter2.layout(
  //     maxWidth: _textAreaMaxWidth,
  //   );

  //   return painter2.height ~/ painter.height;
  // }
}

extension FigmaDimention on double {
  double toFigmaHeight(double fontSize) {
    return this / fontSize;
  }
}
