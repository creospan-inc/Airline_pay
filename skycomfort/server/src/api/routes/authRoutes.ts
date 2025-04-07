import { Router } from 'express';
import { AuthController } from '../../controllers/AuthController';

const router = Router();
const authController = new AuthController();

// Login route
router.post('/login', (req, res) => authController.login(req, res));

// Register route
router.post('/register', (req, res) => authController.register(req, res));

// Refresh token route
router.post('/refresh', (req, res) => authController.refreshToken(req, res));

// Validate token route (for debugging/testing)
router.post('/validate', (req, res) => authController.validateToken(req, res));

export default router; 