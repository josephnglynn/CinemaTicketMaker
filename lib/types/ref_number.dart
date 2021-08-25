class RefNumber {
  final String name;
  final String number;

  const RefNumber(this.name, this.number);

  Map<String, dynamic> toJson() => {
    "name": name,
    "number": number
  };

  static RefNumber fromJson(Map<String, dynamic> map) => RefNumber(map["name"], map["number"]);
}
