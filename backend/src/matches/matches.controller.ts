import { Controller, Get, Param } from '@nestjs/common';
import { MatchesService, Match } from './matches.service';

@Controller('matches')
export class MatchesController {
  constructor(private matchesService: MatchesService) {}

  @Get()
  findAll(): Match[] {
    return this.matchesService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string): Match {
    return this.matchesService.findOne(id);
  }
}
