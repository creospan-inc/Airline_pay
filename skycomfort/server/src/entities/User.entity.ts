import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, OneToMany } from 'typeorm';
import { Order } from './Order.entity';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn()
  id!: number;

  @Column()
  name!: string;

  @Column({ unique: true })
  email!: string;

  @Column()
  username!: string;

  @Column({ select: false })
  password!: string;

  @Column({ nullable: true })
  flightId?: string;

  @Column({ nullable: true })
  seatNumber?: string;

  @Column({ default: false })
  isStaff!: boolean;

  @Column({ default: true })
  isActive!: boolean;

  @OneToMany(() => Order, order => order.user)
  orders!: Order[];

  @CreateDateColumn()
  createdAt!: Date;

  @UpdateDateColumn()
  updatedAt!: Date;
} 