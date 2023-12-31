import 'package:cardflip/data/deck.dart';
import 'package:cardflip/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminModel {
  String username = "admin";
  String password = "cardFlip12345";
  String name = "Admin";
  List<String> reports = [];
  List<String> decks = [];
  List<String> users = [];
  final UserModel userModel = UserModel();
  final _userCollection = FirebaseFirestore.instance.collection("user");
  final _deckCollection = FirebaseFirestore.instance.collection("deck");
  final _reportCollection = FirebaseFirestore.instance.collection("reports");

  Future<List> userDataList({String filter = "all"}) async {
    QuerySnapshot querySnapshot;
    if (filter == "all") {
      querySnapshot = await _userCollection
          .where(
            "role",
            isEqualTo: "learner",
          )
          .get();
    } else {
querySnapshot = await _userCollection
          .where(
            "role",
            isEqualTo: "learner",
          )
          .where(
            "banned",
            isEqualTo: filter == "banned" ? true : false,
          )
          .get();
              }
    // QuerySnapshot 
    final data = querySnapshot.docs
        .map((doc) => {
              "fname": doc.get("fname"),
              "lname": doc.get("lname"),
              "profileIcon": doc.get("profileIcon"),
              "username": doc.get("username"),
              "banned": doc.get("banned"),
              "id": doc.id,
            })
        .toList();
    return data;
  }

  Future<List<Future<Deck>>> deckDataList() async {
    QuerySnapshot querySnapshot = await _deckCollection.get();

    final data = querySnapshot.docs.map((doc) async {
      final user = await userModel.userDataByID(doc.get("userID"));
      // List<Card> cards = [];
      // final flashcards = doc.get("flashcards");
      // for (int i = 0; i < flashcards.length; i++) {
      //   cards.add(Card.fromMap(flashcards[i]));
      // }
      return Deck.fromMap({
        "name": doc.get("name"),
        "rating": doc.get("rating"),
        "userID": doc.get("userID"),
        "description": doc.get("description"),
        "id": doc.id,
        "flashcards": doc.get("flashcards"),
        "tags": doc.get("tags"),
        "likes": doc.get("tags"),
      }, user, doc.id);
    }).toList();
    return data;
  }

  Future<List> reportDataList() async {
    QuerySnapshot querySnapshot = await _reportCollection.get();
    final data = querySnapshot.docs
        .map((doc) => {
              "date": doc.get("date"),
              "deckID": doc.get("deckID"),
              "userID": doc.get("userID"),
              "reporterID": doc.get("reporterID"),
              "id": doc.id,
            })
        .toList();
    return data;
  }

  void banUser(String id) {
    _userCollection.doc(id).update({"banned": true});
    //TODO: Show message "User banned"
  }

  void unbanUser(String id) {
    _userCollection.doc(id).update({"banned": false});
    //TODO: Show message "User banned"
  }

  void deleteDeck(String id) {
    _deckCollection.doc(id).delete();
  }
}
