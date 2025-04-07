import jwt from 'jsonwebtoken';
import { UserService } from './UserService';
import { User } from '../entities/User.entity';
import { SignOptions } from 'jsonwebtoken';

export class AuthService {
  private userService: UserService;
  private jwtSecret: string;
  private jwtExpiresIn: string;
  private jwtRefreshExpiresIn: string;
  
  constructor() {
    this.userService = new UserService();
    this.jwtSecret = process.env.JWT_SECRET || 'your_jwt_secret_key_here';
    this.jwtExpiresIn = process.env.JWT_EXPIRES_IN || '1d';
    this.jwtRefreshExpiresIn = process.env.JWT_REFRESH_EXPIRES_IN || '7d';
  }
  
  async login(email: string, password: string): Promise<{ token: string, refreshToken: string, user: Partial<User> } | null> {
    // Find user by email
    const user = await this.userService.findByEmail(email);
    
    // Check if user exists and verify password
    if (!user || !(await this.userService.verifyPassword(user, password))) {
      return null;
    }
    
    // Generate tokens
    const token = this.generateToken(user);
    const refreshToken = this.generateRefreshToken(user);
    
    // Return tokens and user info (without password)
    const { password: _, ...userWithoutPassword } = user;
    return {
      token,
      refreshToken,
      user: userWithoutPassword as User
    };
  }
  
  async refreshToken(refreshToken: string): Promise<{ token: string, refreshToken: string } | null> {
    try {
      // Verify refresh token
      const decoded = jwt.verify(refreshToken, this.jwtSecret) as { id: number };
      
      // Find user
      const user = await this.userService.findById(decoded.id);
      
      if (!user) {
        return null;
      }
      
      // Generate new tokens
      const newToken = this.generateToken(user);
      const newRefreshToken = this.generateRefreshToken(user);
      
      return {
        token: newToken,
        refreshToken: newRefreshToken
      };
    } catch (error) {
      return null;
    }
  }
  
  async register(userData: Partial<User>): Promise<{ token: string, refreshToken: string, user: Partial<User> } | null> {
    try {
      // Check if user already exists
      const existingUser = await this.userService.findByEmail(userData.email || '');
      
      if (existingUser) {
        return null;
      }
      
      // Create new user
      const newUser = await this.userService.createUser(userData);
      
      // Generate tokens
      const token = this.generateToken(newUser);
      const refreshToken = this.generateRefreshToken(newUser);
      
      // Return tokens and user info (without password)
      const { password: _, ...userWithoutPassword } = newUser;
      return {
        token,
        refreshToken,
        user: userWithoutPassword as User
      };
    } catch (error) {
      return null;
    }
  }
  
  async validateToken(token: string): Promise<User | null> {
    try {
      // Verify token
      const decoded = jwt.verify(token, this.jwtSecret) as { id: number };
      
      // Find user
      return this.userService.findById(decoded.id);
    } catch (error) {
      return null;
    }
  }
  
  private generateToken(user: User): string {
    return jwt.sign(
      { id: user.id, isStaff: user.isStaff },
      this.jwtSecret,
      { expiresIn: this.jwtExpiresIn as jwt.SignOptions['expiresIn'] }
    );
  }
  
  private generateRefreshToken(user: User): string {
    return jwt.sign(
      { id: user.id },
      this.jwtSecret,
      { expiresIn: this.jwtRefreshExpiresIn as jwt.SignOptions['expiresIn'] }
    );
  }
} 