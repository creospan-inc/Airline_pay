import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { Order } from './Order.entity';
import { Service } from './Service.entity';

@Entity('order_items')
export class OrderItem {
  @PrimaryGeneratedColumn()
  id!: number;

  @ManyToOne(() => Order, order => order.items, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'orderId' })
  order!: Order;

  @Column()
  orderId!: number;

  @ManyToOne(() => Service, service => service.orderItems)
  @JoinColumn({ name: 'serviceId' })
  service!: Service;

  @Column()
  serviceId!: number;

  @Column({ default: 1 })
  quantity!: number;

  @Column('real')
  price!: number;

  @Column({ nullable: true })
  notes?: string;

  @CreateDateColumn()
  createdAt!: Date;

  @UpdateDateColumn()
  updatedAt!: Date;
} 