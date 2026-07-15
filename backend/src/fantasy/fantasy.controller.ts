import { Controller, Get, Post, Body, UseGuards, Query, Request } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { FantasyService } from './fantasy.service';

@Controller('fantasy')
@UseGuards(JwtAuthGuard)
export class FantasyController {
  constructor(private readonly fantasyService: FantasyService) {}

  @Get('players')
  async getPlayers(
    @Query('position') position?: string,
    @Query('club') club?: string,
    @Query('search') search?: string,
  ) {
    return this.fantasyService.getPlayers(position, club, search);
  }

  @Get('squad')
  async getSquad(@Request() req) {
    return this.fantasyService.getSquad(req.user.id);
  }

  @Post('squad/transfers')
  async updateSquad(
    @Request() req,
    @Body('playerIds') playerIds: string[],
  ) {
    return this.fantasyService.updateSquad(req.user.id, playerIds);
  }
}
