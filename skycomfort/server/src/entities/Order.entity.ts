import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, OneToMany, JoinColumn } from 'typeorm';
import { User } from './User.entity';
import { OrderItem } from './OrderItem.entity';
import { Payment } from './Payment.entity';

// Define order status as string literals for SQLite compatibility
export enum OrderStatus {
  PENDING = 'pending',
  PROCESSING = 'processing',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled'
}

@Entity('orders')
export class Order {
  @PrimaryGeneratedColumn()
  id!: number;

  @Column()
  flightId!: string;

  @Column()
  seatNumber!: string;

  @Column({
    type: 'text',
    default: OrderStatus.PENDING
  })
  status!: string;

  @Column('real')
  totalAmount!: number;

  @ManyToOne(() => User, user => user.orders)
  @JoinColumn({ name: 'userId' })
  user!: User;

  @Column()
  userId!: number;

  @OneToMany(() => OrderItem, orderItem => orderItem.order, { cascade: true })
  items!: OrderItem[];

  @OneToMany(() => Payment, payment => payment.order)
  payments!: Payment[];

  @Column({ nullable: true })
  notes?: string;

  @CreateDateColumn()
  createdAt!: Date;

  @UpdateDateColumn()
  updatedAt!: Date;
} 