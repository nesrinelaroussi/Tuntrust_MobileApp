import {
  Injectable,
  CanActivate,
  ExecutionContext,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { SubscriptionService } from './subscription.service';

@Injectable()
export class SubscriptionGuard implements CanActivate {
  constructor(private readonly subscriptionService: SubscriptionService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user || (!user.userId && !user.id)) {
      throw new HttpException('Non authentifié.', HttpStatus.UNAUTHORIZED);
    }

    const userId = user.userId || user.id;

    const access = await this.subscriptionService.tryConsumeFreeQuestionOrCheckPro(userId);

    if (!access.allowed) {
      throw new HttpException(
        {
          statusCode: HttpStatus.FORBIDDEN,
          message: 'Quota gratuit de 3 questions atteint. Abonnement TunTrust Pro requis.',
          code: 'QUOTA_EXCEEDED',
          remainingFreeQuestions: 0,
        },
        HttpStatus.FORBIDDEN,
      );
    }

    return true;
  }
}
