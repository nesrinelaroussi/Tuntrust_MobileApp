import { Injectable, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import * as http from 'https';
import {
  Subscription,
  SubscriptionDocument,
  SubscriptionPlan,
} from './subscription.schema';

export interface AiAccessCheckResult {
  allowed: boolean;
  isPro?: boolean;
  questionCount?: number;
  remaining?: number;
  reason?: string;
}

@Injectable()
export class SubscriptionService {
  private readonly logger = new Logger(SubscriptionService.name);

  // Clé publique / REST RevenueCat pour le mode TEST (medaichain-v2 / TunTrust)
  private readonly revenueCatApiKey = 'test_mThrMrvmkejjQOaswkPPTrxmuLA';

  constructor(
    @InjectModel(Subscription.name)
    private subscriptionModel: Model<SubscriptionDocument>,
  ) {}

  async getOrCreateSubscription(userId: string): Promise<SubscriptionDocument> {
    if (!Types.ObjectId.isValid(userId)) {
      throw new Error('Identifiant utilisateur invalide.');
    }

    let sub = await this.subscriptionModel
      .findOne({ userId: new Types.ObjectId(userId) })
      .exec();

    if (!sub) {
      sub = await this.subscriptionModel.create({
        userId: new Types.ObjectId(userId),
        plan: SubscriptionPlan.FREE,
        questionCount: 0,
        isActive: true,
      });
    }

    return sub;
  }

  /**
   * Vérifie et consomme de manière ATOMIQUE une question gratuite en MongoDB.
   * Utilise `findOneAndUpdate` avec condition `{ questionCount: { $lt: 3 } }` et `$inc: { questionCount: 1 }`.
   * Empêche toute concurrence d'outrepasser la limite de 3 questions.
   */
  async tryConsumeFreeQuestionOrCheckPro(userId: string): Promise<AiAccessCheckResult> {
    const sub = await this.getOrCreateSubscription(userId);

    // Si l'utilisateur est abonné TunTrust Pro
    if (sub.plan === SubscriptionPlan.PRO && sub.isActive) {
      return {
        allowed: true,
        isPro: true,
        questionCount: sub.questionCount,
        remaining: 999,
      };
    }

    // Sinon utilisateur gratuit : tentative de consommation atomique
    const updated = await this.subscriptionModel
      .findOneAndUpdate(
        {
          userId: new Types.ObjectId(userId),
          plan: SubscriptionPlan.FREE,
          questionCount: { $lt: 3 },
        },
        { $inc: { questionCount: 1 } },
        { new: true },
      )
      .exec();

    if (updated) {
      const remaining = Math.max(0, 3 - updated.questionCount);
      this.logger.log(
        `[ATOMIC QUOTA] Consommation réussie pour user=${userId}. Questions utilisées: ${updated.questionCount}/3 (Restantes: ${remaining})`,
      );
      return {
        allowed: true,
        isPro: false,
        questionCount: updated.questionCount,
        remaining,
      };
    }

    // Si null : quota gratuit de 3 questions épuisé
    this.logger.warn(`[ATOMIC QUOTA] Quota gratuit atteint pour user=${userId}. Accès refusé.`);
    return {
      allowed: false,
      isPro: false,
      questionCount: sub.questionCount,
      remaining: 0,
      reason: 'QUOTA_EXCEEDED',
    };
  }

  async getSubscriptionStatus(userId: string) {
    const sub = await this.getOrCreateSubscription(userId);
    const isPro = sub.plan === SubscriptionPlan.PRO && sub.isActive;
    const remaining = isPro ? 999 : Math.max(0, 3 - sub.questionCount);

    return {
      plan: sub.plan,
      isPro,
      questionCount: sub.questionCount,
      remainingFreeQuestions: remaining,
      maxFreeQuestions: 3,
    };
  }

  /**
   * Synchronise l'abonnement après un achat RevenueCat côté mobile.
   *
   * En mode TEST (clé publique `test_...`): Le SDK RevenueCat client a déjà vérifié
   * l'achat avant d'appeler cette route. L'API REST RevenueCat nécessite une clé
   * secrète (`sk_...`) que nous ne stockons pas ici. Nous accordons donc directement
   * le statut Pro pour les utilisateurs authentifiés (JWT) en mode test.
   *
   * En mode PRODUCTION: Remplacer `revenueCatApiKey` par la clé secrète `sk_...`
   * du tableau de bord RevenueCat — la vérification REST sera alors effective.
   */
  async syncWithRevenueCat(userId: string): Promise<any> {
    this.logger.log(`[REVENUECAT SYNC] Synchronisation pour user: ${userId}`);

    const isTestMode = this.revenueCatApiKey.startsWith('test_');

    if (isTestMode) {
      // Mode TEST: La clé publique SDK ne peut pas interroger l'API REST RevenueCat.
      // Le SDK Flutter a déjà validé l'achat. On accorde Pro directement.
      this.logger.warn(
        `[REVENUECAT SYNC] Mode TEST détecté (clé publique). Activation directe de Pro pour user=${userId}. ` +
        `En production, utilisez une clé secrète sk_... pour la vérification REST.`,
      );
      try {
        const sub = await this.getOrCreateSubscription(userId);
        sub.plan = SubscriptionPlan.PRO;
        sub.isActive = true;
        await sub.save();
        this.logger.log(`[REVENUECAT SYNC] ✅ Statut Pro activé (mode test) pour user: ${userId}`);
        return this.getSubscriptionStatus(userId);
      } catch (e: any) {
        this.logger.error(`[REVENUECAT SYNC ERROR] ${e?.message ?? e}`);
        return this.getSubscriptionStatus(userId);
      }
    }

    // Mode PRODUCTION : Vérification serveur via l'API REST RevenueCat (clé secrète)
    try {
      const isEntitled = await this.queryRevenueCatSubscriber(userId);
      const sub = await this.getOrCreateSubscription(userId);

      if (isEntitled) {
        sub.plan = SubscriptionPlan.PRO;
        sub.isActive = true;
        await sub.save();
        this.logger.log(`[REVENUECAT SYNC] ✅ Statut Pro activé (vérification REST) pour user: ${userId}`);
      } else {
        this.logger.warn(`[REVENUECAT SYNC] Entitlement non trouvé côté RevenueCat REST pour user: ${userId}`);
      }

      return this.getSubscriptionStatus(userId);
    } catch (e: any) {
      this.logger.error(`[REVENUECAT SYNC ERROR] ${e?.message ?? e}`);
      return this.getSubscriptionStatus(userId);
    }
  }


  /**
   * Gère les webhooks RevenueCat (Mode Test & Prod).
   */
  async handleRevenueCatWebhook(payload: any): Promise<any> {
    const event = payload?.event;
    if (!event) return { status: 'ignored', reason: 'No event' };

    const eventType = event.type;
    const appUserId = event.app_user_id;

    if (!appUserId || !Types.ObjectId.isValid(appUserId)) {
      return { status: 'ignored', reason: 'Invalid app_user_id' };
    }

    this.logger.log(`[REVENUECAT WEBHOOK] Reçu event=${eventType} pour user=${appUserId}`);

    const sub = await this.getOrCreateSubscription(appUserId);

    switch (eventType) {
      case 'INITIAL_PURCHASE':
      case 'RENEWAL':
      case 'NON_RENEWING_PURCHASE':
        sub.plan = SubscriptionPlan.PRO;
        sub.isActive = true;
        if (event.expiration_at_ms) {
          sub.subscriptionEnd = new Date(event.expiration_at_ms);
        }
        await sub.save();
        this.logger.log(`[REVENUECAT WEBHOOK] User ${appUserId} passe en TunTrust Pro.`);
        break;

      case 'CANCELLATION':
      case 'EXPIRATION':
        sub.plan = SubscriptionPlan.FREE;
        sub.isActive = false;
        await sub.save();
        this.logger.log(`[REVENUECAT WEBHOOK] User ${appUserId} repasse en Free.`);
        break;

      default:
        this.logger.log(`[REVENUECAT WEBHOOK] Event ${eventType} non traité.`);
    }

    return { status: 'ok', event: eventType };
  }

  private queryRevenueCatSubscriber(userId: string): Promise<boolean> {
    return new Promise((resolve) => {
      const options = {
        hostname: 'api.revenuecat.com',
        path: `/v1/subscribers/${encodeURIComponent(userId)}`,
        method: 'GET',
        headers: {
          Authorization: `Bearer ${this.revenueCatApiKey}`,
          Accept: 'application/json',
        },
      };

      const req = http.request(options, (res) => {
        let body = '';
        res.on('data', (chunk) => (body += chunk));
        res.on('end', () => {
          try {
            if (res.statusCode === 200) {
              const data = JSON.parse(body);
              const entitlements = data?.subscriber?.entitlements ?? {};
              const proEntitlement = entitlements['tuntrust_pro'] || entitlements['medaichain Pro'];
              const isActive = proEntitlement && proEntitlement.expires_date
                ? new Date(proEntitlement.expires_date) > new Date()
                : false;
              return resolve(Boolean(isActive));
            }
          } catch (e) {
            // Ignore JSON parse errors in test fallback
          }
          // En mode test / dev si la réponse REST est non configurée, accepter si l'utilisateur est identifié en test
          resolve(false);
        });
      });

      req.on('error', () => resolve(false));
      req.end();
    });
  }
}
