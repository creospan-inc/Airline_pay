import { Request, Response } from 'express';
import { ServiceService } from '../services/ServiceService';

export class ServiceController {
  private serviceService: ServiceService;
  
  constructor() {
    this.serviceService = new ServiceService();
  }
  
  async getAllServices(req: Request, res: Response): Promise<void> {
    try {
      const services = await this.serviceService.findAll({
        order: { createdAt: 'DESC' }
      });
      
      res.status(200).json({
        status: 'success',
        results: services.length,
        data: { services }
      });
    } catch (error) {
      res.status(500).json({
        status: 'error',
        message: 'Error fetching services'
      });
    }
  }
  
  async getServiceById(req: Request, res: Response): Promise<void> {
    try {
      const id = parseInt(req.params.id, 10);
      
      if (isNaN(id)) {
        res.status(400).json({
          status: 'error',
          message: 'Invalid ID format'
        });
        return;
      }
      
      const service = await this.serviceService.findById(id);
      
      if (!service) {
        res.status(404).json({
          status: 'error',
          message: 'Service not found'
        });
        return;
      }
      
      res.status(200).json({
        status: 'success',
        data: { service }
      });
    } catch (error) {
      res.status(500).json({
        status: 'error',
        message: 'Error fetching service'
      });
    }
  }
  
  async getServicesByType(req: Request, res: Response): Promise<void> {
    try {
      const { type } = req.params;
      const services = await this.serviceService.findByType(type);
      
      res.status(200).json({
        status: 'success',
        results: services.length,
        data: { services }
      });
    } catch (error) {
      res.status(500).json({
        status: 'error',
        message: 'Error fetching services by type'
      });
    }
  }
  
  async getServicesByCategory(req: Request, res: Response): Promise<void> {
    try {
      const { category } = req.params;
      const services = await this.serviceService.findByCategory(category);
      
      res.status(200).json({
        status: 'success',
        results: services.length,
        data: { services }
      });
    } catch (error) {
      res.status(500).json({
        status: 'error',
        message: 'Error fetching services by category'
      });
    }
  }
  
  async createService(req: Request, res: Response): Promise<void> {
    try {
      const newService = await this.serviceService.create(req.body);
      
      res.status(201).json({
        status: 'success',
        data: { service: newService }
      });
    } catch (error) {
      res.status(500).json({
        status: 'error',
        message: 'Error creating service'
      });
    }
  }
  
  async updateService(req: Request, res: Response): Promise<void> {
    try {
      const id = parseInt(req.params.id, 10);
      
      if (isNaN(id)) {
        res.status(400).json({
          status: 'error',
          message: 'Invalid ID format'
        });
        return;
      }
      
      const updatedService = await this.serviceService.update(id, req.body);
      
      if (!updatedService) {
        res.status(404).json({
          status: 'error',
          message: 'Service not found'
        });
        return;
      }
      
      res.status(200).json({
        status: 'success',
        data: { service: updatedService }
      });
    } catch (error) {
      res.status(500).json({
        status: 'error',
        message: 'Error updating service'
      });
    }
  }
  
  async deleteService(req: Request, res: Response): Promise<void> {
    try {
      const id = parseInt(req.params.id, 10);
      
      if (isNaN(id)) {
        res.status(400).json({
          status: 'error',
          message: 'Invalid ID format'
        });
        return;
      }
      
      const success = await this.serviceService.delete(id);
      
      if (!success) {
        res.status(404).json({
          status: 'error',
          message: 'Service not found or could not be deleted'
        });
        return;
      }
      
      res.status(204).send();
    } catch (error) {
      res.status(500).json({
        status: 'error',
        message: 'Error deleting service'
      });
    }
  }
  
  async updateServiceAvailability(req: Request, res: Response): Promise<void> {
    try {
      const id = parseInt(req.params.id, 10);
      
      if (isNaN(id)) {
        res.status(400).json({
          status: 'error',
          message: 'Invalid ID format'
        });
        return;
      }
      
      const { availability } = req.body;
      
      if (availability === undefined) {
        res.status(400).json({
          status: 'error',
          message: 'Availability is required'
        });
        return;
      }
      
      const updatedService = await this.serviceService.updateAvailability(id, availability);
      
      if (!updatedService) {
        res.status(404).json({
          status: 'error',
          message: 'Service not found'
        });
        return;
      }
      
      res.status(200).json({
        status: 'success',
        data: { service: updatedService }
      });
    } catch (error) {
      res.status(500).json({
        status: 'error',
        message: 'Error updating service availability'
      });
    }
  }
} 