import { Request, Response } from 'express';
import { OrderService } from '../services/OrderService';
import { OrderStatus } from '../entities/Order.entity';

export class OrderController {
  private orderService: OrderService;
  
  constructor() {
    this.orderService = new OrderService();
  }
  
  async createOrder(req: Request, res: Response): Promise<void> {
    try {
      const { flightId, seatNumber, items, userId, notes } = req.body;
      
      if (!flightId || !seatNumber || !items || !Array.isArray(items) || items.length === 0) {
        res.status(400).json({
          status: 'error',
          message: 'Flight ID, seat number, and items are required'
        });
        return;
      }
      
      // Convert any string IDs to numbers in items array
      const processedItems = items.map(item => ({
        ...item,
        serviceId: typeof item.serviceId === 'string' ? parseInt(item.serviceId, 10) : item.serviceId
      }));
      
      const orderData = {
        flightId,
        seatNumber,
        userId: typeof userId === 'string' ? parseInt(userId, 10) : userId,
        notes,
        status: OrderStatus.PENDING,
        totalAmount: 0 // Will be calculated in service
      };
      
      const newOrder = await this.orderService.createWithItems(orderData, processedItems);
      
      res.status(201).json({
        status: 'success',
        data: { order: newOrder }
      });
    } catch (error) {
      res.status(500).json({
        status: 'error',
        message: error instanceof Error ? error.message : 'Error creating order'
      });
    }
  }
  
  async getOrderById(req: Request, res: Response): Promise<void> {
    try {
      const id = parseInt(req.params.id, 10);
      
      if (isNaN(id)) {
        res.status(400).json({
          status: 'error',
          message: 'Invalid ID format'
        });
        return;
      }
      
      const order = await this.orderService.findWithDetails(id);
      
      if (!order) {
        res.status(404).json({
          status: 'error',
          message: 'Order not found'
        });
        return;
      }
      
      res.status(200).json({
        status: 'success',
        data: { order }
      });
    } catch (error) {
      res.status(500).json({
        status: 'error',
        message: 'Error fetching order'
      });
    }
  }
  
  async getUserOrders(req: Request, res: Response): Promise<void> {
    try {
      let userId: number;
      
      if (req.params.userId) {
        userId = parseInt(req.params.userId, 10);
        if (isNaN(userId)) {
          res.status(400).json({
            status: 'error',
            message: 'Invalid user ID format'
          });
          return;
        }
      } else if ((req.user as any)?.id) {
        userId = (req.user as any).id;
      } else {
        res.status(400).json({
          status: 'error',
          message: 'User ID is required'
        });
        return;
      }
      
      const orders = await this.orderService.findByUser(userId);
      
      res.status(200).json({
        status: 'success',
        results: orders.length,
        data: { orders }
      });
    } catch (error) {
      res.status(500).json({
        status: 'error',
        message: 'Error fetching user orders'
      });
    }
  }
  
  async getFlightOrders(req: Request, res: Response): Promise<void> {
    try {
      const { flightId } = req.params;
      
      if (!flightId) {
        res.status(400).json({
          status: 'error',
          message: 'Flight ID is required'
        });
        return;
      }
      
      const orders = await this.orderService.findByFlight(flightId);
      
      res.status(200).json({
        status: 'success',
        results: orders.length,
        data: { orders }
      });
    } catch (error) {
      res.status(500).json({
        status: 'error',
        message: 'Error fetching flight orders'
      });
    }
  }
  
  async updateOrderStatus(req: Request, res: Response): Promise<void> {
    try {
      const id = parseInt(req.params.id, 10);
      
      if (isNaN(id)) {
        res.status(400).json({
          status: 'error',
          message: 'Invalid ID format'
        });
        return;
      }
      
      const { status } = req.body;
      
      if (!status || !Object.values(OrderStatus).includes(status as OrderStatus)) {
        res.status(400).json({
          status: 'error',
          message: 'Valid order status is required'
        });
        return;
      }
      
      const updatedOrder = await this.orderService.updateStatus(id, status as OrderStatus);
      
      if (!updatedOrder) {
        res.status(404).json({
          status: 'error',
          message: 'Order not found'
        });
        return;
      }
      
      res.status(200).json({
        status: 'success',
        data: { order: updatedOrder }
      });
    } catch (error) {
      res.status(500).json({
        status: 'error',
        message: 'Error updating order status'
      });
    }
  }
  
  async getAllOrders(req: Request, res: Response): Promise<void> {
    try {
      // Add pagination
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 10;
      const skip = (page - 1) * limit;
      
      const orders = await this.orderService.findAll({
        skip,
        take: limit,
        order: { createdAt: 'DESC' },
        relations: ['items', 'items.service', 'user']
      });
      
      res.status(200).json({
        status: 'success',
        results: orders.length,
        data: { orders }
      });
    } catch (error) {
      res.status(500).json({
        status: 'error',
        message: 'Error fetching orders'
      });
    }
  }
} 