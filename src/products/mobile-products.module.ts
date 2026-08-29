import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { Product, ProductSchema } from './product.schema';
import { MobileProduct, MobileProductSchema } from './mobile-product.schema';
import { MobileProductService } from './mobile-product.service';
import { MobileProductsController } from './mobile-products.controller';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: Product.name, schema: ProductSchema }]),
    MongooseModule.forFeature([{ name: MobileProduct.name, schema: MobileProductSchema }]),
  ],
  controllers: [MobileProductsController],
  providers: [MobileProductService],
  exports: [MobileProductService],
})
export class MobileProductsModule {}
