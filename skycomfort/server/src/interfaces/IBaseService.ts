import { ObjectLiteral } from 'typeorm';

export interface IBaseService<T extends ObjectLiteral> {
  findAll(options?: any): Promise<T[]>;
  findById(id: number): Promise<T | null>;
  findOne(options: any): Promise<T | null>;
  create(data: Partial<T>): Promise<T>;
  update(id: number, data: Partial<T>): Promise<T | null>;
  delete(id: number): Promise<boolean>;
} 