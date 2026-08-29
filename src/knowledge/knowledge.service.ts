import * as fs from 'fs';
import * as path from 'path';
import { Injectable, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { KnowledgeEntry, KnowledgeEntryDocument } from './knowledge.schema';

@Injectable()
export class KnowledgeService {
  private readonly logger = new Logger(KnowledgeService.name);

  constructor(
    @InjectModel(KnowledgeEntry.name) private readonly knowledgeModel: Model<KnowledgeEntryDocument>,
  ) {}

  private getKnowledgeDir(): string | null {
    const candidates = [
      path.resolve(process.cwd(), '../tuntrust_ai/data'),
      path.resolve(process.cwd(), 'tuntrust_ai/data'),
      path.resolve(__dirname, '../../../tuntrust_ai/data'),
      path.resolve(__dirname, '../../tuntrust_ai/data'),
      path.resolve(process.cwd(), '../tuntrust_ai'),
      path.resolve(process.cwd(), 'tuntrust_ai'),
    ];

    for (const dir of candidates) {
      if (fs.existsSync(dir)) {
        const mdFiles = fs.readdirSync(dir).filter((f) => f.endsWith('.md'));
        if (mdFiles.length > 0) {
          return dir;
        }
      }
    }
    return null;
  }

  private extractTitleAndCleanContent(raw: string, filename: string): { title: string; content: string } {
    let text = raw;
    const firstH1Index = text.search(/^#\s+/m);
    if (firstH1Index !== -1) {
      text = text.slice(firstH1Index);
    }

    text = text
      .replace(/\[\s*Skip to main content\s*\].*?\n/gi, '')
      .replace(/##\s*Search.*?\n/gi, '')
      .replace(/##\s*Menu\s*(Top|Principale|footer).*?(\n\s*\*.*?)+/gi, '')
      .replace(/##\s*NOS QUALIFICATIONS.*?\n(\|.*?\n)+/gi, '')
      .replace(/!\[.*?\]\(.*?\)/gi, '')
      .replace(/googleplus\d*/gi, '')
      .replace(/\n{3,}/g, '\n\n')
      .trim();

    // Extract title from markdown h1 (# Title)
    const h1Match = text.match(/^#\s+(.+)$/m);
    let title = h1Match ? h1Match[1].trim() : path.basename(filename, '.md');
    title = title.replace(/^#+\s*/, '').replace(/\|.*$/, '').trim();
    if (!title || title.length < 3) {
      title = path.basename(filename, '.md');
    }

    return { title, content: text };
  }

  public async ensureSeeded(): Promise<number> {
    const count = await this.knowledgeModel.countDocuments();
    if (count > 0) {
      return count;
    }

    const dataDir = this.getKnowledgeDir();
    if (!dataDir) {
      this.logger.warn('No knowledge markdown directory found for seeding.');
      return 0;
    }

    const files = fs.readdirSync(dataDir)
      .filter((file) => file.endsWith('.md'))
      .sort((a, b) => a.localeCompare(b));

    const docs = files.map((file) => {
      const fullPath = path.join(dataDir, file);
      const rawContent = fs.readFileSync(fullPath, 'utf8');
      const { title, content } = this.extractTitleAndCleanContent(rawContent, file);

      return {
        title,
        content,
        embedding: [],
        source: `tuntrust_ai/data/${file}`,
      };
    });

    if (docs.length > 0) {
      await this.knowledgeModel.insertMany(docs);
      this.logger.log(`==================== [KNOWLEDGE SEEDING METRICS] ====================`);
      this.logger.log(`Inserted ${docs.length} knowledge documents into MongoDB collection.`);
      docs.forEach((doc, idx) => {
        this.logger.log(`Doc #${idx + 1}: Title="${doc.title}" | Source="${doc.source}" | Content Length=${doc.content.length} chars`);
      });
      this.logger.log(`=====================================================================`);
    }

    return this.knowledgeModel.countDocuments();
  }

  async search(query: string): Promise<KnowledgeEntryDocument[]> {
    await this.ensureSeeded();

    const normalized = query.trim().toLowerCase();
    if (!normalized) {
      return [];
    }

    // Direct product term scoring
    const terms = ['id-trust', 'idtrust', 'enterprise-id', 'cev', '2d-doc', 'wildcard', 'san', 'ssl', 'vpn', 'digigo', 'tunsign', 'tunstamp', 'code'];
    const matchedTerms = terms.filter((term) => normalized.includes(term));

    if (matchedTerms.length > 0) {
      const regex = new RegExp(matchedTerms[0], 'i');
      const titleMatches = await this.knowledgeModel.find({ title: { $regex: regex } }).limit(5).exec();
      const contentMatches = await this.knowledgeModel.find({ content: { $regex: regex } }).limit(5).exec();

      const combined = [...titleMatches];
      for (const item of contentMatches) {
        if (!combined.some((c) => c._id.toString() === item._id.toString())) {
          combined.push(item);
        }
      }

      if (combined.length > 0) {
        return combined.slice(0, 5);
      }
    }

    const keywords = normalized
      .split(/\s+/)
      .map((w) => w.replace(/[^\w\u0600-\u06FF]/g, ''))
      .filter((w) => w.length > 2 && !['what', 'how', 'when', 'where', 'which', 'pourquoi', 'comment', 'quelles', 'quel'].includes(w));

    if (keywords.length === 0) {
      return this.knowledgeModel.find().limit(3).exec();
    }

    const titleMatches = await this.knowledgeModel
      .find({ $or: keywords.map((k) => ({ title: { $regex: k, $options: 'i' } })) })
      .limit(3)
      .exec();

    const contentMatches = await this.knowledgeModel
      .find({ $or: keywords.map((k) => ({ content: { $regex: k, $options: 'i' } })) })
      .limit(5)
      .exec();

    const combined = [...titleMatches];
    for (const item of contentMatches) {
      if (!combined.some((c) => c._id.toString() === item._id.toString())) {
        combined.push(item);
      }
    }

    return combined.slice(0, 5);
  }

  async getDatabaseMetrics() {
    await this.ensureSeeded();
    const docs = await this.knowledgeModel.find().exec();
    return {
      count: docs.length,
      documents: docs.map((d) => ({
        id: d._id,
        title: d.title,
        source: d.source,
        contentLength: d.content.length,
      })),
    };
  }
}

