import 'package:flutter/material.dart';

class RecipientNameEditPage extends StatefulWidget {
  const RecipientNameEditPage({Key? key}) : super(key: key);

  @override
  State<RecipientNameEditPage> createState() => _RecipientNameEditPageState();
}

class _RecipientNameEditPageState extends State<RecipientNameEditPage> {
  final TextEditingController _textEditingCtr = TextEditingController();

  final int _maxLength = 8;
  double? _editAreaHeight;
  final TextStyle _titleTextStyle = const TextStyle(fontSize: 24, fontWeight: FontWeight.w400, color: Color(0xFFFFFEFA));

  @override
  void dispose() {
    _textEditingCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.75),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    Text(
                      "收件人姓名",
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
                                    text: "收件人姓名",
                                    style: _titleTextStyle,
                                  ),
                                  textDirection: TextDirection.ltr,
                                );
                                textPainter.layout();

                                _editAreaHeight = MediaQuery.of(context).size.height - (MediaQuery.of(context).size.height * 0.1) - textPainter.height - 24;
                              }
                              return _editAreaHeight!;
                            }()),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: const BoxDecoration(color: Color(0xFFFFFEFA), borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
                        padding: const EdgeInsets.only(left: 0, top: 15, right: 0, bottom: 20),
                        child: TextField(
                          controller: _textEditingCtr,
                          maxLines: null,
                          maxLength: _maxLength,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            hintText: "請輸入",
                            hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
                            border: InputBorder.none,
                            counterText: "",
                          ),
                          onChanged: (String text) {
                            setState(() {});
                          },
                        ),
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
                child: SafeArea(
                  top: false,
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "${_textEditingCtr.text.length} / $_maxLength",
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFB3AA99)),
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
                                  Navigator.of(context).pop(_textEditingCtr.text);
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
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
