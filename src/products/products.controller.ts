import { Controller, Get, Param } from '@nestjs/common';
import { ProductService } from './product.service';

@Controller('products')
export class ProductsController {
  constructor(private readonly productService: ProductService) {}

  @Get()
  async findAll() {
    const products = await this.productService.findAll();
    return products.map((product) => this.productService.toMobileShape(product));
  }

  @Get(':id')
  async findById(@Param('id') id: string) {
    const product = await this.productService.findById(id);
    return product ? this.productService.toMobileShape(product) : null;
  }
}
