import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { Order } from './Order.entity';

export enum PaymentStatus {
  PENDING = 'pending',
  COMPLETED = 'completed',
  FAILED = 'failed',
  REFUNDED = 'refunded'
}

export enum PaymentMethod {
  CREDIT_CARD = 'credit_card',
  DEBIT_CARD = 'debit_card',
  LOYALTY_POINTS = 'loyalty_points',
  IN_FLIGHT_ACCOUNT = 'in_flight_account'
}

@Entity('payments')
export class Payment {
  @PrimaryGeneratedColumn()
  id!: number;

  @Column({ unique: true })
  transactionId!: string;

  @Column('real')
  amount!: number;

  @Column({
    type: 'text',
    default: PaymentStatus.PENDING
  })
  status!: string;

  @Column({
    type: 'text',
    default: PaymentMethod.CREDIT_CARD
  })
  paymentMethod!: string;

  @Column({ nullable: true })
  lastFourDigits?: string;

  @ManyToOne(() => Order, order => order.payments)
  @JoinColumn({ name: 'orderId' })
  order!: Order;

  @Column()
  orderId!: number;

  @Column('simple-json', { nullable: true })
  metadata?: Record<string, any>;

  @CreateDateColumn()
  createdAt!: Date;
} 