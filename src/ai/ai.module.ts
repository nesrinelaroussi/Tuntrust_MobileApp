import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { AiController } from './ai.controller';
import { AiService } from './ai.service';
import { KnowledgeModule } from '../knowledge/knowledge.module';
import { ProductsModule } from '../products/products.module';
import { Conversation, ConversationSchema } from './conversation.schema';

@Module({
  imports: [
    KnowledgeModule,
    ProductsModule,
    MongooseModule.forFeature([
      { name: Conversation.name, schema: ConversationSchema },
    ]),
  ],
  controllers: [AiController],
  providers: [AiService],
})
export class AiModule {}
