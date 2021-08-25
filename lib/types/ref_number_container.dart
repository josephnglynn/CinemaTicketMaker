import 'package:cinema_ticket_maker/types/ref_number.dart';

class RefContainer {
  List<RefNumber> refNumbers;
  String info;

  RefContainer(this.refNumbers, this.info);

  Map<String, dynamic> toJson() =>
      {
        "info": info,
        "data": refNumbers.map((e) => e.toJson()).toList(),
      };

  static RefContainer fromJson(Map<String, dynamic> map) =>
      RefContainer(List<Map<String, dynamic>>.from(map["data"]).map((e) =>
          RefNumber.fromJson(e)).toList(), map["info"]);
}