import { Repository } from 'typeorm';
import { Service } from '../entities/Service.entity';
import { BaseService } from './BaseService';
import { AppDataSource } from '../config/database';

export class ServiceService extends BaseService<Service> {
  constructor() {
    super(AppDataSource.getRepository(Service));
  }
  
  async findByType(type: string): Promise<Service[]> {
    return this.repository.find({
      where: { type },
      order: { createdAt: 'DESC' }
    });
  }
  
  async findByAvailability(available: boolean): Promise<Service[]> {
    return this.repository.find({
      where: { availability: available },
      order: { createdAt: 'DESC' }
    });
  }
  
  async updateAvailability(id: number, available: boolean): Promise<Service | null> {
    await this.repository.update(id, { availability: available });
    return this.findById(id);
  }
  
  async findByCategory(category: string): Promise<Service[]> {
    return this.repository.find({
      where: { category },
      order: { createdAt: 'DESC' }
    });
  }
  
  async searchServices(query: string): Promise<Service[]> {
    return this.repository
      .createQueryBuilder('service')
      .where('service.title LIKE :query OR service.description LIKE :query', { query: `%${query}%` })
      .orderBy('service.createdAt', 'DESC')
      .getMany();
  }
} 