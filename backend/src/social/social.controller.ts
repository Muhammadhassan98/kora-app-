import { Controller, Get, Post, Body, Param, UseGuards, Request } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { SocialService } from './social.service';

@Controller('social')
@UseGuards(JwtAuthGuard)
export class SocialController {
  constructor(private readonly socialService: SocialService) {}

  @Get('posts')
  async getPosts() {
    return this.socialService.getPosts();
  }

  @Post('posts')
  async createPost(
    @Request() req,
    @Body('content') content: string,
  ) {
    return this.socialService.createPost(
      req.user.id,
      req.user.username || 'مشجع فانتكورا',
      req.user.avatarUrl || null,
      content,
    );
  }

  @Post('posts/:id/like')
  async likePost(@Param('id') postId: string) {
    return this.socialService.likePost(postId);
  }

  @Get('communities')
  async getCommunities() {
    return this.socialService.getCommunities();
  }

  @Get('chat/:roomId/messages')
  async getChatMessages(@Param('roomId') roomId: string) {
    return this.socialService.getChatMessages(roomId);
  }

  @Post('chat/:roomId/messages')
  async createChatMessage(
    @Param('roomId') roomId: string,
    @Request() req,
    @Body('content') content: string,
  ) {
    return this.socialService.createChatMessage(
      roomId,
      req.user.id,
      req.user.username || 'مشجع فانتكورا',
      req.user.avatarUrl || null,
      content,
    );
  }
}
