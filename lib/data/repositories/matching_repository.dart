import '../models/matching_model.dart';

class MatchingRepository {

  final List<MatchingModel> _allData = [

    /// SET 1
    MatchingModel(left: "Banjir", right: "Rumah tergenang"),
    MatchingModel(left: "Gempa", right: "Bangunan retak"),
    MatchingModel(left: "Longsor", right: "Tertimbun tanah"),
    MatchingModel(left: "Gunung Meletus", right: "Awan panas"),

    /// SET 2
    MatchingModel(left: "Banjir", right: "Air meluap ke jalan"),
    MatchingModel(left: "Gempa", right: "Tanah bergetar"),
    MatchingModel(left: "Longsor", right: "Lereng runtuh"),
    MatchingModel(left: "Gunung Meletus", right: "Lava keluar"),
  ];

  /// 🔥 AMBIL SET TANPA DUPLIKAT LEFT
  List<MatchingModel> getData() {
    final list = List<MatchingModel>.from(_allData);
    list.shuffle();

    final Map<String, MatchingModel> unique = {};

    for (var item in list) {
      if (!unique.containsKey(item.left)) {
        unique[item.left] = item;
      }
    }

    return unique.values.take(4).toList();
  }
}