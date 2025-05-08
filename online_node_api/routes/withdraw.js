
const express = require('express');
const router = express.Router();
const withdrawController = require('../controllers/withdrawController');


router.post('/',withdrawController.insert)
router.get('/',withdrawController.searchTop)
router.get('/historyAll/',withdrawController.getHistoryAll)
router.post('/historyAll/',withdrawController.getDataHistory)
router.post('/historyAllCheck/',withdrawController.getDataHistoryAllCheck)
router.get('/getbyship',withdrawController.getbyship)
router.get('/getbyshipSuccess',withdrawController.getbyshipSuccess)
router.put('/updateShippingCheck',withdrawController.updateShipSuccess)
router.get('/getdoShipping',withdrawController.getdoFinishShipping)
router.put('/updateFinishShipping',withdrawController.updateFinishShipping)

router.get('/:id',withdrawController.getbyID)
module.exports = router