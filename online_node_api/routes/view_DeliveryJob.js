const express = require('express')
const router = express.Router()
const deliveryJobController = require('../controllers/viewDeliveryJobController')

router.get('/',deliveryJobController.getDataAll)
router.post('/getbyID/',deliveryJobController.getDataByID)
router.post('/getDataJobDeliverySuccess/',deliveryJobController.getDataJobDeliverySuccess)
router.get('/getJobSuccess/',deliveryJobController.getDatJobSuccessAll)
// router.post('/getbyIDSuccess/',deliveryJobController.getDataByID)
router.put('/updateDeliveryStep/:F_docJobDeliveryID',deliveryJobController.updateJob)

module.exports = router 

