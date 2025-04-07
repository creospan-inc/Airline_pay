import { Request, Response } from 'express';
import { AuthService } from '../services/AuthService';

export class AuthController {
  private authService: AuthService;
  
  constructor() {
    this.authService = new AuthService();
  }
  
  async login(req: Request, res: Response): Promise<void> {
    try {
      const { email, password } = req.body;
      
      if (!email || !password) {
        res.status(400).json({
          status: 'error',
          message: 'Email and password are required'
        });
        return;
      }
      
      const authResult = await this.authService.login(email, password);
      
      if (!authResult) {
        res.status(401).json({
          status: 'error',
          message: 'Invalid email or password'
        });
        return;
      }
      
      res.status(200).json({
        status: 'success',
        data: authResult
      });
    } catch (error) {
      res.status(500).json({
        status: 'error',
        message: 'An error occurred during login'
      });
    }
  }
  
  async register(req: Request, res: Response): Promise<void> {
    try {
      const { name, email, username, password, flightId, seatNumber, isStaff } = req.body;
      
      if (!name || !email || !password || !username) {
        res.status(400).json({
          status: 'error',
          message: 'Name, email, username, and password are required'
        });
        return;
      }
      
      const userData = {
        name,
        email,
        username,
        password,
        flightId,
        seatNumber,
        isStaff: isStaff || false
      };
      
      const authResult = await this.authService.register(userData);
      
      if (!authResult) {
        res.status(400).json({
          status: 'error',
          message: 'Registration failed. User may already exist.'
        });
        return;
      }
      
      res.status(201).json({
        status: 'success',
        data: authResult
      });
    } catch (error) {
      res.status(500).json({
        status: 'error',
        message: 'An error occurred during registration'
      });
    }
  }
  
  async refreshToken(req: Request, res: Response): Promise<void> {
    try {
      const { refreshToken } = req.body;
      
      if (!refreshToken) {
        res.status(400).json({
          status: 'error',
          message: 'Refresh token is required'
        });
        return;
      }
      
      const result = await this.authService.refreshToken(refreshToken);
      
      if (!result) {
        res.status(401).json({
          status: 'error',
          message: 'Invalid or expired refresh token'
        });
        return;
      }
      
      res.status(200).json({
        status: 'success',
        data: result
      });
    } catch (error) {
      res.status(500).json({
        status: 'error',
        message: 'An error occurred while refreshing token'
      });
    }
  }
  
  async validateToken(req: Request, res: Response): Promise<void> {
    try {
      // Get token from request (already extracted from authorization header)
      const token = req.body.token || req.query.token;
      
      if (!token) {
        res.status(400).json({
          status: 'error',
          message: 'Token is required'
        });
        return;
      }
      
      const user = await this.authService.validateToken(token);
      
      if (!user) {
        res.status(401).json({
          status: 'error',
          message: 'Invalid or expired token'
        });
        return;
      }
      
      res.status(200).json({
        status: 'success',
        data: {
          valid: true,
          user: {
            id: user.id,
            name: user.name,
            email: user.email,
            username: user.username,
            isStaff: user.isStaff
          }
        }
      });
    } catch (error) {
      res.status(500).json({
        status: 'error',
        message: 'An error occurred while validating token'
      });
    }
  }
} 