import 'package:cardflip/data/deck.dart';
import 'package:cardflip/data/search_history_data/history.dart';
import "package:flutter_riverpod/flutter_riverpod.dart";

final SearchProvider = StateProvider<String>((ref) => "");
final SearchSubmitProvider = StateProvider<bool>((ref) => false);
final HistoryProvider = StateProvider<Future<String>>((ref) async {
  await History.init();
  return History.history;
});
