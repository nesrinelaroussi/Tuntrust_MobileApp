import { Controller, Get, Post } from '@nestjs/common';
import { MobileProductService } from './mobile-product.service';

@Controller('mobile-products')
export class MobileProductsController {
  constructor(private readonly mobileProductService: MobileProductService) {}

  @Get()
  async findAll() {
    return this.mobileProductService.findAll();
  }

  @Post('transform')
  async transform() {
    return this.mobileProductService.transformAndStore();
  }
}
