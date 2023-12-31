import 'dart:convert';
import 'package:cardflip/data/Repositories/search_provider.dart';
import 'package:cardflip/data/Repositories/user_state.dart';
import 'package:cardflip/data/search_history_data/history.dart';
import 'package:cardflip/data/search_history_data/history_item.dart';
import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchInputField extends ConsumerStatefulWidget {
  final String hint;
  final TextEditingController controller;
  final TextInputType type;
  const SearchInputField(
      {super.key,
      required this.hint,
      required this.controller,
      this.type = TextInputType.text});

  @override
  ConsumerState<SearchInputField> createState() => _SearchInputFieldState();
}

class _SearchInputFieldState extends ConsumerState<SearchInputField> {
  late Color _currentColor;
  bool resetButton = false;
  @override
  void initState() {
    _currentColor = Colors.transparent;
    super.initState();
  }

  Future initPreferences() async {
    return await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    // final backgroundColor = .opacity(0.5);

    return FutureBuilder(
      future: initPreferences(),
      builder: (context, snapshot) => (snapshot.hasData)
          ? Card(
              elevation: 0.0,
              color: const Color(0x1f1A0404),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: _currentColor,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SvgPicture.asset(
                      "Images/icons/svg/search.svg",
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: TextField(
                          autofocus: true,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              final SharedPreferences prefs = snapshot.data!;
                              List<dynamic> history = History.fromJson(
                                  prefs.getString("historyData3") ?? "[]");
                              HistoryItem item = HistoryItem(
                                  uid: ref.watch(UserDataProvider)!.id,
                                  query: value);
                              if (history
                                  .where((element) =>
                                      element.query.trim().toLowerCase() ==
                                      value.trim().toLowerCase())
                                  .isEmpty) {
                                history.add(item);
                                final data = json.encode(
                                    history.map((e) => e.toJson()).toList());
                                prefs.setString("historyData3", data);
                                ref.read(HistoryProvider.notifier).state =
                                    Future.value(data);
                              }
                              ref.read(SearchProvider.notifier).state = value;
                              ref.read(SearchSubmitProvider.notifier).state =
                                  true;
                              // widget.controller.clear();
                              setState(() {
                                resetButton = false;
                              });
                            }
                          },
                          cursorColor: Colors.grey[600],
                          cursorHeight: 30,
                          onChanged: (value) {
                            ref.read(SearchSubmitProvider.notifier).state =
                                false;
                            if (value.isNotEmpty) {
                              resetButton = true;
                            } else {
                              resetButton = false;
                            }
                            setState(() {});
                          },
                          controller: widget.controller,
                          style: const TextStyle(
                            color: Color(0xff3F3F3F),
                            fontFamily: "PolySans_Neutral",
                            fontSize: 22,
                          ),
                          decoration: InputDecoration.collapsed(
                            // border:,

                            hintText: widget.hint,
                            hintStyle: TextStyle(
                              color: Colors.grey[600],
                              fontFamily: "PolySans_Neutral",
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: resetButton,
                      child: IconButton(
                          onPressed: () {
                            setState(() {
                              widget.controller.clear();
                              ref.read(SearchProvider.notifier).state = "";
                              resetButton = false;
                            });
                          },
                          icon: const Icon(Icons.close)),
                    )
                  ],
                ),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
