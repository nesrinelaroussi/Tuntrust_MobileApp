import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { KnowledgeEntry, KnowledgeEntrySchema } from './knowledge.schema';
import { KnowledgeService } from './knowledge.service';

@Module({
  imports: [MongooseModule.forFeature([{ name: KnowledgeEntry.name, schema: KnowledgeEntrySchema }])],
  providers: [KnowledgeService],
  exports: [KnowledgeService],
})
export class KnowledgeModule {}
