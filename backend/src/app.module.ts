import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { MatchesModule } from './matches/matches.module';
import { PredictionsModule } from './predictions/predictions.module';
import { FantasyModule } from './fantasy/fantasy.module';
import { EconomyModule } from './economy/economy.module';
import { SocialModule } from './social/social.module';

@Module({
  imports: [AuthModule, MatchesModule, PredictionsModule, FantasyModule, EconomyModule, SocialModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
