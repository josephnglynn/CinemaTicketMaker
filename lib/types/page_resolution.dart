class PageResolution {
  final int width;
  final int height;

  const PageResolution(this.height, this.width);

  static PageResolution fromJson(Map<String, dynamic> map) => PageResolution(map["width"], map["height"]);

  Map<String, dynamic> toJson() {
    return {"width": width, "height": height};
  }
}