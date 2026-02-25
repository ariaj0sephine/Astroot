// Sample cities data (lat, lon)
const Map<String, Map<String, double>> citiesData = {
  'New York': {'lat': 40.7128, 'lon': -74.0060},
  'London': {'lat': 51.5074, 'lon': -0.1278},
  'Tokyo': {'lat': 35.6895, 'lon': 139.6917},
};

// Sample timezones data (name, offset in hours)
const Map<String, int> timezonesData = {
  'EST (UTC-5)': -5,
  'GMT (UTC+0)': 0,
  'IST (UTC+5:30)': 5, // Note: For India, but offset is int—handle half-hours if needed
};

// Sample moon phases (cycle through them for demo)
const List<String> moonPhases = [
  'New Moon',
  'Waxing Crescent',
  'First Quarter',
  'Waxing Gibbous',
  'Full Moon',
  'Waning Gibbous',
  'Last Quarter',
  'Waning Crescent',
];

// Sample sky objects (stars, planets) with 'name' to fix null error
const List<Map<String, dynamic>> skyObjects = [
  {'type': 'venus', 'name': 'Venus'},
  {'type': 'sirius', 'name': 'Sirius'},
  {'type': 'orion', 'name': 'Orion Constellation'},
];