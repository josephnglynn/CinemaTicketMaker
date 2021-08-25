import 'dart:convert';
import 'package:cinema_ticket_maker/types/page_size.dart';
import 'package:cinema_ticket_maker/types/ref_number_container.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static late SharedPreferences _prefs;
  static late String cinemaLong;
  static late String cinemaShort;
  static late bool sameRefForEachTicket;
  static late bool shareInsteadOfPrint;
  static late bool includeNames;
  static late bool newUser;
  static late bool share;
  static late double ticketScale;
  static late int digitsForReferenceNumber;
  static late List<RefContainer> referenceContainers;

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

  static Future setCinemaLong(String value) async {
    cinemaLong = value;
    await setString(_cinemaLongLocation, value);
  }

  static Future setTicketScale(double s) async {
    Settings.ticketScale = s;
    await _prefs.setDouble(_ticketScaleLocation, s);
  }

  static Future setIncludeNamesLocation(bool value) async {
    includeNames = value;
    await _prefs.setBool(_includeNamesLocation, value);
  }

  static Future setShareInsteadOfPrint(bool value) async {
    shareInsteadOfPrint = value;
    await _prefs.setBool(_shareIOPL, value);
  }

  static Future setSameRefForEachTicket(bool value) async {
    sameRefForEachTicket = value;
    await _prefs.setBool(_sameRefForEachTicket, value);
  }

  static Future setDigitsForReferenceNumber(int value) async {
    digitsForReferenceNumber = value;
    await _prefs.setInt(_digitsForReferenceNumber, value);
  }

  static Future setIfNewUser(bool value) async {
    newUser = value;
    await _prefs.setBool(_newUser, value);
  }

  static Future setRefContainers(RefContainer refContainer) async {
    referenceContainers.add(refContainer);

    await _prefs.setString(
      _refs,
      jsonEncode({
        "data": referenceContainers.map((e) => e.toJson()).toList(),
      }),
    );
  }

  static Future updateRefContainers() async =>
      await _prefs.setString(
        _refs,
        jsonEncode({
          "data": referenceContainers.map((e) => e.toJson()).toList(),
        }),
      );

  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
    (await getCustomPageSizes() ?? [])
        .map((e) => pageSizes[e.name] = e.pageResolution);
    cinemaLong = getString(_cinemaLongLocation) ?? "ODEON CINEMAS";
    cinemaShort = getString(_cinemaShortLocation) ?? "ODEON";
    shareInsteadOfPrint = _prefs.getBool(_shareIOPL) ?? true;
    includeNames = _prefs.getBool(_includeNamesLocation) ?? false;
    ticketScale = _prefs.getDouble(_ticketScaleLocation) ?? 2;
    sameRefForEachTicket = _prefs.getBool(_sameRefForEachTicket) ?? false;
    digitsForReferenceNumber = _prefs.getInt(_digitsForReferenceNumber) ?? 10;
    newUser = _prefs.getBool(_newUser) ?? true;

    final refNumberData = _prefs.getString(_refs);
    referenceContainers = refNumberData != null
        ? List<dynamic>.from(jsonDecode(refNumberData)["data"])
            .map((e) => RefContainer.fromJson(e))
            .toList()
        : [];
  }

  static const _customPageSizeLocation = "custom_page_size";
  static const _ticketScaleLocation = "ticket_settings";
  static const _cinemaShortLocation = "cinema_short_location";
  static const _cinemaLongLocation = "cinema_long_location";
  static const _shareIOPL = "sInOP";
  static const _includeNamesLocation = "include_name_location";
  static const _sameRefForEachTicket = "sameRefForEachTicket";
  static const _digitsForReferenceNumber = "digitsForReferenceNumber";
  static const _newUser = "new-user";
  static const _refs = "refs";
}
