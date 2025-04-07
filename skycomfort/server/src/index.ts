import dotenv from 'dotenv';
import app from './app';
import { initializeDatabase } from './config/database';

// Load environment variables
dotenv.config();

const PORT = process.env.PORT || 3000;

// Initialize database
initializeDatabase()
  .then(() => {
    console.log('Database connection established');
    
    // Start server after database initialization
    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
      console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
    });
  })
  .catch(error => {
    console.error('Database connection failed:', error);
    process.exit(1);
  });