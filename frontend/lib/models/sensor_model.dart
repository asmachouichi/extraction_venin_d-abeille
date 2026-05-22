class SensorModel {

  final double weight;
  final double temperature;
  final double humidity;
  final double ax;
  final double ay;
  final double az;

  SensorModel({
    required this.weight,
    required this.temperature,
    required this.humidity,
    required this.ax,
    required this.ay,
    required this.az,
  });

  factory SensorModel.fromJson(List<dynamic> json) {
    return SensorModel(
      weight: (json[0] ?? 0).toDouble(),
      temperature: (json[1] ?? 0).toDouble(),
      humidity: (json[2] ?? 0).toDouble(),
      ax: (json[3] ?? 0).toDouble(),
      ay: (json[4] ?? 0).toDouble(),
      az: (json[5] ?? 0).toDouble(),
    );
  }
}