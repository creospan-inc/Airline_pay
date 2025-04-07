import { Request, Response } from 'express';
import { ServiceService } from '../services/ServiceService';
import { OrderService } from '../services/OrderService';

interface SyncItem {
  entityType: string;
  entityId: string;
  operation: 'insert' | 'update' | 'delete';
  data: any;
}

export class SyncController {
  private serviceService: ServiceService;
  private orderService: OrderService;
  
  constructor() {
    this.serviceService = new ServiceService();
    this.orderService = new OrderService();
  }
  
  async syncData(req: Request, res: Response): Promise<void> {
    try {
      const { userId, items } = req.body;
      
      if (!userId || !items || !Array.isArray(items)) {
        res.status(400).json({
          status: 'error',
          message: 'User ID and sync items array are required'
        });
        return;
      }
      
      const syncResults: Array<{ 
        success: boolean; 
        entityType: string;
        entityId: string;
        message?: string;
      }> = [];
      
      // Process each sync item
      for (const item of items as SyncItem[]) {
        try {
          const { entityType, entityId, operation, data } = item;
          
          switch (entityType) {
            case 'orders':
              await this.processSyncOrder(operation, entityId, data, syncResults);
              break;
            
            case 'user_selections':
              // Process user selections if needed
              syncResults.push({
                success: true,
                entityType,
                entityId
              });
              break;
              
            default:
              syncResults.push({
                success: false,
                entityType,
                entityId,
                message: `Unknown entity type: ${entityType}`
              });
          }
        } catch (error) {
          syncResults.push({
            success: false,
            entityType: item.entityType,
            entityId: item.entityId,
            message: error instanceof Error ? error.message : 'Unknown error'
          });
        }
      }
      
      // Return synchronization results
      res.status(200).json({
        status: 'success',
        results: syncResults.length,
        data: { 
          syncResults,
          timestamp: new Date().toISOString(),
          // Send back the latest services data for the client to update
          services: await this.serviceService.findAll({ 
            where: { availability: true } 
          })
        }
      });
    } catch (error) {
      res.status(500).json({
        status: 'error',
        message: error instanceof Error ? error.message : 'Error processing sync data'
      });
    }
  }
  
  private async processSyncOrder(
    operation: string,
    entityId: string,
    data: any,
    syncResults: Array<{ success: boolean; entityType: string; entityId: string; message?: string; }>
  ): Promise<void> {
    switch (operation) {
      case 'insert':
        try {
          // Extract order items from data
          const { items, ...orderData } = data;
          
          // Ensure any serviceId fields in the items are numbers, not strings
          const processedItems = items.map((item: any) => ({
            ...item,
            serviceId: typeof item.serviceId === 'string' ? parseInt(item.serviceId, 10) : item.serviceId
          }));
          
          // Convert any string IDs to numbers in the order data
          const processedOrderData = {
            ...orderData,
            userId: typeof orderData.userId === 'string' ? parseInt(orderData.userId, 10) : orderData.userId
          };
          
          // Create order with items
          await this.orderService.createWithItems(processedOrderData, processedItems);
          
          syncResults.push({
            success: true,
            entityType: 'orders',
            entityId
          });
        } catch (error) {
          syncResults.push({
            success: false,
            entityType: 'orders',
            entityId,
            message: error instanceof Error ? error.message : 'Error creating order'
          });
        }
        break;
        
      case 'update':
        try {
          const orderId = parseInt(entityId, 10);
          if (isNaN(orderId)) {
            throw new Error('Invalid order ID format');
          }
          
          await this.orderService.update(orderId, data);
          
          syncResults.push({
            success: true,
            entityType: 'orders',
            entityId
          });
        } catch (error) {
          syncResults.push({
            success: false,
            entityType: 'orders',
            entityId,
            message: error instanceof Error ? error.message : 'Error updating order'
          });
        }
        break;
        
      case 'delete':
        // Orders typically aren't deleted, just cancelled
        try {
          const orderId = parseInt(entityId, 10);
          if (isNaN(orderId)) {
            throw new Error('Invalid order ID format');
          }
          
          await this.orderService.update(orderId, { status: 'cancelled' });
          
          syncResults.push({
            success: true,
            entityType: 'orders',
            entityId
          });
        } catch (error) {
          syncResults.push({
            success: false,
            entityType: 'orders',
            entityId,
            message: error instanceof Error ? error.message : 'Error cancelling order'
          });
        }
        break;
        
      default:
        syncResults.push({
          success: false,
          entityType: 'orders',
          entityId,
          message: `Unknown operation: ${operation}`
        });
    }
  }
  
  async getUpdatedServices(req: Request, res: Response): Promise<void> {
    try {
      const lastSyncTimestamp = req.query.lastSync as string;
      let query = {};
      
      // If lastSync is provided, return only services updated since then
      if (lastSyncTimestamp) {
        const lastSync = new Date(lastSyncTimestamp);
        if (!isNaN(lastSync.getTime())) {
          query = {
            where: {
              updatedAt: {
                $gt: lastSync
              }
            }
          };
        }
      }
      
      const services = await this.serviceService.findAll(query);
      
      res.status(200).json({
        status: 'success',
        results: services.length,
        data: {
          services,
          timestamp: new Date().toISOString()
        }
      });
    } catch (error) {
      res.status(500).json({
        status: 'error',
        message: 'Error fetching updated services'
      });
    }
  }
} 