const express = require('express')
const router = express.Router();
const stockbalanceController = require('../controllers/stockBalanceController')

router.get('/',stockbalanceController.getData)
// router.get('/:id',stockbalanceController.getDataByID)
router.get('/:wareID',stockbalanceController.getDataBywareID)
router.get('/all_image/:ID',stockbalanceController.getImageID)
module.exports = router;