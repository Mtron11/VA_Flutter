class Weather {
  late String tempMin;
  late String description;
  late DateTime date; // Добавляем поле для хранения даты прогноза

  Weather(this.tempMin, this.description, this.date);

  @override
  String toString() {
    return 'Дата: ${date.day}-${date.month}-${date.year}, Температура: $tempMin°C, Облачность: $description';
  }
}