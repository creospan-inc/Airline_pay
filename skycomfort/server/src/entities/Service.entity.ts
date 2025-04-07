import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, OneToMany } from 'typeorm';
import { OrderItem } from './OrderItem.entity';

@Entity('services')
export class Service {
  @PrimaryGeneratedColumn()
  id!: number;

  @Column()
  title!: string;

  @Column()
  description!: string;

  @Column('real')
  price!: number;

  @Column()
  type!: string;

  @Column({ nullable: true })
  imageUrl?: string;

  @Column({ default: true })
  availability!: boolean;

  @Column({ nullable: true })
  category?: string;

  @Column('simple-json', { nullable: true })
  metadata?: Record<string, any>;

  @OneToMany(() => OrderItem, orderItem => orderItem.service)
  orderItems!: OrderItem[];

  @CreateDateColumn()
  createdAt!: Date;

  @UpdateDateColumn()
  updatedAt!: Date;
} 