import 'package:cinema_ticket_maker/types/page_resolution.dart';

class CustomPageSize {
  final String name;
  final PageResolution pageResolution;

  CustomPageSize(this.name, this.pageResolution);

  static CustomPageSize fromJson(Map<String, dynamic> map) =>
      CustomPageSize(map["name"], map["res"]);

  Map<String, dynamic> toJson() {
    return {"name": name, "res": pageResolution};
  }
}

Map<String, PageResolution> pageSizes = {
  "A1": const PageResolution(7016, 9333),
  "A2": const PageResolution(4960, 7016),
  "A3": const PageResolution(3508, 4960),
  "A4": const PageResolution(2480, 3508),
  "A5": const PageResolution(1748, 2480),
};
