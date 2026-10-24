class SyrianCity {
  const SyrianCity({
    required this.id,
    required this.nameAr,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String nameAr;
  final double latitude;
  final double longitude;

  String get shortName {
    final paren = nameAr.indexOf(' (');
    if (paren > 0) return nameAr.substring(0, paren);
    return nameAr;
  }
}

const List<SyrianCity> syrianCities = [
  SyrianCity(id: 'damascus', nameAr: 'دمشق', latitude: 33.5138, longitude: 36.2765),
  SyrianCity(id: 'rif_dimashq', nameAr: 'ريف دمشق (دوما)', latitude: 33.5718, longitude: 36.4027),
  SyrianCity(id: 'aleppo', nameAr: 'حلب', latitude: 36.2021, longitude: 37.1343),
  SyrianCity(id: 'homs', nameAr: 'حمص', latitude: 34.7324, longitude: 36.7137),
  SyrianCity(id: 'hama', nameAr: 'حماة', latitude: 35.1318, longitude: 36.7578),
  SyrianCity(id: 'latakia', nameAr: 'اللاذقية', latitude: 35.5317, longitude: 35.7906),
  SyrianCity(id: 'tartus', nameAr: 'طرطوس', latitude: 34.8890, longitude: 35.8866),
  SyrianCity(id: 'idlib', nameAr: 'إدلب', latitude: 35.9306, longitude: 36.6339),
  SyrianCity(id: 'daraa', nameAr: 'درعا', latitude: 32.6189, longitude: 36.1021),
  SyrianCity(id: 'suwayda', nameAr: 'السويداء', latitude: 32.7094, longitude: 36.5695),
  SyrianCity(id: 'quneitra', nameAr: 'القنيطرة', latitude: 33.1259, longitude: 35.8246),
  SyrianCity(id: 'deir_ezzor', nameAr: 'دير الزور', latitude: 35.3359, longitude: 40.1408),
  SyrianCity(id: 'hasakah', nameAr: 'الحسكة', latitude: 36.5074, longitude: 40.7478),
  SyrianCity(id: 'raqqa', nameAr: 'الرقة', latitude: 35.9594, longitude: 39.0078),
];

SyrianCity syrianCityById(String? id) {
  for (final city in syrianCities) {
    if (city.id == id) return city;
  }
  return syrianCities.first;
}
