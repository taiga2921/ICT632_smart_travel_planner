import '../models/app_models.dart';

class MockData {
  static final UserProfile user = UserProfile(
    uid: 'u1',
    name: 'Aisha Rahman',
    email: 'aisha@email.com',
    phone: '+60 12 345 6789',
    country: 'Malaysia',
    preferredCurrency: 'USD',
    preferredLanguage: 'English',
    travelStyle: 'Balanced comfort',
    emergencyContact: '+60 17 123 4567',
  );

  static final List<Trip> trips = [
    Trip(
      id: 't1',
      title: 'Bali Escape',
      destination: 'Bali',
      country: 'Indonesia',
      startDate: DateTime(2026, 8, 10),
      endDate: DateTime(2026, 8, 16),
      budget: 3200,
      currency: 'USD',
      note: 'Beach, cafes, and sunrise views.',
      imageUrl: 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?auto=format&fit=crop&w=900&q=80',
      status: 'upcoming',
      progress: 0.72,
      days: [
        TripDay(
          id: 'd1',
          title: 'Arrival Day',
          date: DateTime(2026, 8, 10),
          items: [
            ItineraryItem(
              id: 'i1',
              title: 'Check-in at Uluwatu Villa',
              description: 'Drop bags and enjoy ocean views.',
              location: 'Uluwatu',
              startTime: '14:00',   // instead of 'time'
              endTime: '15:00',     // add end time
              type: 'accommodation',
              // createdAt and updatedAt are optional – omit or pass null
            ),
            ItineraryItem(
              id: 'i2',
              title: 'Sunset Dinner',
              description: 'Enjoy local seafood by the beach.',
              location: 'Jimbaran',
              startTime: '19:00',
              endTime: '21:00',
              type: 'food',
            ),
          ],
        ),
      ],
      expenses: [
        Expense(id: 'e1', title: 'Airport transfer', category: 'transport', amount: 35, currency: 'USD', date: DateTime(2026, 8, 10)),
        Expense(id: 'e2', title: 'Beach club', category: 'activity', amount: 80, currency: 'USD', date: DateTime(2026, 8, 12)),
      ],
    ),
    Trip(
      id: 't2',
      title: 'Kyoto Discovery',
      destination: 'Kyoto',
      country: 'Japan',
      startDate: DateTime(2026, 9, 2),
      endDate: DateTime(2026, 9, 8),
      budget: 2500,
      currency: 'USD',
      note: 'Temples, tea houses, and autumn gardens.',
      imageUrl: 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?auto=format&fit=crop&w=900&q=80',
      status: 'completed',
      progress: 1.0,
      days: [],
      expenses: [],
    ),
    Trip(
      id: 't3',
      title: 'Seoul Food Trail',
      destination: 'Seoul',
      country: 'South Korea',
      startDate: DateTime(2026, 10, 14),
      endDate: DateTime(2026, 10, 20),
      budget: 1800,
      currency: 'USD',
      note: 'Street food, markets, and rooftop cafés.',
      imageUrl: 'https://images.unsplash.com/photo-1538485399081-7d7bf8f93b4d?auto=format&fit=crop&w=900&q=80',
      status: 'saved',
      progress: 0.28,
      days: [],
      expenses: [],
    ),
    Trip(
      id: 't4',
      title: 'Paris Weekend',
      destination: 'Paris',
      country: 'France',
      startDate: DateTime(2026, 11, 5),
      endDate: DateTime(2026, 11, 7),
      budget: 2100,
      currency: 'USD',
      note: 'Museum strolls and café hopping.',
      imageUrl: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=900&q=80',
      status: 'draft',
      progress: 0.15,
      days: [],
      expenses: [],
    ),
  ];

  static final WeatherForecast weather = WeatherForecast(
    summary: 'Bright and breezy',
    temperature: 28,
    feelsLike: 31,
    precipitation: 12,
    windSpeed: 16,
    humidity: 64,
    quickSummary: 'Perfect weather for sightseeing today.',
    icon: '☀️',
    weekly: [
      DayWeather(day: 'Mon', icon: '☀️', high: 31, low: 24),
      DayWeather(day: 'Tue', icon: '🌦️', high: 29, low: 23),
      DayWeather(day: 'Wed', icon: '⛅', high: 30, low: 24),
      DayWeather(day: 'Thu', icon: '🌤️', high: 32, low: 25),
      DayWeather(day: 'Fri', icon: '🌧️', high: 27, low: 22),
    ],
  );

  static final List<RecommendedDestination> destinations = [
    RecommendedDestination(
      title: 'Tokyo',
      country: 'Japan',
      description: 'Neon streets, temples, and exceptional street food.',
      imageUrl: 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?auto=format&fit=crop&w=900&q=80',
      rating: 4.9,
      estimatedBudget: 2400,
    ),
    RecommendedDestination(
      title: 'Langkawi',
      country: 'Malaysia',
      description: 'Island views, mangroves, and easy island hopping.',
      imageUrl: 'https://images.unsplash.com/photo-1519046904884-53103b34b206?auto=format&fit=crop&w=900&q=80',
      rating: 4.8,
      estimatedBudget: 1800,
    ),
    RecommendedDestination(
      title: 'Sabah',
      country: 'Malaysia',
      description: 'Rainforests, diving spots, and slow island mornings.',
      imageUrl: 'https://images.unsplash.com/photo-1500375592092-40eb2168fd21?auto=format&fit=crop&w=900&q=80',
      rating: 4.7,
      estimatedBudget: 2000,
    ),
  ];

  static final List<Attraction> attractions = [
    Attraction(id: 'a1', name: 'Uluwatu Temple', category: 'Temple', description: 'Cliffside temple with dramatic ocean views.', imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=500&q=80'),
    Attraction(id: 'a2', name: 'Tegalalang Rice Terrace', category: 'Nature', description: 'A scenic landscape of carved rice fields.', imageUrl: 'https://images.unsplash.com/photo-1517760444937-f6397edcbbcd?auto=format&fit=crop&w=500&q=80'),
    Attraction(id: 'a3', name: 'Gyeongbokgung Palace', category: 'Heritage', description: 'A grand palace complex with rich Korean history.', imageUrl: 'https://images.unsplash.com/photo-1526481280693-3bfa7568e0f3?auto=format&fit=crop&w=500&q=80'),
  ];

  static final List<TravelTip> tips = [
    TravelTip(title: 'Best season', body: 'Plan outdoor activities early in the day to avoid the midday heat.'),
    TravelTip(title: 'Packing tips', body: 'Carry a light rain layer for sudden tropical showers.'),
    TravelTip(title: 'Safety tips', body: 'Keep digital and physical copies of your passport handy.'),
    TravelTip(title: 'Currency tips', body: 'Use a small amount of local cash for markets and taxis.'),
  ];

  static final CountryInfo country = CountryInfo(
    name: 'Indonesia',
    capital: 'Jakarta',
    region: 'Asia',
    currency: 'IDR',
    language: 'Bahasa Indonesia',
    timezone: 'WIB (UTC+7)',
    flagUrl: 'https://flagcdn.com/w320/id.png',
  );

  static final List<AppNotification> notifications = [
    AppNotification(title: 'Trip updated', message: 'Your Bali itinerary has been refreshed.', time: '10 min ago'),
    AppNotification(title: 'Weather alert', message: 'Expect light rain in the evening.', time: '1 hr ago'),
  ];
}
