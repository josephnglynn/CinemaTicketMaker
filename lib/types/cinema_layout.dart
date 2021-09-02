class _Row {
  int length;
  String rowIdentifier;

  _Row(this.rowIdentifier, this.length);

  Map<String, dynamic> toJson() => {
        "length": length,
        "rowIdentifier": rowIdentifier,
      };

  static _Row fromJson(Map<String, dynamic> map) => _Row(
        map["rowIdentifier"],
        map["length"],
      );
}

class CinemaLayout {
  List<_Row> rows = [];

  CinemaLayout(this.rows);

  void addRow(String rowIdentifier, int length) {
    rows.add(_Row(rowIdentifier, length));
  }

  Map<String, dynamic> toJson() => {
        "data": rows.map((e) => e.toJson()).toList(),
      };

  static CinemaLayout fromJson(Map<String, dynamic> map) => CinemaLayout(
        List<dynamic>.from(map["data"]).map((e) => _Row.fromJson(e)).toList(),
      );
}
