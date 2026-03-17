import '../models/matching_model.dart';

class MatchingRepository {
  List<MatchingModel> getData() {
    return [
      MatchingModel(left: "Banjir", right: "Rumah tergenang"),
      MatchingModel(left: "Gempa", right: "Bangunan retak"),
      MatchingModel(left: "Longsor", right: "Tertimbun tanah"),
      MatchingModel(left: "Gunung Meletus", right: "Awan panas"),
    ];
  }
}