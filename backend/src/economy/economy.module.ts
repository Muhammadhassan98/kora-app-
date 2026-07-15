import { Module } from '@nestjs/common';
import { EconomyService } from './economy.service';
import { EconomyController } from './economy.controller';
import { PrismaService } from '../prisma.service';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [AuthModule],
  controllers: [EconomyController],
  providers: [EconomyService, PrismaService],
  exports: [EconomyService],
})
export class EconomyModule {}
