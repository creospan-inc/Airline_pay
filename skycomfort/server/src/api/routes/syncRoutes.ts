import { Router } from 'express';
import { SyncController } from '../../controllers/SyncController';
import { authMiddleware } from '../../middlewares/authMiddleware';

const router = Router();
const syncController = new SyncController();

// Routes requiring user authentication
router.use(authMiddleware);
router.post('/', (req, res) => syncController.syncData(req, res));
router.get('/services', (req, res) => syncController.getUpdatedServices(req, res));

export default router; 