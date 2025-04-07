import { Router } from 'express';
import { OrderController } from '../../controllers/OrderController';
import { authMiddleware, staffAuthMiddleware } from '../../middlewares/authMiddleware';

const router = Router();
const orderController = new OrderController();

// Routes requiring user authentication
router.use(authMiddleware);
router.post('/', (req, res) => orderController.createOrder(req, res));
router.get('/user', (req, res) => orderController.getUserOrders(req, res));
router.get('/:id', (req, res) => orderController.getOrderById(req, res));

// Routes requiring staff authentication
router.use(staffAuthMiddleware);
router.get('/', (req, res) => orderController.getAllOrders(req, res));
router.get('/flight/:flightId', (req, res) => orderController.getFlightOrders(req, res));
router.patch('/:id/status', (req, res) => orderController.updateOrderStatus(req, res));

export default router; 