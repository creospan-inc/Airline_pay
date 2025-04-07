import { Router } from 'express';
import authRoutes from './authRoutes';
import serviceRoutes from './serviceRoutes';
import orderRoutes from './orderRoutes';
import paymentRoutes from './paymentRoutes';
import syncRoutes from './syncRoutes';

const router = Router();

// Register all routes
router.use('/auth', authRoutes);
router.use('/services', serviceRoutes);
router.use('/orders', orderRoutes);
router.use('/payments', paymentRoutes);
router.use('/sync', syncRoutes);

export default router; 