import { Injectable, OnModuleInit } from '@nestjs/common';
import { PrismaService } from '../prisma.service';

@Injectable()
export class SocialService implements OnModuleInit {
  constructor(private readonly prisma: PrismaService) {}

  async onModuleInit() {
    // Seed initial communities if empty
    const count = await this.prisma.community.count();
    if (count === 0) {
      await this.prisma.community.createMany({
        data: [
          { name: 'رابطة عشاق الهلال', description: 'منتدى جماهير نادي الهلال السعودي الرسمي', memberCount: 15420, symbol: '🔵⚪' },
          { name: 'رابطة عشاق النصر', description: 'منتدى جماهير نادي النصر العالمي', memberCount: 12450, symbol: '🟡🔵' },
          { name: 'رابطة عشاق الاتحاد', description: 'منتدى جماهير نادي الاتحاد العميد', memberCount: 9860, symbol: '🟡🖤' },
          { name: 'رابطة عشاق الأهلي', description: 'منتدى جماهير نادي الأهلي المصري نادي القرن', memberCount: 19800, symbol: '🟢⚪' },
          { name: 'عشاق برشلونة', description: 'رابطة البلوغرانا العربية الرسمية', memberCount: 22400, symbol: '🔴🔵' },
          { name: 'عشاق ريال مدريد', description: 'رابطة النادي الملكي وجماهير الميرينغي', memberCount: 24500, symbol: '⚪👑' },
        ],
      });

      // Seed initial mock posts
      await this.prisma.post.create({
        data: {
          userId: 'seed-user-1',
          username: 'أحمد الحارثي',
          content: 'توقعاتكم لمباراة الكلاسيكو اليوم؟ الهلال في مستوى ناري بعد الصفقات الأخيرة، ولكن النصر قادر على حسمها برأسية رونالدو! ⚽🔥',
          likesCount: 142,
          comments: {
            create: [
              { userId: 'seed-user-2', username: 'خالد الحربي', content: 'الهلال يمر بأفضل حالاته، فوز هلالي مريح ٢-٠ بالتأكيد.' },
              { userId: 'seed-user-3', username: 'سعد الدوسري', content: 'رونالدو راح يثبت جدارته اليوم ويسجل ثنائية بإذن الله.' },
            ],
          },
        },
      });

      await this.prisma.post.create({
        data: {
          userId: 'seed-user-4',
          username: 'كريم التونسي',
          content: 'مين فيكم جاب نقاط عالية بالجولة دي بالفانتازي؟ أنا اخترت ميتروفيتش كابتن وجاب لي ٢٤ نقطة! 🏆🪙',
          likesCount: 98,
        },
      });
    }
  }

  async getPosts() {
    return this.prisma.post.findMany({
      include: { comments: true },
      orderBy: { createdAt: 'desc' },
    });
  }

  async createPost(userId: string, username: string, avatarUrl: string | null, content: string) {
    return this.prisma.post.create({
      data: {
        userId,
        username,
        avatarUrl,
        content,
      },
      include: { comments: true },
    });
  }

  async likePost(postId: string) {
    const post = await this.prisma.post.findUnique({ where: { id: postId } });
    if (!post) throw new Error('المنشور غير موجود');
    return this.prisma.post.update({
      where: { id: postId },
      data: { likesCount: post.likesCount + 1 },
      include: { comments: true },
    });
  }

  async getCommunities() {
    return this.prisma.community.findMany({
      orderBy: { memberCount: 'desc' },
    });
  }

  async getChatMessages(roomId: string) {
    return this.prisma.chatMessage.findMany({
      where: { roomId },
      orderBy: { createdAt: 'asc' },
      take: 50, // latest 50 messages
    });
  }

  async createChatMessage(roomId: string, userId: string, username: string, avatarUrl: string | null, content: string) {
    // Check if user is VIP (coins > 500)
    const profile = await this.prisma.profile.findUnique({ where: { userId } });
    const isVip = profile ? profile.coinsBalance > 500 : false;

    return this.prisma.chatMessage.create({
      data: {
        roomId,
        userId,
        username,
        avatarUrl,
        content,
        isVip,
      },
    });
  }
}
