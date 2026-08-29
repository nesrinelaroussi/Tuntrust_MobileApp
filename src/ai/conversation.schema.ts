import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type ConversationDocument = Conversation & Document;

@Schema()
export class ChatMessage {
  @Prop({ required: true })
  text: string;

  @Prop({ required: true })
  isUser: boolean;

  @Prop({ default: () => new Date() })
  createdAt: Date;
}

const ChatMessageSchema = SchemaFactory.createForClass(ChatMessage);

@Schema({ timestamps: true })
export class Conversation {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  userId: Types.ObjectId;

  @Prop({ required: true, default: 'Nouvelle conversation' })
  title: string;

  @Prop({ type: [ChatMessageSchema], default: [] })
  messages: ChatMessage[];
}

export const ConversationSchema = SchemaFactory.createForClass(Conversation);
