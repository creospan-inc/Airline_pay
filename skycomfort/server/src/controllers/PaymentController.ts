import { Request, Response } from 'express';
import { PaymentService } from '../services/PaymentService';
import { PaymentStatus } from '../entities/Payment.entity';

export class PaymentController {
  private paymentService: PaymentService;
  
  constructor() {
    this.paymentService = new PaymentService();
  }
  
  async processPayment(req: Request, res: Response): Promise<void> {
    try {
      const { 
        orderId, 
        transactionId, 
        amount, 
        paymentMethod, 
        lastFourDigits,
        metadata 
      } = req.body;
      
      if (!orderId || !transactionId || !amount || !paymentMethod) {
        res.status(400).json({
          status: 'error',
          message: 'Order ID, transaction ID, amount, and payment method are required'
        });
        return;
      }
      
      const processedOrderId = typeof orderId === 'string' ? parseInt(orderId, 10) : orderId;
      
      if (typeof processedOrderId === 'number' && isNaN(processedOrderId)) {
        res.status(400).json({
          status: 'error',
          message: 'Invalid order ID format'
        });
        return;
      }
      
      const paymentData = {
        orderId: processedOrderId,
        transactionId,
        amount,
        paymentMethod,
        lastFourDigits,
        status: PaymentStatus.COMPLETED,
        metadata
      };
      
      const payment = await this.paymentService.processPayment(paymentData);
      
      res.status(201).json({
        status: 'success',
        data: { payment }
      });
    } catch (error) {
      res.status(500).json({
        status: 'error',
        message: error instanceof Error ? error.message : 'Error processing payment'
      });
    }
  }
  
  async getPaymentByTransactionId(req: Request, res: Response): Promise<void> {
    try {
      const { transactionId } = req.params;
      const payment = await this.paymentService.findByTransactionId(transactionId);
      
      if (!payment) {
        res.status(404).json({
          status: 'error',
          message: 'Payment not found'
        });
        return;
      }
      
      res.status(200).json({
        status: 'success',
        data: { payment }
      });
    } catch (error) {
      res.status(500).json({
        status: 'error',
        message: 'Error fetching payment'
      });
    }
  }
  
  async getOrderPayments(req: Request, res: Response): Promise<void> {
    try {
      const orderId = parseInt(req.params.orderId, 10);
      
      if (isNaN(orderId)) {
        res.status(400).json({
          status: 'error',
          message: 'Invalid order ID format'
        });
        return;
      }
      
      const payments = await this.paymentService.findByOrderId(orderId);
      
      res.status(200).json({
        status: 'success',
        results: payments.length,
        data: { payments }
      });
    } catch (error) {
      res.status(500).json({
        status: 'error',
        message: 'Error fetching order payments'
      });
    }
  }
  
  async updatePaymentStatus(req: Request, res: Response): Promise<void> {
    try {
      const id = parseInt(req.params.id, 10);
      
      if (isNaN(id)) {
        res.status(400).json({
          status: 'error',
          message: 'Invalid ID format'
        });
        return;
      }
      
      const { status, metadata } = req.body;
      
      if (!status || !Object.values(PaymentStatus).includes(status as PaymentStatus)) {
        res.status(400).json({
          status: 'error',
          message: 'Valid payment status is required'
        });
        return;
      }
      
      const updatedPayment = await this.paymentService.updatePaymentStatus(
        id, 
        status as PaymentStatus,
        metadata
      );
      
      if (!updatedPayment) {
        res.status(404).json({
          status: 'error',
          message: 'Payment not found'
        });
        return;
      }
      
      res.status(200).json({
        status: 'success',
        data: { payment: updatedPayment }
      });
    } catch (error) {
      res.status(500).json({
        status: 'error',
        message: 'Error updating payment status'
      });
    }
  }
  
  async getAllPayments(req: Request, res: Response): Promise<void> {
    try {
      // Add pagination
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 10;
      const skip = (page - 1) * limit;
      
      const payments = await this.paymentService.findAll({
        skip,
        take: limit,
        order: { createdAt: 'DESC' },
        relations: ['order']
      });
      
      res.status(200).json({
        status: 'success',
        results: payments.length,
        data: { payments }
      });
    } catch (error) {
      res.status(500).json({
        status: 'error',
        message: 'Error fetching payments'
      });
    }
  }
} 