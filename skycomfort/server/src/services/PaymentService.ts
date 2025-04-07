import { Repository } from 'typeorm';
import { Payment, PaymentStatus } from '../entities/Payment.entity';
import { Order } from '../entities/Order.entity';
import { BaseService } from './BaseService';
import { AppDataSource } from '../config/database';

export class PaymentService extends BaseService<Payment> {
  private orderRepository: Repository<Order>;
  
  constructor() {
    super(AppDataSource.getRepository(Payment));
    this.orderRepository = AppDataSource.getRepository(Order);
  }
  
  async findByTransactionId(transactionId: string): Promise<Payment | null> {
    return this.repository.findOne({
      where: { transactionId },
      relations: ['order']
    });
  }
  
  async findByOrderId(orderId: number): Promise<Payment[]> {
    return this.repository.find({
      where: { orderId },
      order: { createdAt: 'DESC' }
    });
  }
  
  async findByStatus(status: PaymentStatus): Promise<Payment[]> {
    return this.repository.find({
      where: { status },
      order: { createdAt: 'DESC' },
      relations: ['order']
    });
  }
  
  async processPayment(paymentData: Partial<Payment>): Promise<Payment> {
    // Start a transaction
    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();
    
    try {
      // Create payment record
      const payment = this.repository.create(paymentData);
      const savedPayment = await queryRunner.manager.save(payment);
      
      // If payment was successful, update the order status
      if (payment.status === PaymentStatus.COMPLETED && payment.orderId) {
        // Update order status to paid/processing
        await queryRunner.manager.update(Order, payment.orderId, {
          status: 'processing'
        });
      }
      
      // Commit transaction
      await queryRunner.commitTransaction();
      
      return savedPayment;
    } catch (error) {
      // Rollback in case of error
      await queryRunner.rollbackTransaction();
      throw error;
    } finally {
      // Release query runner
      await queryRunner.release();
    }
  }
  
  async updatePaymentStatus(
    id: number, 
    status: PaymentStatus, 
    metadata?: Record<string, any>
  ): Promise<Payment | null> {
    // Start a transaction
    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();
    
    try {
      // Update payment
      await queryRunner.manager.update(Payment, id, {
        status,
        ...(metadata ? { metadata } : {})
      });
      
      // Get updated payment
      const payment = await queryRunner.manager.findOne(Payment, {
        where: { id },
        relations: ['order']
      });
      
      if (payment && payment.orderId) {
        // Update order status based on payment status
        if (status === PaymentStatus.COMPLETED) {
          await queryRunner.manager.update(Order, payment.orderId, {
            status: 'processing'
          });
        } else if (status === PaymentStatus.FAILED) {
          await queryRunner.manager.update(Order, payment.orderId, {
            status: 'cancelled'
          });
        }
      }
      
      // Commit transaction
      await queryRunner.commitTransaction();
      
      return payment;
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