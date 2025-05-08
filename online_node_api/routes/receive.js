const express = require('express');
const router = express.Router();
const receiveController = require('../controllers/receiveController');

router.post('/',receiveController.insert)
router.get('/',receiveController.searchTop)
router.get('/history',receiveController.getDataAll)

router.get('/:id',receiveController.getDataByid)
router.post('/history',receiveController.getDataHistory)
module.exports = router;