// ignore_for_file: unnecessary_new
import 'package:cardflip/widgets/library/library_list.dart';
import "package:flutter/material.dart";
import '../helpers/random_generator.dart';
import '../models/deck_model.dart';

class Library extends StatefulWidget {
  const Library({super.key});

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  late RandomGenerator cardgenerator;
  late DeckModel deckModel;
  late Widget _consumerState;
  late AssetImage _banner;
  late Widget _header;
  Map<String, bool> status = {"all": true, "user": false, "others": false};
  final List<Widget> _listBuilder = [
    LibraryList(
      temp: [],
    ),
    LibraryList(
      state: "user",
      temp: [],
    ),
    LibraryList(
      state: "others",
      temp: [],
    )
  ];

  @override
  void initState() {
    deckModel = DeckModel();
    cardgenerator = RandomGenerator();
    _banner = AssetImage(
        "Images/banners/librarypage/${cardgenerator.librarycolor}.png");
    _header = Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: _banner,
          fit: BoxFit.cover,
        ),
      ),
      // width: 400,
      height: 190,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 40.0, bottom: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Text(
                  "Library",
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontFamily: "PolySans_Median",
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    fontSize: 48,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    _consumerState = LibraryList(
      temp: [],
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage("Images/backgrounds/librarypage.png"),
            fit: BoxFit.cover),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _header,
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                          onTap: () {
                            if (!status["all"]!) {
                              status["all"] = true;
                              status["user"] = false;
                              status["others"] = false;
                              _consumerState = LibraryList(
                                temp: [],
                              );
                              setState(() {});
                            }
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  color: (status["all"]!)
                                      ? const Color.fromARGB(31, 10, 1, 1)
                                      : Colors.transparent,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12))),
                              width: 48,
                              height: 48,
                              child: Center(
                                  child: Text(
                                "All",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: const Color(0xff484848),
                                    fontSize: 20,
                                    fontFamily: "PolySans_Neutral",
                                    fontWeight: (status["all"]! == true)
                                        ? FontWeight.w600
                                        : FontWeight.normal),
                              )))),
                      GestureDetector(
                        onTap: () {
                          if (!status["user"]!) {
                            status["all"] = false;
                            status["user"] = true;
                            status["others"] = false;
                            _consumerState = LibraryList(
                              state: "user",
                              temp: [],
                            );
                            setState(() {});
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: (status["user"]!)
                                  ? const Color.fromARGB(31, 10, 1, 1)
                                  : Colors.transparent,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(12))),
                          width: 48,
                          height: 48,
                          child: Center(
                            child: Text(
                              "Yours",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: "PolySans_Neutral",
                                  fontWeight: (status["user"]!)
                                      ? FontWeight.w600
                                      : FontWeight.normal),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (!status["others"]!) {
                            status["all"] = false;
                            status["user"] = false;
                            status["others"] = true;
                            _consumerState = LibraryList(
                              state: "others",
                              temp: [],
                            );
                            setState(() {});
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: (status["others"]!)
                                  ? const Color.fromARGB(31, 10, 1, 1)
                                  : Colors.transparent,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(12))),
                          width: 55,
                          height: 48,
                          child: Center(
                            child: Text(
                              "Others",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: "PolySans_Neutral",
                                  fontWeight: (status["others"]!)
                                      ? FontWeight.w600
                                      : FontWeight.normal),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/adddeck');
                        },
                        child: Container(
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage("Images/icons/add.png"),
                                  fit: BoxFit.cover),
                            ),
                            width: 48,
                            height: 48,
                            child: const Text(""))),
                  ),
                ),
              ],
            ),
          ),
          _consumerState
        ],
      ),
    );
  }
}
