import 'dart:convert';
import 'package:cinema_ticket_maker/types/pagesize.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static late SharedPreferences _prefs;
  static late String cinemaLong;
  static late String cinemaShort;

  static String? getString(String key) => _prefs.getString(key);

  static Future setString(String key, String value) async =>
      await _prefs.setString(key, value);

  static Future<List<CustomPageSize>?> getCustomPageSizes() async {
    String? result = _prefs.getString(_customPageSizeLocation);
    if (result == null) return null;

    return List<Map<String, dynamic>>.from(jsonDecode(result)["data"])
        .map((e) => CustomPageSize.fromJson(e))
        .toList();
  }

  static Future setCustomPageSizes(List<CustomPageSize> value) async {
    await _prefs.setString(
      _customPageSizeLocation,
      jsonEncode(
        {"data": value.map((e) => e.toJson()).toList()},
      ),
    );
  }

  static Future setCinemaShort(String value) async {
    cinemaShort = value;
    await setString(_cinemaShortLocation, value);
  }

  static Future setCinemaLong(String value)async {
    cinemaLong = value;
   await  setString(_cinemaLongLocation, value);
  }

  static double getTicketScale() => _prefs.getDouble(_ticketScaleLocation) ?? 1;

  static Future setTicketScale(double s) async =>
      await _prefs.setDouble(_ticketScaleLocation, s);

  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
    (await getCustomPageSizes() ?? [])
        .map((e) => pageSizes[e.name] = e.pageResolution);
    cinemaLong = getString(_cinemaLongLocation) ?? "ODEON CINEMAS";
    cinemaShort = getString(_cinemaShortLocation) ?? "ODEON";
  }

  static const _customPageSizeLocation = "custom_page_size";
  static const _ticketScaleLocation = "ticket_settings";
  static const _cinemaShortLocation = "cinema_short_location";
  static const _cinemaLongLocation = "cinema_long_location";
}
