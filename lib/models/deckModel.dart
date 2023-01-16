import 'package:cardflip/data/Leaderboard.dart';
import 'package:cardflip/data/category.dart';
import 'package:cardflip/data/tag.dart';
import 'package:cardflip/models/userModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/deck.dart';
import 'package:cardflip/data/card.dart';
import '../data/User.dart';

class DeckModel {
  final List<Deck> recentDecks = [];
  final List<Deck> userPreferences = [];
  final List<Deck> topRatedDecks = [];
  final _tagCollection = FirebaseFirestore.instance.collection("tag");
  final _deckCollection = FirebaseFirestore.instance.collection("deck");
  final _categoryCollection =
      FirebaseFirestore.instance.collection("categories");
  final UserModel userModel = UserModel();
  Future<List<dynamic>> getData() async {
    QuerySnapshot querySnapshot = await _tagCollection.get();
    final data = querySnapshot.docs.map((doc) => doc.get("name")).toList();
    return data;
  }

  List<Deck> deckByTagID(String id) {
    return recentDecks
        .where((element) => element.tags.where((e) => e.tagID == id).isNotEmpty)
        .toList();
  }

  Deck deckByIDRecent(String id) {
    return recentDecks.where((element) => element.id == id).toList()[0];
  }

  Deck deckByIDPreference(String id) {
    return userPreferences.where((element) => element.id == id).toList()[0];
  }

  Deck deckByID(String id) {
    List<Deck> decks =
        recentDecks.where((element) => element.id == id).toList();
    if (decks.isNotEmpty) {
      return decks[0];
    }
    return userPreferences.where((element) => element.id == id).toList()[0];
  }

  Future<Deck> getdeckByID(String id) async {
    final deck = await _deckCollection.doc(id).get();
    List<Card> cards = [];
    final flashcards = deck.get("flashcards");
    for (int i = 0; i < flashcards.length; i++) {
      cards.add(Card.fromMap(flashcards[i]));
    }
    return Deck(
      name: deck.get("name"),
      description: deck.get("description"),
      rating: double.parse(deck.get('rating')),
      id: deck.id,
      userID: deck.get('userID'),
      cards: cards,
      user: await userModel.getUserByID(deck.get("userID")),
    );
  }

  Future<List<Map>> decksByQuery(String query) async {
    QuerySnapshot querySnapshot = await _deckCollection.get();
    final data = (querySnapshot.docs
        .map((doc) => {"id": doc.id, "name": doc.get("name")})).toList();
    List<Map> result = [];
    for (int i = 0; i < data.length; i++) {
      if (data[i]["name"]
          .trim()
          .toLowerCase()
          .contains(query.trim().toLowerCase())) {
        result.add(data[i]);
      }
    }
    return result;
  }

  Future<List<Category>> getCategories() async {
    QuerySnapshot categories = await _categoryCollection.get();
    return categories.docs.map((doc) {
      final decks = <Deck>[];
      for (int i = 0; i < doc["decks"].length; i++) {
        getdeckByID(doc["decks"][i]).then((value) => decks.add(value));
      }

      return Category.fromSnapshot({
        "id": doc.id,
        "name": doc.get("name"),
        "decks": decks,
        "vector": "Images/vectors/category_${doc.get("name")}.png",
        "background":
            "Images/backgrounds/category_screen/category_${doc.get("name")}.png"
      });
    }).toList();
  }

  Future<List<Deck>> getDecksByIDs(List<String> deckIDs) async {
    QuerySnapshot querySnapshot = await _deckCollection.get();
    List<Deck> data = [];
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      QueryDocumentSnapshot<Object?> doc = querySnapshot.docs[i];
      List<Card> cards = [];
      final flashcards = doc.get("flashcards");
      for (int i = 0; i < flashcards.length; i++) {
        cards.add(Card.fromMap(flashcards[i]));
      }
      if (deckIDs.contains(doc.id)) {
        data.add(Deck(
          name: doc.get("name"),
          description: doc.get("description"),
          rating: double.parse(doc.get('rating')),
          id: doc.id,
          userID: doc.get('userID'),
          cards: cards,
          user: await userModel.getUserByID(doc.get("userID")),
        ));
      }
    }
    return data;
  }

  Future<List<Deck>> getUserPreference(List userTags) async {
    QuerySnapshot querySnapshot = await _deckCollection.get();

    List<Deck> data = [];
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      QueryDocumentSnapshot<Object?> doc = querySnapshot.docs[i];
      if (userTags
          .toSet()
          .intersection(doc.get("tags").toSet())
          .toList()
          .isNotEmpty) {
        if (data.length < 6) {
          List<Card> cards = [];
          final flashcards = doc.get("flashcards");
          for (int i = 0; i < flashcards.length; i++) {
            if (flashcards[i]['id'] != null ||
                flashcards[i]['term'] != null ||
                flashcards[i]['definition'] != null)
              cards.add(Card.fromMap(flashcards[i]));
          }
          data.add(Deck(
            name: doc.get("name"),
            description: doc.get("description"),
            rating: double.parse(doc.get('rating')),
            id: doc.id,
            userID: doc.get('userID'),
            cards: cards,
            user: await userModel.getUserByID(doc.get("userID")),
            // tags:
          ));
        }
      }
    }
    return data;
  }

  Future<List<Tag>> tagsByQuery(String query) async {
    QuerySnapshot querySnapshot = await _tagCollection.get();
    final data = (querySnapshot.docs
        .map((doc) => Tag(tagID: doc.id, name: doc.get("name")))).toList();
    List<Tag> result = [];
    List<Tag> temp = List.from(data);

    for (int i = 0; i < temp.length; i++) {
      if (!(data[data.indexOf(temp[i])]
          .name
          .toLowerCase()
          .trim()
          .contains(query.toLowerCase().trim()))) {
        data.remove(temp[i]);
      }
    }
    return data;
  }

  Future<List<Future<Deck>>> deckByUserID(String id) async {
    final decks = await _deckCollection.where("userID", isEqualTo: id).get();
    return decks.docs
        .map((e) async =>
            Deck.fromSnapshot(e, await userModel.getUserByID(e["userID"])))
        .toList();
  }

  Future leaderboardUsers(String id) async {
    var querySnapshot = await _deckCollection.doc(id).get();

    Map<dynamic, dynamic> data = querySnapshot.data() as Map<dynamic, dynamic>;
    return ((data["leaderboard"] != null) ? data["leaderboard"] : []);
  }

  List<Deck> filter(List<Deck> deckList) {
    /// Sorting the cards by term.
    deckList.sort(((a, b) => a.deckName
        .toLowerCase()
        .trim()
        .compareTo(b.deckName.toLowerCase().trim())));
    return deckList;
  }

  List deckTerms(Deck deck) {
    List<String> terms = [];
    for (Card card in deck.cards) {
      terms.add(card.term);
    }
    return terms;
  }

  int get totalLength => userPreferences.length + recentDecks.length;
}
