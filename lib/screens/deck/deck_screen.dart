import 'dart:convert';
import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cardflip/data/Repositories/flashcard_state.dart';
import 'package:cardflip/data/Repositories/user_decks.dart';
import 'package:cardflip/data/Repositories/user_state.dart';
import 'package:cardflip/data/deck.dart';
import 'package:cardflip/data/uncompleted_decks_data/uncompleted_deck_item.dart';
import 'package:cardflip/data/uncompleted_decks_data/uncompleted_decks.dart';
import 'package:cardflip/models/admin_model.dart';
import 'package:cardflip/models/deck_model.dart';
import 'package:cardflip/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:no_glow_scroll/no_glow_scroll.dart';
import "package:flutter_riverpod/flutter_riverpod.dart";
import 'package:recase/recase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../helpers/random_generator.dart';
import '../../models/flashcards_model.dart';
import 'term_card.dart' as term_card;
import 'package:cardflip/data/card.dart' as card_data;

class DeckScreen extends ConsumerStatefulWidget {
  final bool backhome;
  final Deck deck;
  const DeckScreen({Key? key, required this.deck, required this.backhome})
      : super(key: key);

  @override
  ConsumerState<DeckScreen> createState() => _MyDeckScreenState();
}

class _MyDeckScreenState extends ConsumerState<DeckScreen> {
  late FlashcardModel model;
  final heartState = ["heart_outline", "heart_filled"];
  final RandomGenerator _cardGen = RandomGenerator();
  final deckModel = DeckModel();
  final userModel = UserModel();

  late Widget _cards;
  bool _isFiltered = false;
  int counter = 0;
  late int _randomBanner;

  @override
  void initState() {
    super.initState();
    model = FlashcardModel(deck: widget.deck);
    _cards = cardList(model.getCards);
    _randomBanner = Random().nextInt(6);
  }

  Future initPreferences() async {
    return await SharedPreferences.getInstance();
  }

  Widget cardList(List<card_data.Card> cardList) {
    return Expanded(
      child: NoGlowScroll(
        child: ListView(
          children: [
            for (int index = 0; index < cardList.length; index += 2)
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
                child: Row(
                  mainAxisAlignment: (index + 1 < cardList.length)
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.start,
                  children: [
                    for (int i = 0;
                        i <= (index + 1 < cardList.length ? 1 : 0);
                        i++)
                      term_card.Card(
                        id: widget.deck.id,
                        deck: widget.deck,
                        index: cardList[index + i].id,
                        cardName: cardList[index + i].term,
                        path:
                            "Images/cards/librarypage/${_cardGen.getcolor}/${_cardGen.getshape}.png",
                      ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget filter() => GestureDetector(
        onTap: () {
          setState(() {
            if (_isFiltered == false) {
              model.filter();
              _cards = cardList(model.getCards);
              _isFiltered = true;
            }
          });
        },
      );
  @override
  Widget build(BuildContext context) {
    final favourites = ref.watch(FavouritesProvider);
    final ratings = ref.watch(RatingProvider);
    final reports = ref.watch(ReportProvider);
    final userData = ref.watch(UserDataProvider);
    final userID = userData!.id;
    bool isReported = (reports.contains(model.deck.id));
    dynamic size = MediaQuery.of(context).size;
    return Scaffold(
      body: FutureBuilder(
          future: initPreferences(),
          builder: (context, snapshot) {
            return Container(
              height: size.height,
              width: size.width,
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("Images/backgrounds/deckpage.png"),
                    fit: BoxFit.cover),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 410,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                              "Images/banners/deckpage/$_randomBanner.png"),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: ((widget.deck.userID == userData.id))
                              ? const EdgeInsets.fromLTRB(30.0, 20, 20, 20)
                              : const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 15.0,
                                ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                      onTap: () {
                                        if (userData.role == "learner") {
                                          if (widget.backhome) {
                                            Navigator.pushReplacementNamed(
                                                context, "/home");
                                          } else {
                                            Navigator.pop(context);
                                          }
                                        } else if (userData.role == "admin") {
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: Container(
                                          decoration: const BoxDecoration(
                                            image: DecorationImage(
                                                image: AssetImage(
                                                    "Images/icons/arrow-left-s-line.png"),
                                                fit: BoxFit.cover),
                                          ),
                                          width: 40,
                                          height: 40,
                                          child: const Text(""))),
                                  SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: PopupMenuButton(
                                      color: Colors.white,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8.0),
                                        ),
                                      ),
                                      icon: SvgPicture.asset(
                                          "Images/icons/svg/more-fill.svg"),
                                      itemBuilder: (BuildContext context) => [
                                        if (userData.role == "learner")
                                          PopupMenuItem(
                                            enabled: !isReported,
                                            onTap: () {
                                              if (!reports
                                                  .contains(model.deck.id)) {
                                                ref
                                                        .read(ReportProvider
                                                            .notifier)
                                                        .state =
                                                    reports + [model.deck.id];
                                                isReported = true;
                                                deckModel.addReport(
                                                    widget.deck.id,
                                                    widget.deck.user["id"],
                                                    userData.id);
                                              }
                                            },
                                            child: Wrap(
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              children: const [
                                                Icon(Icons.flag),
                                                SizedBox(width: 10),
                                                Text("Report"),
                                              ],
                                            ),
                                          ),
                                        // PopupMenuItem(
                                        //   onTap: () => filter(),
                                        //   child: Wrap(
                                        //     crossAxisAlignment:
                                        //         WrapCrossAlignment.center,
                                        //     children: const [
                                        //       Icon(Icons.sort_by_alpha_rounded,
                                        //           size: 23),
                                        //       SizedBox(width: 10),
                                        //       Text("Sort alphabetically"),
                                        //     ],
                                        //   ),
                                        // ),
                                        PopupMenuItem(
                                          onTap: () {
                                            deckModel
                                                .deleteDeck(widget.deck.id)
                                                .then((value) {
                                              if (widget.backhome) {
                                                Navigator.pushReplacementNamed(
                                                    context, "/home");
                                              } else {
                                                Navigator.pop(context);
                                              }
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      duration:
                                                          Duration(seconds: 3),
                                                      content: Text(
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  "Poppins"),
                                                          'Deck Deleted.')));
                                            });
                                          },
                                          child: Wrap(
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            children: const [
                                              Icon(Icons.delete_forever,
                                                  size: 23),
                                              SizedBox(width: 10),
                                              Text("Delete deck"),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              // const SizedBox(height: 25),
                              AutoSizeText(
                                model.deck.deckName,
                                maxLines: 1,
                                minFontSize: 12,
                                overflow: TextOverflow.ellipsis,
                                stepGranularity: 1,
                                style: TextStyle(
                                  fontFamily: "PolySans_Median",
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  fontSize:
                                      (MediaQuery.of(context).size.width > 320)
                                          ? 48
                                          : 40,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Text(
                                  model.deck.deckDescription,
                                  style: const TextStyle(
                                    fontFamily: "PolySans_Neutral",
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(255, 52, 52, 52),
                                    fontSize: 20,
                                  ),
                                ),
                              ),

                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${widget.deck.cards.length} Flashcards",
                                        style: TextStyle(
                                          fontFamily: "PolySans_Median",
                                          fontWeight: FontWeight.w500,
                                          color: const Color.fromARGB(
                                              255, 60, 58, 62),
                                          fontSize: (MediaQuery.of(context)
                                                      .size
                                                      .width >
                                                  322)
                                              ? 30
                                              : 22,
                                        ),
                                      ),
                                      if (widget.deck.userID != userData.id)
                                        Row(
                                          children: [
                                            GestureDetector(
                                                onTap: () => Future(() =>
                                                    Navigator.pushNamed(
                                                        context, '/leaderboard',
                                                        arguments: {
                                                          "deck": widget.deck
                                                        })),
                                                child: Container(
                                                  width: 45,
                                                  height: 45,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Color(0x0f1a0404),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                12)),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Image.asset(
                                                        "Images/icons/leaderboard.png",
                                                        width: 40,
                                                        height: 40),
                                                  ),
                                                )),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            userData.role == "learner"
                                                ? GestureDetector(
                                                    onTap: () async {
                                                      if (!favourites.contains(
                                                          model.deck.id)) {
                                                        ref
                                                                .read(FavouritesProvider
                                                                    .notifier)
                                                                .state =
                                                            favourites +
                                                                [model.deck.id];
                                                      } else {
                                                        List<String> temp = ref
                                                            .read(
                                                                FavouritesProvider
                                                                    .notifier)
                                                            .state;
                                                        temp.remove(
                                                            model.deck.id);
                                                        ref
                                                            .read(
                                                                FavouritesProvider
                                                                    .notifier)
                                                            .state = temp;
                                                        setState(() {});
                                                      }
                                                      await userModel
                                                          .updateFavourites(
                                                              favourites,
                                                              userData);
                                                    },
                                                    child: Container(
                                                      width: 45,
                                                      height: 45,
                                                      decoration:
                                                          const BoxDecoration(
                                                        color:
                                                            Color(0x0f1a0404),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    12)),
                                                      ),
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: SvgPicture.asset(
                                                              "Images/icons/svg/${heartState[favourites.contains(model.deck.id) ? 1 : 0]}.svg",
                                                              width: 45,
                                                              height: 45)),
                                                    ))
                                                : GestureDetector(
                                                    onTap: () {
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return Center(
                                                              child: Container(
                                                                width: 300,
                                                                height: 200,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  image: const DecorationImage(
                                                                      image: AssetImage(
                                                                          "Images/backgrounds/homepage.png"),
                                                                      fit: BoxFit
                                                                          .cover),
                                                                ),
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceAround,
                                                                  children: [
                                                                    const SizedBox(
                                                                        height:
                                                                            10),
                                                                    const Text(
                                                                      "Confirm Deletion!",
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            "PolySans_Median",
                                                                        color: Color.fromARGB(
                                                                            239,
                                                                            105,
                                                                            0,
                                                                            0),
                                                                        fontSize:
                                                                            20,
                                                                      ),
                                                                    ),
                                                                    const Text(
                                                                      "Are you sure you want to delete this deck?",
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            "PolySans_Slim",
                                                                        color: Color.fromARGB(
                                                                            239,
                                                                            105,
                                                                            0,
                                                                            0),
                                                                        fontSize:
                                                                            15,
                                                                      ),
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        ButtonBar(
                                                                            children: [
                                                                              TextButton(
                                                                                child: const Text("Cancel"),
                                                                                onPressed: () {
                                                                                  Navigator.of(context).pop();
                                                                                },
                                                                              ),
                                                                              TextButton(
                                                                                child: const Text("Yes"),
                                                                                onPressed: () {
                                                                                  AdminModel().deleteDeck(widget.deck.id);
                                                                                  Navigator.of(context).pop();
                                                                                  showDialog(
                                                                                    context: context,
                                                                                    builder: (BuildContext context) {
                                                                                      return Center(
                                                                                        child: Container(
                                                                                          width: 300,
                                                                                          height: 200,
                                                                                          decoration: BoxDecoration(
                                                                                            borderRadius: BorderRadius.circular(10),
                                                                                            image: const DecorationImage(image: AssetImage("Images/backgrounds/homepage.png"), fit: BoxFit.cover),
                                                                                          ),
                                                                                          child: Column(
                                                                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                            children: [
                                                                                              const SizedBox(height: 10),
                                                                                              const Text(
                                                                                                "Banned!",
                                                                                                style: TextStyle(
                                                                                                  fontFamily: "PolySans_Median",
                                                                                                  color: Color.fromARGB(239, 105, 0, 0),
                                                                                                  fontSize: 20,
                                                                                                ),
                                                                                              ),
                                                                                              const Text(
                                                                                                "Deck Banned Successfully",
                                                                                                style: TextStyle(
                                                                                                  fontFamily: "PolySans_Slim",
                                                                                                  color: Color.fromARGB(239, 105, 0, 0),
                                                                                                  fontSize: 20,
                                                                                                ),
                                                                                              ),
                                                                                              Row(
                                                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                                                                children: [
                                                                                                  TextButton(
                                                                                                    child: const Text("Close"),
                                                                                                    onPressed: () {
                                                                                                      Navigator.of(context).pop();
                                                                                                    },
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      );
                                                                                    },
                                                                                  );
                                                                                },
                                                                              ),
                                                                            ]),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          });
                                                    },
                                                    child: Container(
                                                        decoration:
                                                            const BoxDecoration(
                                                          image: DecorationImage(
                                                              image: AssetImage(
                                                                  "Images/icons/banDeck.png"),
                                                              fit:
                                                                  BoxFit.cover),
                                                        ),
                                                        width: 45,
                                                        height: 45,
                                                        child: const Text("")),
                                                  ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        if (widget.deck.userID != userData.id)
                                          GestureDetector(
                                              onTap: () {},
                                              child: Row(
                                                children: [
                                                  Row(
                                                    children: [
                                                      SvgPicture.asset(
                                                        "Images/avatars/${widget.deck.user["profileIcon"]}.svg",
                                                        width: 35,
                                                        height: 35,
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Text(
                                                        ReCase(widget.deck
                                                                .user["fname"])
                                                            .titleCase,
                                                        style: const TextStyle(
                                                          fontFamily:
                                                              "PolySans_Slim",
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Color.fromARGB(
                                                              255, 52, 52, 52),
                                                          fontSize: 22,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              )),
                                        GestureDetector(
                                            onTap: () {
                                              if (userData.role == "learner") {
                                                if (model.deck.userID ==
                                                    userData.id) {
                                                  return;
                                                } else {
                                                  if (!ratings.contains(
                                                      model.deck.id)) {
                                                    model.deck
                                                        .incrementRating();
                                                    ref
                                                            .read(RatingProvider
                                                                .notifier)
                                                            .state =
                                                        ratings +
                                                            [widget.deck.id];
                                                    deckModel
                                                        .addLike(widget.deck.id,
                                                            userData.id)
                                                        .then((value) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(const SnackBar(
                                                              behavior:
                                                                  SnackBarBehavior
                                                                      .floating,
                                                              duration:
                                                                  Duration(
                                                                      seconds:
                                                                          3),
                                                              content: Text(
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          "Poppins"),
                                                                  'Deck is now liked!')));
                                                    });
                                                  } else {
                                                    widget.deck
                                                        .decrementRating();
                                                    List<String> temp = ref
                                                        .read(RatingProvider
                                                            .notifier)
                                                        .state;
                                                    temp.remove(widget.deck.id);
                                                    ref
                                                            .read(RatingProvider
                                                                .notifier)
                                                            .state =
                                                        <String>[] + temp;
                                                    deckModel.removeLike(
                                                        widget.deck.id,
                                                        userData.id);

                                                    setState(() {});
                                                  }
                                                }
                                              } else {
                                                {}
                                              }
                                            },
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                    width: (ratings.contains(
                                                                model
                                                                    .deck.id) ||
                                                            model.deck.userID !=
                                                                userData.id)
                                                        ? 28
                                                        : 26,
                                                    height: (ratings.contains(
                                                                model
                                                                    .deck.id) ||
                                                            model.deck.userID !=
                                                                userData.id)
                                                        ? 28
                                                        : 26,
                                                    child: SvgPicture.asset(
                                                      "Images/icons/svg/like-${(ratings.contains(model.deck.id) || model.deck.userID == userData.id) ? "fill" : "line"}.svg",
                                                    )),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  model.deck.deckRating,
                                                  style: const TextStyle(
                                                    fontFamily: "PolySans_Slim",
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xff514F55),
                                                    fontSize: 23,
                                                  ),
                                                ),
                                              ],
                                            )),
                                        if (widget.deck.userID == userData.id)
                                          Row(
                                            children: [
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              GestureDetector(
                                                  onTap: () => Future(() =>
                                                      Navigator.pushNamed(
                                                          context,
                                                          '/leaderboard',
                                                          arguments: {
                                                            "deck": widget.deck
                                                          })),
                                                  child: Container(
                                                    width: 45,
                                                    height: 45,
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Color(0x0f1a0404),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  12)),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Image.asset(
                                                          "Images/icons/leaderboard.png",
                                                          width: 40,
                                                          height: 40),
                                                    ),
                                                  )),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              GestureDetector(
                                                  onTap: () {
                                                    Navigator.pushNamed(
                                                        context, '/editdeck',
                                                        arguments: {
                                                          "deck": widget.deck
                                                        });
                                                  },
                                                  child: Container(
                                                    width: 45,
                                                    height: 45,
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Color(0xf1A0404),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  12)),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: SvgPicture.asset(
                                                          "Images/icons/svg/edit.svg",
                                                          width: 28,
                                                          height: 28),
                                                    ),
                                                  )),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              GestureDetector(
                                                  onTap: () {
                                                    Navigator.pushNamed(context,
                                                        "/addFlashcards",
                                                        arguments: {
                                                          'deck': widget.deck
                                                        });
                                                  },
                                                  child: Container(
                                                    width: 45,
                                                    height: 45,
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Color(0xf1A0404),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  12)),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: SvgPicture.asset(
                                                          "Images/icons/svg/add.svg",
                                                          width: 25,
                                                          height: 25),
                                                    ),
                                                  )),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                            ],
                                          )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (userData.role == "learner")
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (snapshot.hasData) {
                                final SharedPreferences prefs = snapshot.data!;
                                List<dynamic> uncompleteDecks =
                                    UncompletedDecks.fromJson(prefs.getString(
                                            "uncompleted_decks_${userData.id}") ??
                                        "[]");
                                UncompletedDeckItem item = UncompletedDeckItem(
                                    uid: userID, deckID: widget.deck.id);
                                if (uncompleteDecks
                                    .where((e) =>
                                        e.deckID.trim().toLowerCase() ==
                                        item.deckID.trim().toLowerCase())
                                    .isEmpty) {
                                  uncompleteDecks.add(item);
                                  final data = json.encode(uncompleteDecks
                                      .map((e) => e.toJson())
                                      .toList());
                                  prefs.setString(
                                      "uncompleted_decks_${userData.id}", data);
                                }
                              }
                              ref.read(FlashcardStateProvider.notifier).state =
                                  "1";
                              Navigator.pushNamed(context, '/flashcards',
                                  arguments: {"deck": widget.deck});
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage("Images/icons/bar.png"),
                                    fit: BoxFit.cover),
                              ),
                              width: 136.71,
                              height: 55,
                              child: const Center(
                                child: Text(
                                  "Study",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontFamily: "PolySans_Median",
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (widget.deck.cards.length < 3) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                        behavior: SnackBarBehavior.floating,
                                        duration: Duration(seconds: 3),
                                        content: Text(
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: "Poppins"),
                                            'You can start a test once you have created at least 3 cards!')))
                                    .closed
                                    .then((value) =>
                                        ScaffoldMessenger.of(context)
                                            .clearSnackBars());
                                return;
                              } else {
                                Navigator.pushReplacementNamed(context, '/test',
                                    arguments: {"deck": widget.deck});
                              }
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage("Images/icons/bar.png"),
                                    fit: BoxFit.cover),
                              ),
                              width: 136.71,
                              height: 55,
                              child: const Center(
                                child: Text(
                                  "Test",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontFamily: "PolySans_Median",
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    const SizedBox(
                      height: 20,
                    ),
                    _cards
                  ]),
            );
          }),
    );
  }
}
