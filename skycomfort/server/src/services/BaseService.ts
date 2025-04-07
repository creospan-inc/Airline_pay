import { Repository, FindOptionsWhere, ObjectLiteral } from 'typeorm';
import { IBaseService } from '../interfaces/IBaseService';

export abstract class BaseService<T extends ObjectLiteral> implements IBaseService<T> {
  protected repository: Repository<T>;
  
  constructor(repository: Repository<T>) {
    this.repository = repository;
  }
  
  async findAll(options?: any): Promise<T[]> {
    return this.repository.find(options);
  }
  
  async findById(id: number): Promise<T | null> {
    return this.repository.findOneBy({ id } as unknown as FindOptionsWhere<T>);
  }
  
  async findOne(options: any): Promise<T | null> {
    return this.repository.findOne(options);
  }
  
  async create(data: Partial<T>): Promise<T> {
    const entity = this.repository.create(data as any);
    return this.repository.save(entity as any);
  }
  
  async update(id: number, data: Partial<T>): Promise<T | null> {
    await this.repository.update(id, data as any);
    return this.findById(id);
  }
  
  async delete(id: number): Promise<boolean> {
    const result = await this.repository.delete(id);
    return !!result.affected && result.affected > 0;
  }
} 