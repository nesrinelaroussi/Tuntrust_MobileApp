import * as fs from 'fs';
import * as path from 'path';
import mongoose from 'mongoose';
import { ProductSchema } from './product.schema';

async function importProducts() {
  const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/tuntrust';
  const filePath = path.resolve(__dirname, '../../products.json');

  await mongoose.connect(mongoUri);
  const ProductModel = mongoose.model('Product', ProductSchema);

  const raw = fs.readFileSync(filePath, 'utf-8');
  const products = JSON.parse(raw);

  await ProductModel.deleteMany({});
  await ProductModel.insertMany(products);

  console.log(`Imported ${products.length} products into MongoDB`);
  await mongoose.disconnect();
}

importProducts().catch((error) => {
  console.error('Import failed:', error);
  process.exit(1);
});
