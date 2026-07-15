import { Module } from '@nestjs/common';
import { FantasyService } from './fantasy.service';
import { FantasyController } from './fantasy.controller';
import { PrismaService } from '../prisma.service';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [AuthModule],
  controllers: [FantasyController],
  providers: [FantasyService, PrismaService],
  exports: [FantasyService],
})
export class FantasyModule {}
