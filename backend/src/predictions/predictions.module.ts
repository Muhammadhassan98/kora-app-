import { Module } from '@nestjs/common';
import { PredictionsService } from './predictions.service';
import { PredictionsController } from './predictions.controller';
import { PrismaService } from '../prisma.service';
import { MatchesModule } from '../matches/matches.module';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [MatchesModule, AuthModule],
  controllers: [PredictionsController],
  providers: [PredictionsService, PrismaService],
})
export class PredictionsModule {}
