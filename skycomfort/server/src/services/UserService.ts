import { Repository } from 'typeorm';
import * as bcrypt from 'bcrypt';
import { User } from '../entities/User.entity';
import { BaseService } from './BaseService';
import { AppDataSource } from '../config/database';

export class UserService extends BaseService<User> {
  constructor() {
    super(AppDataSource.getRepository(User));
  }
  
  async findByEmail(email: string): Promise<User | null> {
    return this.repository.findOne({ where: { email } });
  }
  
  async findByFlightAndSeat(flightId: string, seatNumber: string): Promise<User | null> {
    return this.repository.findOne({
      where: { flightId, seatNumber }
    });
  }
  
  async createUser(userData: Partial<User>): Promise<User> {
    // Hash password if provided
    if (userData.password) {
      userData.password = await bcrypt.hash(userData.password, 10);
    }
    
    const user = this.repository.create(userData);
    return this.repository.save(user);
  }
  
  async updateUser(id: number, userData: Partial<User>): Promise<User | null> {
    // Hash password if it's being updated
    if (userData.password) {
      userData.password = await bcrypt.hash(userData.password, 10);
    }
    
    await this.repository.update(id, userData);
    return this.findById(id);
  }
  
  async verifyPassword(user: User, password: string): Promise<boolean> {
    // Fetch user with password included
    const userWithPassword = await this.repository.findOne({
      where: { id: user.id },
      select: ['id', 'password']
    });
    
    if (!userWithPassword || !userWithPassword.password) {
      return false;
    }
    
    return bcrypt.compare(password, userWithPassword.password);
  }
  
  async findWithOrders(userId: number): Promise<User | null> {
    return this.repository.findOne({
      where: { id: userId },
      relations: ['orders', 'orders.items', 'orders.items.service']
    });
  }
  
  async deactivateUser(id: number): Promise<boolean> {
    const result = await this.repository.update(id, { isActive: false });
    return result.affected !== undefined && result.affected > 0;
  }
  
  async activateUser(id: number): Promise<boolean> {
    const result = await this.repository.update(id, { isActive: true });
    return result.affected !== undefined && result.affected > 0;
  }
} 