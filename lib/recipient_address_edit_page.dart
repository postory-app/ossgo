import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:ui/tw_cities.dart';

class RecipientAddressEditPage extends StatefulWidget {
  const RecipientAddressEditPage({Key? key}) : super(key: key);

  @override
  State<RecipientAddressEditPage> createState() => _RecipientAddressEditPageState();
}

class _RecipientAddressEditPageState extends State<RecipientAddressEditPage> {
  String? _selectedCity;
  String? _selectedDistrict;

  late List<String> _cityList;
  List<String> _districtsList = [];

  final TextEditingController _postCodeTextEditingCtr = TextEditingController();
  final TextEditingController _addressTextEditingCtr = TextEditingController();

  bool _isFinishBtnCanTap = false;

  final TextStyle _titleTextStyle = const TextStyle(fontSize: 24, fontWeight: FontWeight.w400, color: Color(0xFFFFFEFA));

  double? _editAreaHeight;

  @override
  void initState() {
    _cityList = TwCities.getCityList();
    super.initState();
  }

  @override
  void dispose() {
    _postCodeTextEditingCtr.dispose();
    _addressTextEditingCtr.dispose();
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
                      "收件人住址",
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

                                _editAreaHeight = MediaQuery.of(context).size.height - (MediaQuery.of(context).size.height * 0.1) - textPainter.height - 24;
                              }
                              return _editAreaHeight!;
                            }()),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: const BoxDecoration(color: Color(0xFFFFFEFA), borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                              Expanded(
                                child: SizedBox(
                                  height: 35,
                                  child: DropdownButton(
                                      borderRadius: BorderRadius.circular(10),
                                      dropdownColor: const Color(0xFF028169),
                                      enableFeedback: false,
                                      itemHeight: 60,
                                      elevation: 0,
                                      isExpanded: true,
                                      iconDisabledColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      isDense: true,
                                      iconEnabledColor: Colors.white,
                                      underline: Container(
                                        height: 1,
                                        color: const Color(0xFF028169),
                                      ),
                                      icon: const Padding(padding: EdgeInsets.only(right: 10), child: Icon(Icons.keyboard_arrow_down, color: Color(0xFF028169))),
                                      value: _selectedCity,
                                      onChanged: (String? value) {
                                        if (value != null && _selectedCity != value) {
                                          setState(() {
                                            _selectedCity = value;
                                            _selectedDistrict = null;
                                            _postCodeTextEditingCtr.text = "";
                                            _districtsList = TwCities.getDistrictsList(value);
                                            _checkFinishBtnState();
                                          });
                                        }
                                      },
                                      hint: const Text(
                                        "城市",
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFFCFCECA)),
                                      ),
                                      selectedItemBuilder: (BuildContext ctxt) {
                                        return _cityList.map<Widget>((value) {
                                          return Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              AutoSizeText(
                                                value,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF0F0F0E)),
                                              ),
                                              const Spacer(),
                                            ],
                                          );
                                        }).toList();
                                      },
                                      items: _cityList.map((value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Row(
                                            children: [
                                              Icon(Icons.check, color: (_selectedCity != null && _selectedCity == value) ? const Color.fromARGB(255, 240, 238, 230) : Colors.transparent),
                                              const SizedBox(width: 20),
                                              Text(
                                                value,
                                                style: const TextStyle(color: Color(0xFFFFFEFA), fontWeight: FontWeight.w400, fontSize: 16),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList()),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: SizedBox(
                                  height: 35,
                                  child: DropdownButton(
                                      borderRadius: BorderRadius.circular(10),
                                      dropdownColor: const Color(0xFF028169),
                                      enableFeedback: false,
                                      itemHeight: 60,
                                      elevation: 0,
                                      isExpanded: true,
                                      iconDisabledColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      isDense: true,
                                      iconEnabledColor: Colors.white,
                                      underline: Container(
                                        height: 1,
                                        color: const Color(0xFF028169),
                                      ),
                                      icon: const Padding(padding: EdgeInsets.only(right: 10), child: Icon(Icons.keyboard_arrow_down, color: Color(0xFF028169))),
                                      value: _selectedDistrict,
                                      onChanged: _districtsList.isNotEmpty
                                          ? (String? value) {
                                              if (value != null && _selectedDistrict != value) {
                                                setState(() {
                                                  if (_selectedDistrict != value) {
                                                    _selectedDistrict = value;
                                                    _postCodeTextEditingCtr.text = "";
                                                  }

                                                  if (_selectedCity != null && _selectedDistrict != null) {
                                                    _postCodeTextEditingCtr.text = TwCities.getPostcode(_selectedCity!, _selectedDistrict!) ?? "";
                                                  }
                                                  _checkFinishBtnState();
                                                });
                                              }
                                            }
                                          : null,
                                      hint: const Text(
                                        "區域",
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFFCFCECA)),
                                      ),
                                      selectedItemBuilder: (BuildContext ctxt) {
                                        return _districtsList.map<Widget>((value) {
                                          return Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              AutoSizeText(
                                                value,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF0F0F0E)),
                                              ),
                                              const Spacer(),
                                            ],
                                          );
                                        }).toList();
                                      },
                                      items: _districtsList.map((value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Row(
                                            children: [
                                              Icon(Icons.check, color: (_selectedDistrict != null && _selectedDistrict == value) ? const Color.fromARGB(255, 240, 238, 230) : Colors.transparent),
                                              const SizedBox(width: 20),
                                              Text(
                                                value,
                                                style: const TextStyle(color: Color(0xFFFFFEFA), fontWeight: FontWeight.w400, fontSize: 16),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList()),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: TextField(
                                  controller: _postCodeTextEditingCtr,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF0F0F0E)),
                                  onChanged: (text) {
                                    setState(() {
                                      _checkFinishBtnState();
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFF028169)),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFF028169)),
                                    ),
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFF028169)),
                                    ),
                                    hintText: '郵遞區號',
                                    hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFFCFCECA)),
                                  ),
                                ),
                              ),
                            ]),
                            const SizedBox(height: 36),
                            Flexible(
                              child: TextField(
                                controller: _addressTextEditingCtr,
                                maxLines: null,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF0F0F0E)),
                                onChanged: (text) {
                                  setState(() {
                                    _checkFinishBtnState();
                                  });
                                },
                                decoration: const InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(0xFF028169)),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(0xFF028169)),
                                  ),
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Color(0xFF028169)),
                                  ),
                                  hintText: '詳細住址',
                                  hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFFCFCECA)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
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
                          Opacity(
                            opacity: _isFinishBtnCanTap ? 1 : 0.5,
                            child: UnconstrainedBox(
                              child: TextButton(
                                  style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(const Color(0xFFFFD24A)),
                                      overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.08)),
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18.0),
                                      ))),
                                  onPressed: _isFinishBtnCanTap
                                      ? () {
                                          Navigator.of(context).pop({"city": _selectedCity, "district": _selectedDistrict, "postCode": _postCodeTextEditingCtr.text, "address": _addressTextEditingCtr.text});
                                        }
                                      : null,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    child: const Text(
                                      "完成",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF1F1E1C)),
                                    ),
                                  )),
                            ),
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

  _checkFinishBtnState() {
    _isFinishBtnCanTap = (_selectedCity != null && _selectedDistrict != null && _postCodeTextEditingCtr.text.isNotEmpty && _addressTextEditingCtr.text.isNotEmpty);
  }
}
