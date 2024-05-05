import 'dart:convert';
import 'weather_service.dart';
import 'weather.dart';

class AI {
  Future<List<Weather>> _fetchWeatherData(String city) async {
    final s = await WeatherService().getData(city);
    final data = json.decode(s);
    List<Weather> weekForecast = [];

    for (var i = 0; i < data['list'].length; i += 8) {
      var dayData = data['list'][i];
      var tempMin = dayData['main']['temp'].toString();
      var description = dayData['weather'][0]['description'];
      var date = DateTime.fromMillisecondsSinceEpoch(dayData['dt'] * 1000); // Преобразование временной метки в объект DateTime
      weekForecast.add(Weather(tempMin, description, date));
    }

    return weekForecast;
  }

  Future<String> getAnswer(String question) async {
    final RegExp weatherPattern = RegExp(r'погода в городе (.+)');
    final match = weatherPattern.firstMatch(question.trim());

    if (match != null) {
      final String city = match.group(1)!;

      try {
        final weekForecast = await _fetchWeatherData(city);
        String forecastString = "Прогноз погоды в городе $city на неделю:\n";

        for (int i = 0; i < weekForecast.length; i++) {
          String formattedDate = '${weekForecast[i].date.day}-${weekForecast[i].date.month}-${weekForecast[i].date.year}';
          forecastString += "$formattedDate: Температура ${weekForecast[i].tempMin}, Описание ${weekForecast[i].description}\n";
        }

        return forecastString;
      } catch (error) {
        return "Не удалось получить данные о погоде для города $city.";
      }
    } else {
      return "Я могу помочь с информацией о погоде. Спросите, например, 'погода в городе Киров'.";
    }
  }
}