import * as fs from 'fs';
import * as path from 'path';
import { Injectable, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Product, ProductDocument } from './product.schema';

@Injectable()
export class ProductService {
  private readonly logger = new Logger(ProductService.name);

  constructor(
    @InjectModel(Product.name) private readonly productModel: Model<ProductDocument>,
  ) {}

  private summarize(text: string): string {
    if (!text) return '';
    const normalized = text.replace(/\s+/g, ' ').trim();
    return normalized.length > 200 ? `${normalized.slice(0, 197).trimEnd()}...` : normalized;
  }

  private inferCategory(name: string): string {
    const lower = name.toLowerCase();
    if (lower.includes('ssl')) return 'Sécurité web';
    if (lower.includes('vpn')) return 'Réseau';
    if (lower.includes('code')) return 'Sécurité logicielle';
    if (lower.includes('cachet')) return 'Signature électronique';
    if (lower.includes('id-trust')) return 'Authentification';
    return 'Certification';
  }

  private inferBenefits(features: string[]): string[] {
    return features.slice(0, 5).map((feature) => feature.replace(/^\s*[-•]\s*/, '').trim());
  }

  private inferTargetUsers(name: string, description: string): string[] {
    const text = `${name} ${description}`.toLowerCase();
    const users: string[] = [];
    if (text.includes('entreprise') || text.includes('entreprises')) users.push('Entreprises');
    if (text.includes('administration') || text.includes('organisations')) users.push('Administrations');
    if (text.includes('particulier') || text.includes('individus')) users.push('Particuliers');
    if (users.length === 0) users.push('Utilisateurs');
    return users;
  }

  private inferIcon(name: string): string {
    const lower = name.toLowerCase();
    if (lower.includes('ssl')) return '🔐';
    if (lower.includes('vpn')) return '🛡️';
    if (lower.includes('code')) return '💻';
    if (lower.includes('cachet')) return '🖋️';
    return '✅';
  }

  private async seedFromJson(): Promise<ProductDocument[]> {
    const candidates = [
      path.resolve(process.cwd(), 'products.json'),
      path.resolve(process.cwd(), 'tuntrust/products.json'),
      path.resolve(__dirname, '../../products.json'),
      path.resolve(__dirname, '../../../products.json'),
    ];

    let filePath: string | null = null;
    for (const c of candidates) {
      if (fs.existsSync(c)) {
        filePath = c;
        break;
      }
    }

    if (!filePath) {
      this.logger.warn('products.json not found for seeding.');
      return [];
    }

    const raw = fs.readFileSync(filePath, 'utf8');
    const products = JSON.parse(raw) as Array<Record<string, any>>;

    const normalized = products.map((product) => ({
      name: product.name,
      description: product.description,
      shortDescription: this.summarize(product.description),
      category: this.inferCategory(product.name),
      benefits: this.inferBenefits(product.features || []),
      targetUsers: this.inferTargetUsers(product.name, product.description),
      icon: this.inferIcon(product.name),
      simplifiedFeatures: (product.features || []).map((feature: string) => feature.replace(/^\s*[-•]\s*/, '').trim()),
      features: product.features || [],
      image: product.image,
      url: product.url,
    }));

    await this.productModel.insertMany(normalized);
    this.logger.log(`Seeded ${normalized.length} products into MongoDB.`);
    return this.productModel.find().sort({ name: 1 }).exec();
  }

  async findAll(): Promise<ProductDocument[]> {
    const existing = await this.productModel.find().sort({ name: 1 }).exec();
    if (existing.length > 0) {
      return existing;
    }
    return this.seedFromJson();
  }

  toMobileShape(product: ProductDocument) {
    const rawFeatures = Array.isArray((product as any).features) && (product as any).features.length > 0
      ? (product as any).features
      : Array.isArray((product as any).simplifiedFeatures)
        ? (product as any).simplifiedFeatures
        : [];
    const rawBenefits = Array.isArray((product as any).benefits) ? (product as any).benefits : [];
    const rawUsers = Array.isArray((product as any).targetUsers) ? (product as any).targetUsers : [];

    return {
      _id: (product as any)._id?.toString?.() ?? (product as any)._id,
      id: (product as any)._id?.toString?.() ?? (product as any)._id,
      name: product.name,
      description: product.description, // Full detailed description from MongoDB!
      shortDescription: (product as any).shortDescription || this.summarize(product.description || ''),
      category: (product as any).category || this.inferCategory(product.name),
      benefits: rawBenefits.length > 0 ? rawBenefits : this.inferBenefits(rawFeatures),
      targetUsers: rawUsers.length > 0 ? rawUsers : this.inferTargetUsers(product.name, product.description || ''),
      icon: (product as any).icon || this.inferIcon(product.name),
      simplifiedFeatures: (product as any).simplifiedFeatures || rawFeatures,
      features: rawFeatures,
      image: product.image,
      url: product.url,
    };
  }

  async findById(id: string): Promise<ProductDocument | null> {
    return this.productModel.findById(id).exec();
  }

  async create(productData: Partial<Product>): Promise<ProductDocument> {
    const createdProduct = new this.productModel(productData);
    return createdProduct.save();
  }

  async createMany(products: Array<Partial<Product>>): Promise<any> {
    return this.productModel.insertMany(products);
  }
}

