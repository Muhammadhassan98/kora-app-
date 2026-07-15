import 'package:equatable/equatable.dart';

class MatchEntity extends Equatable {
  final String id;
  final String homeTeam;
  final String awayTeam;
  final String homeLogo;
  final String awayLogo;
  final String status; // 'upcoming', 'live', 'finished'
  final int? homeScore;
  final int? awayScore;
  final int? minute;
  final DateTime startTime;

  const MatchEntity({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeLogo,
    required this.awayLogo,
    required this.status,
    this.homeScore,
    this.awayScore,
    this.minute,
    required this.startTime,
  });

  @override
  List<Object?> get props => [
        id,
        homeTeam,
        awayTeam,
        homeLogo,
        awayLogo,
        status,
        homeScore,
        awayScore,
        minute,
        startTime,
      ];
}
