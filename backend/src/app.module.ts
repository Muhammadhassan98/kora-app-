import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { MatchesModule } from './matches/matches.module';
import { PredictionsModule } from './predictions/predictions.module';
import { FantasyModule } from './fantasy/fantasy.module';

@Module({
  imports: [AuthModule, MatchesModule, PredictionsModule, FantasyModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
