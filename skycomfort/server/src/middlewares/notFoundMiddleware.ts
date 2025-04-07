import { Request, Response, NextFunction } from 'express';

/**
 * Middleware to handle undefined routes
 */
export const notFoundMiddleware = (req: Request, res: Response, next: NextFunction): void => {
  res.status(404).json({
    status: 'error',
    message: `Cannot ${req.method} ${req.originalUrl}`
  });
}; 