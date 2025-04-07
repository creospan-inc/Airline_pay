import { Router } from 'express';
import { PaymentController } from '../../controllers/PaymentController';
import { authMiddleware, staffAuthMiddleware } from '../../middlewares/authMiddleware';

const router = Router();
const paymentController = new PaymentController();

// Routes requiring user authentication
router.use(authMiddleware);
router.post('/', (req, res) => paymentController.processPayment(req, res));
router.get('/transaction/:transactionId', (req, res) => paymentController.getPaymentByTransactionId(req, res));
router.get('/order/:orderId', (req, res) => paymentController.getOrderPayments(req, res));

// Routes requiring staff authentication
router.use(staffAuthMiddleware);
router.get('/', (req, res) => paymentController.getAllPayments(req, res));
router.patch('/:id/status', (req, res) => paymentController.updatePaymentStatus(req, res));

export default router; 