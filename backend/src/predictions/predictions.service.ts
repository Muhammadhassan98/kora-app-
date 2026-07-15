import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { MatchesService } from '../matches/matches.service';
import { CreatePredictionDto } from './dto/create-prediction.dto';
import { ProcessPredictionDto } from './dto/process-prediction.dto';

@Injectable()
export class PredictionsService {
  constructor(
    private prisma: PrismaService,
    private matchesService: MatchesService,
  ) {}

  async create(userId: string, dto: CreatePredictionDto) {
    // 1. Fetch match and check status
    const match = this.matchesService.findOne(dto.matchId);
    if (match.status !== 'upcoming') {
      throw new BadRequestException('Can only predict upcoming matches');
    }

    // 2. Upsert prediction (one prediction per user per match)
    // Find if already exists
    const existing = await this.prisma.prediction.findFirst({
      where: {
        userId,
        matchId: dto.matchId,
      },
    });

    if (existing) {
      return this.prisma.prediction.update({
        where: { id: existing.id },
        data: {
          predictedWinner: dto.predictedWinner,
          predictedHomeScore: dto.predictedHomeScore,
          predictedAwayScore: dto.predictedAwayScore,
        },
      });
    } else {
      return this.prisma.prediction.create({
        data: {
          userId,
          matchId: dto.matchId,
          predictedWinner: dto.predictedWinner,
          predictedHomeScore: dto.predictedHomeScore,
          predictedAwayScore: dto.predictedAwayScore,
        },
      });
    }
  }

  async findMyPredictions(userId: string) {
    return this.prisma.prediction.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async getLeaderboard() {
    return this.prisma.profile.findMany({
      orderBy: [
        { xpPoints: 'desc' },
        { coinsBalance: 'desc' },
      ],
      take: 20, // top 20 users
    });
  }

  async processMatchPredictions(matchId: string, dto: ProcessPredictionDto) {
    // 1. Mark match finished in MatchesService
    this.matchesService.updateMatchResult(matchId, dto.homeScore, dto.awayScore);

    // 2. Determine actual winner
    let actualWinner = 'draw';
    if (dto.homeScore > dto.awayScore) {
      actualWinner = 'home';
    } else if (dto.awayScore > dto.homeScore) {
      actualWinner = 'away';
    }

    // 3. Find unprocessed predictions for this match
    const predictions = await this.prisma.prediction.findMany({
      where: {
        matchId,
        isProcessed: false,
      },
    });

    const results: any[] = [];

    for (const pred of predictions) {
      let xpEarned = 0;
      let coinsEarned = 0;

      const exactMatch =
        pred.predictedHomeScore === dto.homeScore &&
        pred.predictedAwayScore === dto.awayScore;

      const correctWinner = pred.predictedWinner === actualWinner;

      if (exactMatch) {
        xpEarned = 50;
        coinsEarned = 10;
      } else if (correctWinner) {
        xpEarned = 20;
        coinsEarned = 5;
      }

      // Update User Profile (Coins & XP & Level)
      const profile = await this.prisma.profile.findUnique({
        where: { userId: pred.userId },
      });

      if (profile) {
        const newXp = profile.xpPoints + xpEarned;
        const newCoins = profile.coinsBalance + coinsEarned;
        const newLevel = Math.floor(newXp / 100) + 1; // 100 XP per level

        await this.prisma.profile.update({
          where: { userId: pred.userId },
          data: {
            xpPoints: newXp,
            coinsBalance: newCoins,
            level: newLevel,
          },
        });

        // Register transaction if coins earned
        if (coinsEarned > 0) {
          await this.prisma.coinTransaction.create({
            data: {
              userId: pred.userId,
              amount: coinsEarned,
              transactionType: 'prediction_reward',
              description: `مكافأة توقع مباراة ${matchId}`,
            },
          });
        }
      }

      // Mark prediction processed
      const updatedPred = await this.prisma.prediction.update({
        where: { id: pred.id },
        data: {
          pointsEarned: xpEarned,
          isProcessed: true,
        },
      });

      results.push({
        predictionId: pred.id,
        userId: pred.userId,
        xpEarned,
        coinsEarned,
        exactMatch,
        correctWinner,
      });
    }

    return {
      success: true,
      message: `Processed ${predictions.length} predictions for match ${matchId}`,
      results,
    };
  }
}
