import { Request, Response, NextFunction } from 'express';

export interface AppError extends Error {
  statusCode?: number;
  status?: string;
  isOperational?: boolean;
}

/**
 * Global error handler middleware
 */
export const errorHandler = (
  err: AppError,
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  const statusCode = err.statusCode || 500;
  const status = err.status || 'error';
  
  // Determine if we're in development environment
  const isDev = process.env.NODE_ENV === 'development';
  
  // If this is a known/operational error, we send the error message
  // Otherwise, we send a generic message for unexpected errors
  if (isDev) {
    // In development, we send detailed error information
    res.status(statusCode).json({
      status,
      message: err.message,
      error: err,
      stack: err.stack
    });
  } else {
    // In production, limit error information
    // Only send detailed messages for operational errors
    if (err.isOperational) {
      res.status(statusCode).json({
        status,
        message: err.message
      });
    } else {
      // For programming or unknown errors, send generic message
      console.error('ERROR 💥', err);
      res.status(500).json({
        status: 'error',
        message: 'Something went wrong'
      });
    }
  }
}; 