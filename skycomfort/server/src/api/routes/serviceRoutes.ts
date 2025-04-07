import { Router } from 'express';
import { ServiceController } from '../../controllers/ServiceController';
import { authMiddleware, staffAuthMiddleware } from '../../middlewares/authMiddleware';

const router = Router();
const serviceController = new ServiceController();

// Public routes that don't require authentication
router.get('/', (req, res) => serviceController.getAllServices(req, res));
router.get('/:id', (req, res) => serviceController.getServiceById(req, res));
router.get('/type/:type', (req, res) => serviceController.getServicesByType(req, res));
router.get('/category/:category', (req, res) => serviceController.getServicesByCategory(req, res));

// Routes requiring staff authentication
router.use(staffAuthMiddleware);
router.post('/', (req, res) => serviceController.createService(req, res));
router.put('/:id', (req, res) => serviceController.updateService(req, res));
router.delete('/:id', (req, res) => serviceController.deleteService(req, res));
router.patch('/:id/availability', (req, res) => serviceController.updateServiceAvailability(req, res));

export default router; 