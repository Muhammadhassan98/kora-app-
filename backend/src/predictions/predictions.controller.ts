import { Controller, Post, Get, Body, Param, UseGuards, Req, HttpCode, HttpStatus } from '@nestjs/common';
import { PredictionsService } from './predictions.service';
import { CreatePredictionDto } from './dto/create-prediction.dto';
import { ProcessPredictionDto } from './dto/process-prediction.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('predictions')
export class PredictionsController {
  constructor(private predictionsService: PredictionsService) {}

  @UseGuards(JwtAuthGuard)
  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(@Req() req: any, @Body() dto: CreatePredictionDto) {
    const data = await this.predictionsService.create(req.user.id, dto);
    return {
      success: true,
      message: 'Prediction saved successfully',
      data,
    };
  }

  @UseGuards(JwtAuthGuard)
  @Get('my')
  @HttpCode(HttpStatus.OK)
  async findMyPredictions(@Req() req: any) {
    const data = await this.predictionsService.findMyPredictions(req.user.id);
    return {
      success: true,
      data,
    };
  }

  @Get('leaderboard')
  @HttpCode(HttpStatus.OK)
  async getLeaderboard() {
    const data = await this.predictionsService.getLeaderboard();
    return {
      success: true,
      data,
    };
  }

  // Simulator route to finish and process predictions for a match (simulate admin/cron job)
  @Post('admin/process/:matchId')
  @HttpCode(HttpStatus.OK)
  async processMatch(
    @Param('matchId') matchId: string,
    @Body() dto: ProcessPredictionDto,
  ) {
    return this.predictionsService.processMatchPredictions(matchId, dto);
  }
}
