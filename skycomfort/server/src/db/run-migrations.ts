import { AppDataSource } from '../config/database';
import path from 'path';

/**
 * Run database migrations
 */
async function runMigrations() {
  console.log('Starting database migrations...');
  
  try {
    // Initialize the database connection
    const dataSource = await AppDataSource.initialize();
    console.log('Database connection initialized');
    console.log(`SQLite database location: ${AppDataSource.options.database}`);
    
    // Run pending migrations
    const migrations = await dataSource.runMigrations();
    
    if (migrations.length === 0) {
      console.log('No pending migrations to run');
    } else {
      console.log(`Successfully ran ${migrations.length} migrations:`);
      migrations.forEach(migration => {
        console.log(`- ${migration.name}`);
      });
    }
    
    // Close the connection and exit
    await dataSource.destroy();
    console.log('Database connection closed');
    process.exit(0);
  } catch (error) {
    console.error('Error during migrations:', error);
    process.exit(1);
  }
}

// Run migrations
runMigrations(); 