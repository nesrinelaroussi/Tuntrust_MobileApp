import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type ProductDocument = Product & Document;

@Schema({ timestamps: true })
export class Product {
  @Prop({ required: true, trim: true })
  name: string;

  @Prop({ required: true })
  description: string;

  @Prop({ required: true })
  shortDescription: string;

  @Prop({ required: true, trim: true })
  category: string;

  @Prop({ type: [String], default: [] })
  benefits: string[];

  @Prop({ type: [String], default: [] })
  targetUsers: string[];

  @Prop({ required: true, trim: true })
  icon: string;

  @Prop({ type: [String], default: [] })
  simplifiedFeatures: string[];

  @Prop({ type: [String], default: [] })
  features: string[];

  @Prop({ required: true })
  image: string;

  @Prop({ required: true, trim: true })
  url: string;
}

export const ProductSchema = SchemaFactory.createForClass(Product);
