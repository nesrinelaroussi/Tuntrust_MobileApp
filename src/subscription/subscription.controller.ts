import { Controller, Get, Post, Body, Req, UseGuards, Logger } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { SubscriptionService } from './subscription.service';

@Controller('subscription')
export class SubscriptionController {
  private readonly logger = new Logger(SubscriptionController.name);

  constructor(private readonly subscriptionService: SubscriptionService) {}

  @Get('me')
  @UseGuards(AuthGuard('jwt'))
  async getMySubscription(@Req() req: any) {
    const userId = req.user?.userId || req.user?.id;
    return this.subscriptionService.getSubscriptionStatus(userId);
  }

  @Post('sync')
  @UseGuards(AuthGuard('jwt'))
  async syncSubscription(@Req() req: any) {
    const userId = req.user?.userId || req.user?.id;
    this.logger.log(`[SUBSCRIPTION CONTROLLER] Demande de synchronisation pour user: ${userId}`);
    return this.subscriptionService.syncWithRevenueCat(userId);
  }

  @Post('webhooks/revenuecat')
  async handleRevenueCatWebhook(@Body() body: any) {
    this.logger.log('[SUBSCRIPTION CONTROLLER] Webhook RevenueCat reçu');
    return this.subscriptionService.handleRevenueCatWebhook(body);
  }
}
