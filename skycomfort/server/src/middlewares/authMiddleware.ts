import { Request, Response, NextFunction } from 'express';
import { AuthService } from '../services/AuthService';

// Extend Express Request type
declare global {
  namespace Express {
    interface Request {
      user?: any;
    }
  }
}

const authService = new AuthService();

/**
 * Middleware to verify user authentication
 */
export const authMiddleware = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    // Get token from header
    const authHeader = req.headers.authorization;
    const token = authHeader && authHeader.split(' ')[1];
    
    if (!token) {
      res.status(401).json({
        status: 'error',
        message: 'Access denied. No token provided.'
      });
      return;
    }
    
    // Verify token
    const user = await authService.validateToken(token);
    
    if (!user) {
      res.status(401).json({
        status: 'error',
        message: 'Invalid or expired token'
      });
      return;
    }
    
    // Check if user is active
    if (!user.isActive) {
      res.status(403).json({
        status: 'error',
        message: 'Account is disabled'
      });
      return;
    }
    
    // Add user to request
    req.user = user;
    
    next();
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Authentication error'
    });
  }
};

/**
 * Middleware to verify staff authentication
 */
export const staffAuthMiddleware = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    // First verify user authentication
    await authMiddleware(req, res, () => {
      // User is authenticated, now check if they are staff
      if (!req.user || !req.user.isStaff) {
        res.status(403).json({
          status: 'error',
          message: 'Access denied. Staff privileges required.'
        });
        return;
      }
      
      next();
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Staff authentication error'
    });
  }
}; 