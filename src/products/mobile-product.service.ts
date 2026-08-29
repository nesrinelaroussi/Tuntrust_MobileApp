import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Product, ProductDocument } from './product.schema';
import { MobileProduct, MobileProductDocument } from './mobile-product.schema';

@Injectable()
export class MobileProductService {
  constructor(
    @InjectModel(MobileProduct.name) private readonly mobileProductModel: Model<MobileProductDocument>,
    @InjectModel(Product.name) private readonly productModel: Model<ProductDocument>,
  ) {}

  private summarize(text: string): string {
    if (!text) return '';
    const normalized = text.replace(/\s+/g, ' ').trim();
    return normalized.length > 180 ? `${normalized.slice(0, 177).trimEnd()}...` : normalized;
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
    return features.slice(0, 3).map((feature) => feature.replace(/^\s*[-•]\s*/, ''));
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

  private simplifiedFeatures(features: string[]): string[] {
    return features.slice(0, 4).map((feature) => feature.replace(/^\s*[-•]\s*/, '').trim());
  }

  async transformAndStore(): Promise<MobileProductDocument[]> {
    const rawProducts = await this.productModel.find().lean().exec();

    const mobileProducts = rawProducts.map((product) => ({
      name: product.name,
      description: product.description,
      shortDescription: this.summarize(product.description),
      category: this.inferCategory(product.name),
      benefits: product.benefits?.length ? product.benefits : this.inferBenefits((product as any).features || []),
      targetUsers: product.targetUsers?.length ? product.targetUsers : this.inferTargetUsers(product.name, product.description),
      icon: product.icon || this.inferIcon(product.name),
      simplifiedFeatures: product.simplifiedFeatures?.length ? product.simplifiedFeatures : this.simplifiedFeatures((product as any).features || []),
      image: product.image,
      url: product.url,
    }));

    await this.mobileProductModel.deleteMany({});
    const saved = await this.mobileProductModel.insertMany(mobileProducts);
    return saved;
  }

  async findAll(): Promise<MobileProductDocument[]> {
    return this.mobileProductModel.find().exec();
  }
}
