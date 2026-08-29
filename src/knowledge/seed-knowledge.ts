import * as fs from 'fs';
import * as path from 'path';
import mongoose from 'mongoose';
import { KnowledgeEntrySchema } from './knowledge.schema';

function getKnowledgeDir(): string | null {
  const candidates = [
    path.resolve(process.cwd(), '../tuntrust_ai/data'),
    path.resolve(process.cwd(), 'tuntrust_ai/data'),
    path.resolve(__dirname, '../../tuntrust_ai/data'),
  ];

  for (const dir of candidates) {
    if (fs.existsSync(dir)) {
      return dir;
    }
  }
  return null;
}

function extractTitleAndCleanContent(raw: string, filename: string): { title: string; content: string } {
  let text = raw
    .replace(/\[\s*Skip to main content\s*\].*?\n/gi, '')
    .replace(/##\s*Search.*?\n/gi, '')
    .replace(/!\[.*?\]\(.*?\)/gi, '')
    .replace(/\n{3,}/g, '\n\n')
    .trim();

  const h1Match = text.match(/^#\s+(.+)$/m);
  const title = h1Match ? h1Match[1].trim() : path.basename(filename, '.md');
  return { title, content: text };
}

async function seedKnowledge() {
  const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/tuntrust';
  await mongoose.connect(mongoUri);

  const model = mongoose.model('KnowledgeEntry', KnowledgeEntrySchema);
  const count = await model.countDocuments();
  if (count > 0) {
    console.log('Knowledge already seeded');
    await mongoose.disconnect();
    return;
  }

  const baseDir = getKnowledgeDir();
  if (!baseDir) {
    throw new Error('No TunTrust markdown data directory found.');
  }

  const files = fs.readdirSync(baseDir)
    .filter((file) => file.endsWith('.md'))
    .sort((a, b) => a.localeCompare(b));

  const docs = files.map((file) => {
    const fullPath = path.join(baseDir, file);
    const rawContent = fs.readFileSync(fullPath, 'utf8');
    const { title, content } = extractTitleAndCleanContent(rawContent, file);

    return {
      title,
      content,
      embedding: [],
      source: `tuntrust_ai/data/${file}`,
    };
  });

  await model.insertMany(docs);
  console.log(`Seeded ${docs.length} knowledge documents`);
  await mongoose.disconnect();
}

seedKnowledge().catch((error) => {
  console.error(error);
  process.exit(1);
});
