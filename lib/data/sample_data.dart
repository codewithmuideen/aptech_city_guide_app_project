import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../models/city.dart';
import '../models/attraction.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class SampleData {
  static final List<City> cities = [
    City(
      id: 'c1',
      name: 'Mumbai',
      country: 'India',
      description:
          'The city of dreams, Mumbai is India\u2019s financial capital, known for Bollywood, marine drives and colonial architecture.',
      imageUrl:
          'https://images.unsplash.com/photo-1570168007204-dfb528c6958f?w=1200&q=80',
      latitude: 19.0760,
      longitude: 72.8777,
    ),
    City(
      id: 'c2',
      name: 'Paris',
      country: 'France',
      description:
          'The City of Light, famous for art, fashion, gastronomy and iconic landmarks like the Eiffel Tower.',
      imageUrl:
          'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=1200&q=80',
      latitude: 48.8566,
      longitude: 2.3522,
    ),
    City(
      id: 'c3',
      name: 'Tokyo',
      country: 'Japan',
      description:
          'A bustling mix of ultramodern and traditional, from neon-lit skyscrapers to historic temples.',
      imageUrl:
          'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=1200&q=80',
      latitude: 35.6762,
      longitude: 139.6503,
    ),
    City(
      id: 'c4',
      name: 'New York',
      country: 'USA',
      description:
          'The Big Apple - a global hub of culture, finance, art and world-famous landmarks.',
      imageUrl:
          'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=1200&q=80',
      latitude: 40.7128,
      longitude: -74.0060,
    ),
  ];

  static final List<Attraction> attractions = [
    // Mumbai
    Attraction(
      id: 'a1',
      cityId: 'c1',
      name: 'Gateway of India',
      category: AttractionCategory.attraction,
      description:
          'An arch-monument built in the early 20th century on the waterfront of Mumbai, and an iconic symbol of the city.',
      imageUrl:
          'https://images.unsplash.com/photo-1566552881560-0be862a7c445?w=1200&q=80',
      address: 'Apollo Bandar, Colaba, Mumbai',
      phone: '+91 22 2284 1877',
      website: 'https://maharashtratourism.gov.in',
      openingHours: 'Open 24 hours',
      latitude: 18.9220,
      longitude: 72.8347,
    ),
    Attraction(
      id: 'a2',
      cityId: 'c1',
      name: 'Trishna',
      category: AttractionCategory.restaurant,
      description:
          'Legendary seafood restaurant known for its butter-pepper-garlic crab and coastal Indian cuisine.',
      imageUrl:
          'https://images.unsplash.com/photo-1544025162-d76694265947?w=1200&q=80',
      address: '7, Rope Walk Lane, Kala Ghoda, Fort, Mumbai',
      phone: '+91 22 2270 3213',
      openingHours: '12:00 - 15:30, 19:00 - 00:00',
      latitude: 18.9283,
      longitude: 72.8321,
    ),
    Attraction(
      id: 'a3',
      cityId: 'c1',
      name: 'The Taj Mahal Palace',
      category: AttractionCategory.hotel,
      description:
          'A heritage, 5-star luxury hotel built in Colaba, overlooking the Arabian Sea and Gateway of India.',
      imageUrl:
          'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=1200&q=80',
      address: 'Apollo Bandar, Colaba, Mumbai',
      phone: '+91 22 6665 3366',
      website: 'https://www.tajhotels.com',
      openingHours: 'Open 24 hours',
      latitude: 18.9217,
      longitude: 72.8330,
    ),
    // Paris
    Attraction(
      id: 'a4',
      cityId: 'c2',
      name: 'Eiffel Tower',
      category: AttractionCategory.attraction,
      description:
          'Wrought-iron lattice tower on the Champ de Mars, a global cultural icon of France and one of the most recognizable structures in the world.',
      imageUrl:
          'https://images.unsplash.com/photo-1511739001486-6bfe10ce785f?w=1200&q=80',
      address: 'Champ de Mars, 5 Av. Anatole France, 75007 Paris',
      phone: '+33 8 92 70 12 39',
      website: 'https://www.toureiffel.paris',
      openingHours: '09:30 - 23:45',
      latitude: 48.8584,
      longitude: 2.2945,
    ),
    Attraction(
      id: 'a5',
      cityId: 'c2',
      name: 'Le Jules Verne',
      category: AttractionCategory.restaurant,
      description:
          'Michelin-starred fine dining restaurant inside the Eiffel Tower with panoramic views of Paris.',
      imageUrl:
          'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=1200&q=80',
      address: 'Av. Gustave Eiffel, 75007 Paris',
      phone: '+33 1 72 76 16 61',
      openingHours: '12:00 - 13:30, 19:00 - 21:30',
      latitude: 48.8582,
      longitude: 2.2945,
    ),
    // Tokyo
    Attraction(
      id: 'a6',
      cityId: 'c3',
      name: 'Senso-ji Temple',
      category: AttractionCategory.attraction,
      description:
          'An ancient Buddhist temple located in Asakusa; Tokyo\u2019s oldest and most significant temple.',
      imageUrl:
          'https://images.unsplash.com/photo-1583889659384-ceaa8c6ca7ff?w=1200&q=80',
      address: '2 Chome-3-1 Asakusa, Taito City, Tokyo',
      phone: '+81 3-3842-0181',
      website: 'https://www.senso-ji.jp',
      openingHours: '06:00 - 17:00',
      latitude: 35.7148,
      longitude: 139.7967,
    ),
    Attraction(
      id: 'a7',
      cityId: 'c3',
      name: 'Sakura Festival',
      category: AttractionCategory.event,
      description:
          'Annual cherry-blossom viewing festival in Ueno Park with food stalls, music and thousands of sakura trees in bloom.',
      imageUrl:
          'https://images.unsplash.com/photo-1522383225653-ed111181a951?w=1200&q=80',
      address: 'Ueno Park, Taito City, Tokyo',
      openingHours: 'Late March - Early April',
      latitude: 35.7156,
      longitude: 139.7730,
    ),
    // New York
    Attraction(
      id: 'a8',
      cityId: 'c4',
      name: 'Statue of Liberty',
      category: AttractionCategory.attraction,
      description:
          'A colossal neoclassical sculpture on Liberty Island, a symbol of freedom and a welcoming sight to immigrants arriving from abroad.',
      imageUrl:
          'https://images.unsplash.com/photo-1485871981521-5b1fd3805eee?w=1200&q=80',
      address: 'Liberty Island, New York, NY 10004',
      phone: '+1 212-363-3200',
      website: 'https://www.nps.gov/stli',
      openingHours: '09:00 - 17:00',
      latitude: 40.6892,
      longitude: -74.0445,
    ),
    Attraction(
      id: 'a9',
      cityId: 'c4',
      name: 'The Plaza Hotel',
      category: AttractionCategory.hotel,
      description:
          'Iconic luxury hotel overlooking Central Park, a historic landmark of New York City.',
      imageUrl:
          'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200&q=80',
      address: '768 5th Ave, New York, NY 10019',
      phone: '+1 212-759-3000',
      website: 'https://www.theplazany.com',
      openingHours: 'Open 24 hours',
      latitude: 40.7644,
      longitude: -73.9744,
    ),
  ];

  static AppUser get adminUser => AppUser(
        id: 'admin',
        name: 'Administrator',
        email: AppConstants.adminEmail,
        passwordHash: sha256
            .convert(utf8.encode(AppConstants.adminPassword))
            .toString(),
        phone: '+1 000 000 0000',
        isAdmin: true,
      );
}
