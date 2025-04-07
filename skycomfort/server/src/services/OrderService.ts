import { Repository } from 'typeorm';
import { Order, OrderStatus } from '../entities/Order.entity';
import { OrderItem } from '../entities/OrderItem.entity';
import { Service } from '../entities/Service.entity';
import { BaseService } from './BaseService';
import { AppDataSource } from '../config/database';

export class OrderService extends BaseService<Order> {
  private orderItemRepository: Repository<OrderItem>;
  private serviceRepository: Repository<Service>;
  
  constructor() {
    super(AppDataSource.getRepository(Order));
    this.orderItemRepository = AppDataSource.getRepository(OrderItem);
    this.serviceRepository = AppDataSource.getRepository(Service);
  }
  
  async findWithDetails(id: number): Promise<Order | null> {
    return this.repository.findOne({
      where: { id },
      relations: ['items', 'items.service', 'user', 'payments']
    });
  }
  
  async findByUser(userId: number): Promise<Order[]> {
    return this.repository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
      relations: ['items', 'items.service']
    });
  }
  
  async findByFlight(flightId: string): Promise<Order[]> {
    return this.repository.find({
      where: { flightId },
      order: { createdAt: 'DESC' },
      relations: ['items', 'user']
    });
  }
  
  async findByStatus(status: OrderStatus): Promise<Order[]> {
    return this.repository.find({
      where: { status },
      order: { createdAt: 'DESC' },
      relations: ['items', 'user']
    });
  }
  
  async updateStatus(id: number, status: OrderStatus): Promise<Order | null> {
    await this.repository.update(id, { status });
    return this.findWithDetails(id);
  }
  
  async createWithItems(orderData: Partial<Order>, items: Array<{ serviceId: number, quantity: number }>): Promise<Order> {
    // Start a transaction
    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();
    
    try {
      // Create order
      const order = this.repository.create(orderData);
      const savedOrder = await queryRunner.manager.save(order);
      
      // Calculate total amount and create order items
      let totalAmount = 0;
      const orderItems: OrderItem[] = [];
      
      for (const item of items) {
        const service = await this.serviceRepository.findOneBy({ id: item.serviceId });
        
        if (!service) {
          throw new Error(`Service with ID ${item.serviceId} not found`);
        }
        
        const orderItem = this.orderItemRepository.create({
          orderId: savedOrder.id,
          serviceId: service.id,
          quantity: item.quantity,
          price: service.price
        });
        
        const savedItem = await queryRunner.manager.save(orderItem);
        orderItems.push(savedItem);
        
        totalAmount += service.price * item.quantity;
      }
      
      // Update order with total amount
      savedOrder.totalAmount = totalAmount;
      savedOrder.items = orderItems;
      await queryRunner.manager.save(savedOrder);
      
      // Commit transaction
      await queryRunner.commitTransaction();
      
      return this.findWithDetails(savedOrder.id) as Promise<Order>;
    } catch (error) {
      // Rollback in case of error
      await queryRunner.rollbackTransaction();
      throw error;
    } finally {
      // Release query runner
      await queryRunner.release();
    }
  }
} 