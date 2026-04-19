import { verifyToken } from '../utils/jwt.js';
import { error } from '../utils/response.js';

export const authenticate = (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;

        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return error(res, 'Token tidak ditemukan', 401);
        }

        const token = authHeader.split(' ')[1];

        const decoded = verifyToken(token);

        req.user = decoded;
        next();
    
    } catch (err) {
        return error(res, 'Token tidak valid atau sudah kadaluarsa', 401);
    }
}