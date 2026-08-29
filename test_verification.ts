import mongoose from 'mongoose';
import { KnowledgeEntrySchema } from './src/knowledge/knowledge.schema';
import { KnowledgeService } from './src/knowledge/knowledge.service';
import { ProductSchema } from './src/products/product.schema';
import { ProductService } from './src/products/product.service';
import { AiService } from './src/ai/ai.service';

async function runVerification() {
  const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/tuntrust';
  console.log(`Connecting to MongoDB at ${mongoUri}...`);
  await mongoose.connect(mongoUri);

  const knowledgeModel = mongoose.model('KnowledgeEntry', KnowledgeEntrySchema);
  const productModel = mongoose.model('Product', ProductSchema);

  // Clear existing collections for fresh verification
  await knowledgeModel.deleteMany({});
  await productModel.deleteMany({});

  const knowledgeService = new KnowledgeService(knowledgeModel as any);
  const productService = new ProductService(productModel as any);
  const aiService = new AiService(knowledgeService, productService);

  console.log('\n==================== [1. KNOWLEDGE SEEDING & METRICS AUDIT] ====================');
  const docCount = await knowledgeService.ensureSeeded();
  const metrics = await knowledgeService.getDatabaseMetrics();
  console.log(`Total Knowledge Documents in MongoDB: ${metrics.count}`);
  metrics.documents.forEach((doc, i) => {
    console.log(`Doc #${i + 1}: Title="${doc.title}" | Source="${doc.source}" | Size=${doc.contentLength} chars`);
  });

  console.log('\n==================== [2. KNOWLEDGE RETRIEVAL TEST: "What is ID-Trust?"] ====================');
  const searchResults = await knowledgeService.search('What is ID-Trust?');
  console.log(`Retrieved ${searchResults.length} knowledge entries from MongoDB:`);
  searchResults.forEach((res, i) => {
    console.log(`Result #${i + 1}: Title="${res.title}" | Source="${res.source}"`);
    console.log(`Snippet: ${res.content.slice(0, 160).replace(/\s+/g, ' ')}...`);
  });

  console.log('\n==================== [3. PRODUCTS COLLECTION AUDIT] ====================');
  const products = await productService.findAll();
  console.log(`Total Products in MongoDB: ${products.length}`);
  products.forEach((p, i) => {
    const shape = productService.toMobileShape(p);
    console.log(`Product #${i + 1}: Name="${shape.name}" | Category="${shape.category}" | Features Count=${shape.features.length} | Description Length=${shape.description.length} chars`);
  });

  console.log('\n==================== [4. MULTI-LINGUAL AI ASSISTANT TEST & AUDIT LOGS] ====================');
  const testQueries = [
    { lang: 'English', text: 'What is ID-Trust?' },
    { lang: 'French', text: 'Quelles sont les caractéristiques du certificat Wildcard SSL ?' },
    { lang: 'Standard Arabic', text: 'كيف يمكنني الحصول على شهادة Enterprise-ID؟' },
    { lang: 'Tunisian Arabic (Derja)', text: 'n7eb n\'عرف kifesh na3mel signature electronique' },
  ];

  for (const q of testQueries) {
    console.log(`\n--- Testing Language: ${q.lang} ---`);
    const answer = await aiService.ask(q.text);
    console.log(`Question: "${q.text}"`);
    console.log(`Generated Answer:\n${answer}\n`);
  }

  await mongoose.disconnect();
  console.log('\n==================== [VERIFICATION COMPLETE] ====================');
}

runVerification().catch((err) => {
  console.error('Verification failed:', err);
  process.exit(1);
});
