import { Injectable, NotFoundException } from '@nestjs/common';

export class Match {
  id: string;
  homeTeam: string;
  awayTeam: string;
  homeLogo: string;
  awayLogo: string;
  status: 'upcoming' | 'live' | 'finished';
  homeScore?: number;
  awayScore?: number;
  minute?: number;
  startTime: string;
}

@Injectable()
export class MatchesService {
  private matches: Match[] = [
    {
      id: 'match_1',
      homeTeam: 'ريال مدريد',
      awayTeam: 'برشلونة',
      homeLogo: 'https://assets.mixkit.co/active-storage/sfx/947/947-84.wav', // Dummy or generic URLs
      awayLogo: 'https://assets.mixkit.co/active-storage/sfx/947/947-84.wav',
      status: 'live',
      homeScore: 2,
      awayScore: 1,
      minute: 75,
      startTime: new Date().toISOString(),
    },
    {
      id: 'match_2',
      homeTeam: 'أرسنال',
      awayTeam: 'تشيلسي',
      homeLogo: 'https://assets.mixkit.co/active-storage/sfx/947/947-84.wav',
      awayLogo: 'https://assets.mixkit.co/active-storage/sfx/947/947-84.wav',
      status: 'upcoming',
      startTime: new Date(Date.now() + 2 * 60 * 60 * 1000).toISOString(), // starts in 2 hours
    },
    {
      id: 'match_3',
      homeTeam: 'مانشستر سيتي',
      awayTeam: 'ليفربول',
      homeLogo: 'https://assets.mixkit.co/active-storage/sfx/947/947-84.wav',
      awayLogo: 'https://assets.mixkit.co/active-storage/sfx/947/947-84.wav',
      status: 'finished',
      homeScore: 1,
      awayScore: 3,
      startTime: new Date(Date.now() - 4 * 60 * 60 * 1000).toISOString(), // finished 4 hours ago
    },
    {
      id: 'match_4',
      homeTeam: 'بايرن ميونخ',
      awayTeam: 'بوروسيا دورتموند',
      homeLogo: 'https://assets.mixkit.co/active-storage/sfx/947/947-84.wav',
      awayLogo: 'https://assets.mixkit.co/active-storage/sfx/947/947-84.wav',
      status: 'upcoming',
      startTime: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(), // starts tomorrow
    },
  ];

  findAll(): Match[] {
    return this.matches;
  }

  findOne(id: string): Match {
    const match = this.matches.find((m) => m.id === id);
    if (!match) {
      throw new NotFoundException(`Match with ID ${id} not found`);
    }
    return match;
  }

  // Helper method for admin processing: allows updating score and finishing a match
  updateMatchResult(id: string, homeScore: number, awayScore: number): Match {
    const match = this.findOne(id);
    match.status = 'finished';
    match.homeScore = homeScore;
    match.awayScore = awayScore;
    match.minute = undefined;
    return match;
  }
}
