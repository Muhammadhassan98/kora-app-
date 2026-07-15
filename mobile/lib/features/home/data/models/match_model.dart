import '../../domain/entities/match_entity.dart';

class MatchModel extends MatchEntity {
  const MatchModel({
    required super.id,
    required super.homeTeam,
    required super.awayTeam,
    required super.homeLogo,
    required super.awayLogo,
    required super.status,
    super.homeScore,
    super.awayScore,
    super.minute,
    required super.startTime,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'] as String,
      homeTeam: json['homeTeam'] as String,
      awayTeam: json['awayTeam'] as String,
      homeLogo: json['homeLogo'] as String,
      awayLogo: json['awayLogo'] as String,
      status: json['status'] as String,
      homeScore: json['homeScore'] as int?,
      awayScore: json['awayScore'] as int?,
      minute: json['minute'] as int?,
      startTime: DateTime.parse(json['startTime'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'homeTeam': homeTeam,
      'awayTeam': awayTeam,
      'homeLogo': homeLogo,
      'awayLogo': awayLogo,
      'status': status,
      'homeScore': homeScore,
      'awayScore': awayScore,
      'minute': minute,
      'startTime': startTime.toIso8601String(),
    };
  }
}
