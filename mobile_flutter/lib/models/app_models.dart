class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String country;
  final String preferredCurrency;
  final String preferredLanguage;
  final String travelStyle;
  final String emergencyContact;
  final String photoUrl;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.phone = '',
    this.country = '',
    this.preferredCurrency = 'USD',
    this.preferredLanguage = 'English',
    this.travelStyle = 'Balanced comfort',
    this.emergencyContact = '',
    this.photoUrl = '',
  });

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) {
      return email.isNotEmpty ? email[0].toUpperCase() : '?';
    }
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  factory UserProfile.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserProfile(
      uid: uid,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      country: data['country'] as String? ?? '',
      preferredCurrency: data['preCurrency'] as String? ?? 'USD',
      preferredLanguage: data['preLanguage'] as String? ?? 'English',
      travelStyle: data['preTravelStyle'] as String? ?? 'Balanced comfort',
      emergencyContact: data['emerContact'] as String? ?? '',
      photoUrl: data['photoURL'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'country': country,
      'preCurrency': preferredCurrency,
      'preLanguage': preferredLanguage,
      'preTravelStyle': travelStyle,
      'emerContact': emergencyContact,
      'photoURL': photoUrl,
    };
  }

  UserProfile copyWith({String? name, String? email, String? photoUrl}) {
    return UserProfile(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone,
      country: country,
      preferredCurrency: preferredCurrency,
      preferredLanguage: preferredLanguage,
      travelStyle: travelStyle,
      emergencyContact: emergencyContact,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}

/// Backend-backed trip record. Mirrors the MySQL `trips` table.
class TripModel {
  final int id;
  final int userId;
  final String title;
  final String? destinationName;
  final String startDate; // YYYY-MM-DD
  final String endDate; // YYYY-MM-DD
  final double budget;
  final String currency;
  final String? notes;
  final String status; // 'planned', 'ongoing', 'completed'
  final DateTime? createdAt;

  TripModel({
    required this.id,
    required this.userId,
    required this.title,
    this.destinationName,
    required this.startDate,
    required this.endDate,
    required this.budget,
    required this.currency,
    this.notes,
    required this.status,
    this.createdAt,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      title: json['title'] ?? '',
      destinationName: json['destination_name'] as String?,
      startDate: _dateOnly(json['start_date']),
      endDate: _dateOnly(json['end_date']),
      budget: double.tryParse('${json['budget']}') ?? 0.0,
      currency: json['currency'] ?? 'MYR',
      notes: json['notes'] as String?,
      status: json['status'] ?? 'planned',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse('${json['created_at']}')
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'destination_name': destinationName,
        'start_date': startDate,
        'end_date': endDate,
        'budget': budget,
        'currency': currency,
        'notes': notes,
        'status': status,
      };

  DateTime? get start => DateTime.tryParse(startDate);
  DateTime? get end => DateTime.tryParse(endDate);

  int get dayCount {
    final from = start;
    final to = end;
    if (from == null || to == null) return 0;
    return to.difference(from).inDays + 1;
  }
}

/// One calendar day of a trip. Mirrors the MySQL `itineraries` table.
class ItineraryModel {
  final int id;
  final int tripId;
  final String date; // YYYY-MM-DD
  final String? title;
  final String? notes;

  ItineraryModel({
    required this.id,
    required this.tripId,
    required this.date,
    this.title,
    this.notes,
  });

  factory ItineraryModel.fromJson(Map<String, dynamic> json) {
    return ItineraryModel(
      id: (json['id'] as num).toInt(),
      tripId: (json['trip_id'] as num?)?.toInt() ?? 0,
      date: _dateOnly(json['date']),
      title: json['title'] as String?,
      notes: json['notes'] as String?,
    );
  }

  ItineraryModel copyWith({String? title, String? notes}) {
    return ItineraryModel(
      id: id,
      tripId: tripId,
      date: date,
      title: title ?? this.title,
      notes: notes ?? this.notes,
    );
  }

  DateTime? get dateTime => DateTime.tryParse(date);
}

/// A single planned entry within a day. Mirrors `itinerary_items`.
class ItineraryItemModel {
  final int id;
  final int itineraryId;
  final String title;
  final String? description;
  final String? location;
  final String? startTime; // HH:MM
  final String? endTime; // HH:MM
  final String type; // activity, transport, food, accommodation, other

  ItineraryItemModel({
    required this.id,
    required this.itineraryId,
    required this.title,
    this.description,
    this.location,
    this.startTime,
    this.endTime,
    required this.type,
  });

  factory ItineraryItemModel.fromJson(Map<String, dynamic> json) {
    return ItineraryItemModel(
      id: (json['id'] as num).toInt(),
      itineraryId: (json['itinerary_id'] as num?)?.toInt() ?? 0,
      title: json['title'] ?? '',
      description: json['description'] as String?,
      location: json['location'] as String?,
      startTime: _timeOnly(json['start_time']),
      endTime: _timeOnly(json['end_time']),
      type: json['type'] ?? 'activity',
    );
  }
}

/// A recorded trip expense. Mirrors the MySQL `expenses` table.
class ExpenseModel {
  final int id;
  final int tripId;
  final String title;
  final double amount;
  final String currency;
  final String category;
  final String expenseDate; // YYYY-MM-DD
  final String? notes;

  ExpenseModel({
    required this.id,
    required this.tripId,
    required this.title,
    required this.amount,
    required this.currency,
    required this.category,
    required this.expenseDate,
    this.notes,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: (json['id'] as num).toInt(),
      tripId: (json['trip_id'] as num?)?.toInt() ?? 0,
      title: json['title'] ?? '',
      amount: double.tryParse('${json['amount']}') ?? 0.0,
      currency: json['currency'] ?? 'MYR',
      category: json['category'] ?? 'other',
      expenseDate: _dateOnly(json['expense_date']),
      notes: json['notes'] as String?,
    );
  }

  DateTime? get date => DateTime.tryParse(expenseDate);
}

/// MySQL DATE columns are returned as `YYYY-MM-DD`, but an older driver config
/// can still emit a full ISO timestamp — keep only the calendar part.
String _dateOnly(dynamic value) {
  if (value == null) return '';
  final raw = value.toString();
  if (raw.length >= 10) return raw.substring(0, 10);
  return raw;
}

/// MySQL TIME columns come back as `HH:MM:SS`; the app works in `HH:MM`.
String? _timeOnly(dynamic value) {
  if (value == null) return null;
  final raw = value.toString();
  if (raw.length >= 5) return raw.substring(0, 5);
  return raw;
}

class WeatherForecast {
  final String summary;
  final double temperature;
  final double feelsLike;
  final double precipitation;
  final double windSpeed;
  final double humidity;
  final String quickSummary;
  final String icon;
  final List<DayWeather> weekly;

  WeatherForecast({
    required this.summary,
    required this.temperature,
    required this.feelsLike,
    required this.precipitation,
    required this.windSpeed,
    required this.humidity,
    required this.quickSummary,
    required this.icon,
    required this.weekly,
  });
}

class DayWeather {
  final String day;
  final String icon;
  final double high;
  final double low;

  DayWeather({
    required this.day,
    required this.icon,
    required this.high,
    required this.low,
  });
}

class Attraction {
  final String id;
  final String name;
  final String category;
  final String description;
  final String imageUrl;

  Attraction({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.imageUrl,
  });
}

class CountryInfo {
  final String name;
  final String? officialName;
  final String? capital;
  final String? region;
  final String? flag;
  final int? population;
  final Map<String, dynamic>? currencies;
  final Map<String, dynamic>? languages;
  final List<dynamic>? timezones;

  CountryInfo({
    required this.name,
    this.officialName,
    this.capital,
    this.region,
    this.flag,
    this.population,
    this.currencies,
    this.languages,
    this.timezones,
  });

  /// Nested JSON maps decode as `Map<String, Object?>`, which a direct
  /// `as Map<String, dynamic>?` cast rejects, so copy them instead.
  factory CountryInfo.fromJson(Map<String, dynamic> json) {
    return CountryInfo(
      name: json['name'] as String? ?? '',
      officialName: json['officialName'] as String?,
      capital: json['capital'] as String?,
      region: json['region'] as String?,
      flag: json['flag'] as String?,
      population: json['population'] as int?,
      currencies: json['currencies'] != null
          ? Map<String, dynamic>.from(json['currencies'] as Map)
          : null,
      languages: json['languages'] != null
          ? Map<String, dynamic>.from(json['languages'] as Map)
          : null,
      timezones: json['timezones'] != null
          ? List<dynamic>.from(json['timezones'] as List)
          : null,
    );
  }

  /// RestCountries returns currencies keyed by code, e.g.
  /// `{"MYR": {"name": "Malaysian ringgit", "symbol": "RM"}}`.
  String get currencyLabel {
    final entries = currencies?.entries;
    if (entries == null || entries.isEmpty) return 'Not available';
    final first = entries.first;
    final details = first.value as Map<String, dynamic>?;
    final currencyName = details?['name'] as String? ?? first.key;
    final symbol = details?['symbol'] as String?;
    return symbol != null ? '$currencyName ($symbol)' : currencyName;
  }

  String get languageLabel {
    final values = languages?.values;
    if (values == null || values.isEmpty) return 'Not available';
    return values.join(', ');
  }

  String get timezoneLabel {
    if (timezones == null || timezones!.isEmpty) return 'Not available';
    return timezones!.join(', ');
  }
}

class RecommendedDestination {
  final String title;
  final String country;
  final String description;
  final String imageUrl;
  final double rating;
  final double estimatedBudget;

  RecommendedDestination({
    required this.title,
    required this.country,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.estimatedBudget,
  });
}

class TravelTip {
  final String title;
  final String body;

  TravelTip({
    required this.title,
    required this.body,
  });
}

class AppNotification {
  final String title;
  final String message;
  final String time;

  AppNotification({
    required this.title,
    required this.message,
    required this.time,
  });
}

class CurrentWeather {
  final double temperature;
  final double windspeed;
  final int weathercode;
  final String time;

  CurrentWeather({
    required this.temperature,
    required this.windspeed,
    required this.weathercode,
    required this.time,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['temperature'] as num).toDouble(),
      windspeed: (json['windspeed'] as num).toDouble(),
      weathercode: json['weathercode'] as int,
      time: json['time'] as String,
    );
  }
}

class DailyForecast {
  final List<String> time;
  final List<double> tempMax;
  final List<double> tempMin;
  final List<double> precipitation;
  final List<int> weathercode;

  DailyForecast({
    required this.time,
    required this.tempMax,
    required this.tempMin,
    required this.precipitation,
    required this.weathercode,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      time: List<String>.from(json['time']),
      tempMax: List<double>.from(
          (json['temperature_2m_max'] as List).map((e) => (e as num).toDouble())),
      tempMin: List<double>.from(
          (json['temperature_2m_min'] as List).map((e) => (e as num).toDouble())),
      precipitation: List<double>.from(
          (json['precipitation_sum'] as List).map((e) => (e as num).toDouble())),
      weathercode: List<int>.from(json['weathercode']),
    );
  }

  int get length => time.length;
}

class AttractionResult {
  final String title;
  final double? rating;
  final int? reviews;
  final String? type;
  final String? address;
  final String? thumbnail;
  final String? description;

  AttractionResult({
    required this.title,
    this.rating,
    this.reviews,
    this.type,
    this.address,
    this.thumbnail,
    this.description,
  });

  factory AttractionResult.fromJson(Map<String, dynamic> json) {
    return AttractionResult(
      title: json['title'] ?? '',
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      reviews: json['reviews'] as int?,
      type: json['type'] as String?,
      address: json['address'] as String?,
      thumbnail: json['thumbnail'] as String?,
      description: json['description'] as String?,
    );
  }
}

class HotelResult {
  final String name;
  final double? rating;
  final int? reviews;
  final String? description;
  final String? link;
  final String? thumbnail;
  final String? price;

  HotelResult({
    required this.name,
    this.rating,
    this.reviews,
    this.description,
    this.link,
    this.thumbnail,
    this.price,
  });

  factory HotelResult.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List?;
    return HotelResult(
      name: json['name'] ?? '',
      rating: json['overall_rating'] != null
          ? (json['overall_rating'] as num).toDouble()
          : null,
      reviews: json['reviews'] as int?,
      description: json['description'] as String?,
      link: json['link'] as String?,
      thumbnail: (images != null && images.isNotEmpty)
          ? images[0]['thumbnail'] as String?
          : null,
      price: json['rate_per_night']?['lowest'] as String?,
    );
  }
}

class RestaurantResult {
  final String title;
  final double? rating;
  final int? reviews;
  final String? type;
  final String? address;
  final String? thumbnail;
  final String? hours;

  RestaurantResult({
    required this.title,
    this.rating,
    this.reviews,
    this.type,
    this.address,
    this.thumbnail,
    this.hours,
  });

  factory RestaurantResult.fromJson(Map<String, dynamic> json) {
    return RestaurantResult(
      title: json['title'] ?? '',
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      reviews: json['reviews'] as int?,
      type: json['type'] as String?,
      address: json['address'] as String?,
      thumbnail: json['thumbnail'] as String?,
      hours: json['hours'] as String?,
    );
  }
}
