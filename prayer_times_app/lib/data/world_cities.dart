/// مدن عالمية مع إحداثياتها (خط العرض، خط الطول)
class WorldCity {
  final String nameAr;
  final String countryAr;
  final double latitude;
  final double longitude;

  const WorldCity({
    required this.nameAr,
    required this.countryAr,
    required this.latitude,
    required this.longitude,
  });
}

const List<WorldCity> worldCities = [
  WorldCity(nameAr: 'مكة المكرمة', countryAr: 'السعودية', latitude: 21.4225, longitude: 39.8262),
  WorldCity(nameAr: 'المدينة المنورة', countryAr: 'السعودية', latitude: 24.4672, longitude: 39.6111),
  WorldCity(nameAr: 'الرياض', countryAr: 'السعودية', latitude: 24.7136, longitude: 46.6753),
  WorldCity(nameAr: 'جدة', countryAr: 'السعودية', latitude: 21.5433, longitude: 39.1728),
  WorldCity(nameAr: 'القاهرة', countryAr: 'مصر', latitude: 30.0444, longitude: 31.2357),
  WorldCity(nameAr: 'القدس', countryAr: 'فلسطين', latitude: 31.7683, longitude: 35.2137),
  WorldCity(nameAr: 'إسطنبول', countryAr: 'تركيا', latitude: 41.0082, longitude: 28.9784),
  WorldCity(nameAr: 'دبي', countryAr: 'الإمارات', latitude: 25.2048, longitude: 55.2708),
  WorldCity(nameAr: 'أبوظبي', countryAr: 'الإمارات', latitude: 24.4539, longitude: 54.3773),
  WorldCity(nameAr: 'عمّان', countryAr: 'الأردن', latitude: 31.9454, longitude: 35.9284),
  WorldCity(nameAr: 'بيروت', countryAr: 'لبنان', latitude: 33.8938, longitude: 35.5018),
  WorldCity(nameAr: 'دمشق', countryAr: 'سوريا', latitude: 33.5138, longitude: 36.2765),
  WorldCity(nameAr: 'بغداد', countryAr: 'العراق', latitude: 33.3152, longitude: 44.3661),
  WorldCity(nameAr: 'الكويت', countryAr: 'الكويت', latitude: 29.3759, longitude: 47.9774),
  WorldCity(nameAr: 'الدوحة', countryAr: 'قطر', latitude: 25.2854, longitude: 51.5310),
  WorldCity(nameAr: 'المنامة', countryAr: 'البحرين', latitude: 26.2285, longitude: 50.5860),
  WorldCity(nameAr: 'مسقط', countryAr: 'عُمان', latitude: 23.5880, longitude: 58.3829),
  WorldCity(nameAr: 'صنعاء', countryAr: 'اليمن', latitude: 15.3694, longitude: 44.1910),
  WorldCity(nameAr: 'الخرطوم', countryAr: 'السودان', latitude: 15.5007, longitude: 32.5599),
  WorldCity(nameAr: 'كوالالمبور', countryAr: 'ماليزيا', latitude: 3.1390, longitude: 101.6869),
  WorldCity(nameAr: 'جاكرتا', countryAr: 'إندونيسيا', latitude: -6.2088, longitude: 106.8456),
  WorldCity(nameAr: 'لندن', countryAr: 'بريطانيا', latitude: 51.5074, longitude: -0.1278),
  WorldCity(nameAr: 'باريس', countryAr: 'فرنسا', latitude: 48.8566, longitude: 2.3522),
  WorldCity(nameAr: 'نيويورك', countryAr: 'أمريكا', latitude: 40.7128, longitude: -74.0060),
];
