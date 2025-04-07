import path from 'path';
import fs from 'fs';
import { AppDataSource } from '../config/database';

/**
 * Run database seeds
 */
async function runSeeds() {
  console.log('Starting database seeding...');
  
  try {
    // Initialize the database connection
    const dataSource = await AppDataSource.initialize();
    console.log('Database connection initialized');
    console.log(`SQLite database location: ${AppDataSource.options.database}`);
    
    // Get all seed files from the seeds directory
    const seedsDir = path.join(__dirname, 'seeds');
    const seedFiles = fs.readdirSync(seedsDir)
      .filter(file => file.endsWith('.ts') && file !== 'index.ts');
    
    if (seedFiles.length === 0) {
      console.log('No seed files found');
      process.exit(0);
    }
    
    console.log(`Found ${seedFiles.length} seed files to run`);
    
    // Import and run each seed file
    for (const file of seedFiles) {
      const seedPath = path.join(seedsDir, file);
      console.log(`Running seed: ${file}`);
      
      try {
        // Execute the seed file
        await require(seedPath).seed(dataSource);
        console.log(`Successfully executed seed: ${file}`);
      } catch (err) {
        console.error(`Error running seed ${file}:`, err);
      }
    }
    
    console.log('All seeds executed successfully');
    
    // Close the connection when done
    await dataSource.destroy();
    console.log('Database connection closed');
    process.exit(0);
  } catch (error) {
    console.error('Error during seeding:', error);
    process.exit(1);
  }
}

// Run seeds
runSeeds(); 