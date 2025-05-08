const express = require('express');
const router = express.Router();
const receiveDetailController = require('../controllers/receiveDetailController')


router.post('/',receiveDetailController.insertDetail)
router.get('/:id',receiveDetailController.getDetailByid)
module.exports = router