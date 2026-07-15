import { Controller, Get, Post, Body, UseGuards, Request } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { EconomyService } from './economy.service';

@Controller('economy')
@UseGuards(JwtAuthGuard)
export class EconomyController {
  constructor(private readonly economyService: EconomyService) {}

  @Get('transactions')
  async getTransactions(@Request() req) {
    return this.economyService.getTransactions(req.user.id);
  }

  @Post('claim-ad')
  async claimAdReward(@Request() req) {
    return this.economyService.claimAdReward(req.user.id);
  }

  @Post('purchase-item')
  async purchaseStoreItem(
    @Request() req,
    @Body('itemId') itemId: string,
  ) {
    return this.economyService.purchaseStoreItem(req.user.id, itemId);
  }
}
