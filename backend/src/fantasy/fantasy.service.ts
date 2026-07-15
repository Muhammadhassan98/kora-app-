import { Injectable, OnModuleInit, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';

@Injectable()
export class FantasyService implements OnModuleInit {
  constructor(private readonly prisma: PrismaService) {}

  async onModuleInit() {
    // Seed initial players if player table is empty
    const count = await this.prisma.player.count();
    if (count === 0) {
      console.log('Seeding fantasy players...');
      const initialPlayers = [
        { name: 'محمد صلاح', position: 'MID', price: 12.5, points: 124, club: 'ليفربول', logo: 'https://assets.mixkit.co/active-storage/sfx/947/947-84.wav' },
        { name: 'إيرلينج هالاند', position: 'FWD', price: 14.0, points: 112, club: 'مانشستر سيتي', logo: 'https://assets.mixkit.co/active-storage/sfx/947/947-84.wav' },
        { name: 'بوكايو ساكا', position: 'MID', price: 10.0, points: 98, club: 'أرسنال', logo: 'https://assets.mixkit.co/active-storage/sfx/947/947-84.wav' },
        { name: 'سون هيونج مين', position: 'MID', price: 9.5, points: 86, club: 'توتنهام', logo: 'https://assets.mixkit.co/active-storage/sfx/947/947-84.wav' },
        { name: 'كيفين دي بروين', position: 'MID', price: 10.5, points: 74, club: 'مانشستر سيتي', logo: 'https://assets.mixkit.co/active-storage/sfx/947/947-84.wav' },
        { name: 'كول بالمر', position: 'MID', price: 8.5, points: 110, club: 'تشيلسي', logo: 'https://assets.mixkit.co/active-storage/sfx/947/947-84.wav' },
        { name: 'فيل فودين', position: 'MID', price: 8.5, points: 102, club: 'مانشستر سيتي', logo: 'https://assets.mixkit.co/active-storage/sfx/947/947-84.wav' },
        { name: 'ألكسندر أرنولد', position: 'DEF', price: 8.0, points: 78, club: 'ليفربول', logo: 'https://assets.mixkit.co/active-storage/sfx/947/947-84.wav' },
        { name: 'ويليام ساليبا', position: 'DEF', price: 6.5, points: 80, club: 'أرسنال', logo: 'https://assets.mixkit.co/active-storage/sfx/947/947-84.wav' },
        { name: 'فيرجيل فان دايك', position: 'DEF', price: 6.5, points: 78, club: 'ليفربول', logo: 'https://assets.mixkit.co/active-storage/sfx/947/947-84.wav' },
        { name: 'كيران تريبيير', position: 'DEF', price: 7.0, points: 72, club: 'نيوكاسل', logo: 'https://assets.mixkit.co/active-storage/sfx/947/947-84.wav' },
        { name: 'روبن دياز', position: 'DEF', price: 6.0, points: 68, club: 'مانشستر سيتي', logo: 'https://assets.mixkit.co/active-storage/sfx/947/947-84.wav' },
        { name: 'أليسون بيكر', position: 'GKP', price: 6.0, points: 88, club: 'ليفربول', logo: 'https://assets.mixkit.co/active-storage/sfx/947/947-84.wav' },
        { name: 'إيدرسون', position: 'GKP', price: 5.5, points: 82, club: 'مانشستر سيتي', logo: 'https://assets.mixkit.co/active-storage/sfx/947/947-84.wav' },
        { name: 'ديفيد رايا', position: 'GKP', price: 5.0, points: 76, club: 'أرسنال', logo: 'https://assets.mixkit.co/active-storage/sfx/947/947-84.wav' },
        { name: 'إيميليانو مارتينيز', position: 'GKP', price: 5.0, points: 70, club: 'أستون فيلا', logo: 'https://assets.mixkit.co/active-storage/sfx/947/947-84.wav' },
        { name: 'أولي واتكينز', position: 'FWD', price: 9.0, points: 94, club: 'أستون فيلا', logo: 'https://assets.mixkit.co/active-storage/sfx/947/947-84.wav' },
        { name: 'ألكسندر إيساك', position: 'FWD', price: 8.0, points: 88, club: 'نيوكاسل', logo: 'https://assets.mixkit.co/active-storage/sfx/947/947-84.wav' },
        { name: 'دومينيك سولانكي', position: 'FWD', price: 7.0, points: 82, club: 'بورنموث', logo: 'https://assets.mixkit.co/active-storage/sfx/947/947-84.wav' },
        { name: 'جارود بوين', position: 'MID', price: 8.0, points: 90, club: 'وست هام', logo: 'https://assets.mixkit.co/active-storage/sfx/947/947-84.wav' }
      ];

      await this.prisma.player.createMany({
        data: initialPlayers,
      });
      console.log('Seeded 20 fantasy players successfully.');
    }
  }

  async getPlayers(position?: string, club?: string, search?: string) {
    const where: any = {};
    if (position) {
      where.position = position;
    }
    if (club) {
      where.club = club;
    }
    if (search) {
      where.name = {
        contains: search,
        mode: 'insensitive',
      };
    }
    return this.prisma.player.findMany({
      where,
      orderBy: { points: 'desc' },
    });
  }

  async getSquad(userId: string) {
    let squad = await this.prisma.fantasySquad.findFirst({
      where: { userId },
      include: {
        players: {
          include: {
            player: true,
          },
        },
      },
    });

    if (!squad) {
      // Create empty default squad for new user
      squad = await this.prisma.fantasySquad.create({
        data: {
          userId,
          budget: 100.0,
          totalPoints: 0,
          gameweekPoints: 0,
        },
        include: {
          players: {
            include: {
              player: true,
            },
          },
        },
      });
    }

    return squad;
  }

  async updateSquad(userId: string, playerIds: string[]) {
    if (playerIds.length > 15) {
      throw new BadRequestException('لا يمكن للتشكيلة أن تحتوي على أكثر من 15 لاعباً');
    }

    const players = await this.prisma.player.findMany({
      where: {
        id: { in: playerIds },
      },
    });

    if (players.length !== playerIds.length) {
      throw new BadRequestException('بعض اللاعبين المحددين غير موجودين');
    }

    // Check budget
    const totalCost = players.reduce((sum, p) => sum + p.price, 0);
    if (totalCost > 100.0) {
      throw new BadRequestException(`تجاوزت الميزانية المحددة! التكلفة الإجمالية: ${totalCost.toFixed(1)}M، الميزانية: 100M`);
    }

    let squad = await this.prisma.fantasySquad.findFirst({
      where: { userId },
    });

    if (!squad) {
      squad = await this.prisma.fantasySquad.create({
        data: {
          userId,
          budget: 100.0 - totalCost,
          totalPoints: 0,
          gameweekPoints: 0,
        },
      });
    } else {
      squad = await this.prisma.fantasySquad.update({
        where: { id: squad.id },
        data: {
          budget: 100.0 - totalCost,
        },
      });
    }

    // Clear existing players
    await this.prisma.squadPlayer.deleteMany({
      where: { fantasySquadId: squad.id },
    });

    // Add new players
    const squadPlayersData = players.map((p, index) => ({
      fantasySquadId: squad.id,
      playerId: p.id,
      isCaptain: index === 0,
      isViceCaptain: index === 1,
      isBench: index >= 11,
    }));

    await this.prisma.squadPlayer.createMany({
      data: squadPlayersData,
    });

    return this.getSquad(userId);
  }
}
