import { AppDataSource } from '../../config/database';
import { User } from '../../entities/User.entity';
import { Service } from '../../entities/Service.entity';
import * as bcrypt from 'bcrypt';

/**
 * Seed the database with initial data
 */
async function seedDatabase() {
  console.log('Starting database seeding...');
  
  try {
    // Initialize the database connection
    const dataSource = await AppDataSource.initialize();
    console.log('Database connection initialized');
    
    // Seed admin user
    await seedAdminUser();
    
    // Seed services
    await seedServices();
    
    console.log('Database seeding completed successfully');
    process.exit(0);
  } catch (error) {
    console.error('Error during database seeding:', error);
    process.exit(1);
  }
}

/**
 * Seed an admin user
 */
async function seedAdminUser() {
  const userRepository = AppDataSource.getRepository(User);
  
  // Check if admin user already exists
  const existingAdmin = await userRepository.findOne({
    where: { email: 'admin@skycomfort.com' }
  });
  
  if (existingAdmin) {
    console.log('Admin user already exists, skipping...');
    return;
  }
  
  // Create admin user
  const hashedPassword = await bcrypt.hash('password123', 10);
  
  const adminUser = userRepository.create({
    name: 'Admin User',
    email: 'admin@skycomfort.com',
    password: hashedPassword,
    isStaff: true,
    isActive: true
  });
  
  await userRepository.save(adminUser);
  console.log('Admin user created successfully');
}

/**
 * Seed services
 */
async function seedServices() {
  const serviceRepository = AppDataSource.getRepository(Service);
  
  // Check if services already exist
  const existingServices = await serviceRepository.count();
  
  if (existingServices > 0) {
    console.log('Services already exist, skipping...');
    return;
  }
  
  // Define services to seed
  const services = [
    // Meals
    {
      title: 'Premium Chicken Meal',
      description: 'Grilled chicken with seasonal vegetables and mashed potatoes',
      price: 15.99,
      type: 'meal',
      category: 'main',
      availability: true,
      imageUrl: '/assets/images/services/meals/chicken_meal.jpg'
    },
    {
      title: 'Vegetarian Pasta',
      description: 'Penne pasta with roasted vegetables and tomato sauce',
      price: 12.99,
      type: 'meal',
      category: 'main',
      availability: true,
      imageUrl: '/assets/images/services/meals/vegetarian_pasta.jpg'
    },
    
    // Beverages
    {
      title: 'Craft Beer Selection',
      description: 'Selection of premium craft beers',
      price: 8.99,
      type: 'beverage',
      category: 'alcoholic',
      availability: true,
      imageUrl: '/assets/images/services/beverages/craft_beer.jpg'
    },
    {
      title: 'Premium Coffee',
      description: 'Freshly brewed premium coffee',
      price: 4.99,
      type: 'beverage',
      category: 'hot',
      availability: true,
      imageUrl: '/assets/images/services/beverages/premium_coffee.jpg'
    },
    
    // Entertainment
    {
      title: 'Movie Streaming Pass',
      description: 'Access to premium movie streaming service',
      price: 9.99,
      type: 'entertainment',
      category: 'movies',
      availability: true,
      imageUrl: '/assets/images/services/entertainment/movie_streaming.jpg'
    },
    {
      title: 'Gaming Premium',
      description: 'Access to premium in-flight gaming',
      price: 7.99,
      type: 'entertainment',
      category: 'games',
      availability: true,
      imageUrl: '/assets/images/services/entertainment/gaming.jpg'
    },
    
    // Comfort
    {
      title: 'Comfort Kit',
      description: 'Premium comfort kit with eye mask, ear plugs, and socks',
      price: 14.99,
      type: 'comfort',
      category: 'kits',
      availability: true,
      imageUrl: '/assets/images/services/comfort/comfort_kit.jpg'
    },
    {
      title: 'Premium Pillow',
      description: 'Memory foam travel pillow for maximum comfort',
      price: 11.99,
      type: 'comfort',
      category: 'pillow',
      availability: true,
      imageUrl: '/assets/images/services/comfort/premium_pillow.jpg'
    }
  ];
  
  // Save services to database
  for (const serviceData of services) {
    const service = serviceRepository.create(serviceData);
    await serviceRepository.save(service);
  }
  
  console.log(`${services.length} services created successfully`);
}

// Run the seed script
seedDatabase(); 