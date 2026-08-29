import {
  Controller,
  Get,
  Post,
  Delete,
  Req,
  UseGuards,
  Param,
  Body,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { AiService } from './ai.service';
import { KnowledgeService } from '../knowledge/knowledge.service';

@Controller('ai')
export class AiController {
  constructor(
    private readonly aiService: AiService,
    private readonly knowledgeService: KnowledgeService,
  ) {}

  @Post('chat')
  @UseGuards(AuthGuard('jwt'))
  async chat(@Req() req: any, @Body() body: any) {
    const startedAt = Date.now();
    const question = typeof body === 'string' ? body : body?.question ?? '';
    const conversationId = body?.conversationId;
    const userId = req.user?.userId;

    const result = await this.aiService.chat(question, conversationId, userId);
    const responseTimeMs = Date.now() - startedAt;

    console.log(
      `[AI CONTROLLER] chat question="${question}" conversationId="${result.conversationId}" responseTimeMs=${responseTimeMs}`,
    );

    return {
      answer: result.answer,
      conversationId: result.conversationId,
      title: result.title,
      responseTimeMs,
    };
  }

  @Get('conversations')
  @UseGuards(AuthGuard('jwt'))
  async getConversations(@Req() req: any) {
    const userId = req.user?.userId;
    return this.aiService.getConversations(userId);
  }

  @Post('conversations')
  @UseGuards(AuthGuard('jwt'))
  async createConversation(@Req() req: any) {
    const userId = req.user?.userId;
    return this.aiService.createConversation(userId);
  }

  @Get('conversations/:id')
  @UseGuards(AuthGuard('jwt'))
  async getConversationById(@Param('id') id: string, @Req() req: any) {
    const userId = req.user?.userId;
    return this.aiService.getConversationById(id, userId);
  }

  @Delete('conversations/:id')
  @UseGuards(AuthGuard('jwt'))
  async deleteConversation(@Param('id') id: string, @Req() req: any) {
    const userId = req.user?.userId;
    await this.aiService.deleteConversation(id, userId);
    return { success: true, message: 'Conversation supprimée avec succès.' };
  }

  @Get('metrics')
  async getMetrics() {
    return this.knowledgeService.getDatabaseMetrics();
  }
}
