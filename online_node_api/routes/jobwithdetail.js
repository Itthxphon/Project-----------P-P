const express =require('express')
const router = express.Router()
const JobWithDetailController = require('../controllers/viewDeliveryJobWithDetailController')

router.get('/:id',JobWithDetailController.getDataByJobID)
router.get('/getHistorySuccess/:id',JobWithDetailController.getDataSuccessHistory)
module.exports = router     