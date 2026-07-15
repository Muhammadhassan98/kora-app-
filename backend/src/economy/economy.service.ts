import { Injectable, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';

@Injectable()
export class EconomyService {
  constructor(private readonly prisma: PrismaService) {}

  async getTransactions(userId: string) {
    return this.prisma.coinTransaction.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async claimAdReward(userId: string) {
    const rewardAmount = 20;

    // Use Prisma transaction to ensure Atomicity
    return this.prisma.$transaction(async (tx) => {
      // 1. Update user profile coin balance
      const profile = await tx.profile.findUnique({
        where: { userId },
      });

      if (!profile) {
        throw new BadRequestException('الملف الشخصي للمستخدم غير موجود');
      }

      const updatedProfile = await tx.profile.update({
        where: { userId },
        data: {
          coinsBalance: profile.coinsBalance + rewardAmount,
        },
      });

      // 2. Record transaction history
      await tx.coinTransaction.create({
        data: {
          userId,
          amount: rewardAmount,
          transactionType: 'ad_reward',
          description: 'شاهد إعلان فيديو مجزي وحصل على 20 عملة',
        },
      });

      return updatedProfile;
    });
  }

  async purchaseStoreItem(userId: string, itemId: string) {
    let price = 0;
    let description = '';

    if (itemId === 'neon_avatar_frame') {
      price = 100;
      description = 'شراء إطار الأفاتار النيون المميز';
    } else if (itemId === 'vip_access_7d') {
      price = 250;
      description = 'شراء اشتراك VIP لمدة 7 أيام';
    } else {
      throw new BadRequestException('عنصر المتجر غير صالح');
    }

    return this.prisma.$transaction(async (tx) => {
      const profile = await tx.profile.findUnique({
        where: { userId },
      });

      if (!profile) {
        throw new BadRequestException('الملف الشخصي للمستخدم غير موجود');
      }

      if (profile.coinsBalance < price) {
        throw new BadRequestException('رصيد العملات غير كافٍ لإتمام عملية الشراء');
      }

      const updatedProfile = await tx.profile.update({
        where: { userId },
        data: {
          coinsBalance: profile.coinsBalance - price,
        },
      });

      await tx.coinTransaction.create({
        data: {
          userId,
          amount: -price,
          transactionType: 'store_buy',
          description,
        },
      });

      return updatedProfile;
    });
  }
}
