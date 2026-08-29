import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';

export type KnowledgeEntryDocument = HydratedDocument<KnowledgeEntry>;

@Schema({ timestamps: true })
export class KnowledgeEntry {
  @Prop({ required: true, trim: true })
  title: string;

  @Prop({ required: true })
  content: string;

  @Prop({ type: [Number], default: [] })
  embedding: number[];

  @Prop({ required: true, trim: true })
  source: string;
}

export const KnowledgeEntrySchema = SchemaFactory.createForClass(KnowledgeEntry);
