import { DataSource } from 'typeorm';
import dotenv from 'dotenv';
import path from 'path';
import { User } from '../entities/User.entity';
import { Service } from '../entities/Service.entity';
import { Order } from '../entities/Order.entity';
import { OrderItem } from '../entities/OrderItem.entity';
import { Payment } from '../entities/Payment.entity';

// Load environment variables
dotenv.config();

// Define database file path
const dbPath = process.env.DB_PATH || path.join(__dirname, '../../', 'skycomfort.sqlite');

// Create and export the TypeORM DataSource
export const AppDataSource = new DataSource({
  type: 'sqlite',
  database: dbPath,
  synchronize: process.env.NODE_ENV === 'development', // Only in development
  logging: process.env.NODE_ENV === 'development',
  entities: [
    User,
    Service,
    Order,
    OrderItem,
    Payment
  ],
  migrations: [
    __dirname + '/../db/migrations/*.ts'
  ],
  subscribers: [],
});

// Initialize database connection
export const initializeDatabase = async () => {
  try {
    await AppDataSource.initialize();
    console.log('Data Source has been initialized!');
    console.log(`SQLite database location: ${dbPath}`);
    return AppDataSource;
  } catch (error) {
    console.error('Error during Data Source initialization:', error);
    throw error;
  }
}; 