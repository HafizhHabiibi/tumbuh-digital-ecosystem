import express from 'express';
import {
    getProfile,
    createOrangTua,
    getOrangTua,
    getOrangTuaById,
} from '../controllers/kaderController.js';
import { authenticate } from '../middlewares/auth.js';
import { authorizeRole } from '../middlewares/role.js';

const router = express.Router();

router.use((req, res, next) => {
    console.log(`[KADER ROUTE] ${req.method} ${req.path}`)
    next()
})

router.use(authenticate)
router.use(authorizeRole('kader'))

router.get('/profile', getProfile)
router.post('/orang-tua', createOrangTua)
router.get('/orang-tua', getOrangTua)
router.get('/orang-tua/:id', getOrangTuaById)

export default router;