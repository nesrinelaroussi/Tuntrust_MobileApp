import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type SubscriptionDocument = Subscription & Document;

export enum SubscriptionPlan {
  FREE = 'free',
  PRO = 'pro',
}

@Schema({ timestamps: true })
export class Subscription {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true, unique: true, index: true })
  userId: Types.ObjectId;

  @Prop({ type: String, enum: SubscriptionPlan, default: SubscriptionPlan.FREE })
  plan: string;

  @Prop({ type: Number, default: 0 })
  questionCount: number;

  @Prop({ type: Date })
  subscriptionEnd?: Date;

  @Prop({ type: Boolean, default: true })
  isActive: boolean;
}

export const SubscriptionSchema = SchemaFactory.createForClass(Subscription);
