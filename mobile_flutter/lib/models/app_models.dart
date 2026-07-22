class UserProfile {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String location;
  final String bio;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.location,
    required this.bio,
  });
}

class Trip {
  final String id;
  final String title;
  final String destination;
  final String country;
  final DateTime startDate;
  final DateTime endDate;
  final double budget;
  final String currency;
  final String note;
  final List<TripDay> days;
  final List<Expense> expenses;
  final String imageUrl;
  final String status;
  final double progress;

  Trip({
    required this.id,
    required this.title,
    required this.destination,
    required this.country,
    required this.startDate,
    required this.endDate,
    required this.budget,
    required this.currency,
    required this.note,
    required this.days,
    required this.expenses,
    this.imageUrl = '',
    this.status = 'upcoming',
    this.progress = 0.0,
  });
}

class TripDay {
  final String id;
  final String title;
  final DateTime date;
  final List<ItineraryItem> items;

  TripDay({
    required this.id,
    required this.title,
    required this.date,
    required this.items,
  });
}

class ItineraryItem {
  final String id;
  final String title;
  final String description;
  final String location;
  final String startTime;
  final String endTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String type;

  ItineraryItem({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.startTime,
    required this.endTime,
    this.createdAt,   // now assigns to the field
    this.updatedAt,   // now assigns to the field
    required this.type,
  });
}

class Expense {
  final String id;
  final String title;
  final String category;
  final double amount;
  final String currency;
  final DateTime date;

  Expense({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.currency,
    required this.date,
  });
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
  final String capital;
  final String region;
  final String currency;
  final String language;
  final String timezone;
  final String flagUrl;

  CountryInfo({
    required this.name,
    required this.capital,
    required this.region,
    required this.currency,
    required this.language,
    required this.timezone,
    required this.flagUrl,
  });
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
