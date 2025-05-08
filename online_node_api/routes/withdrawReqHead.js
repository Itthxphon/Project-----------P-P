const express = require('express')
const router = express.Router()
const withdrawReqController = require('../controllers/withdrawRequestController')


router.get('/' , withdrawReqController.showAll)
router.get('/getID',withdrawReqController.searchTop)

router.get('/:id' , withdrawReqController.selectAll)
router.put('/:id',withdrawReqController.update)
router.post('/historyAll',withdrawReqController.getDataHistory)
router.post('/insert',withdrawReqController.insert)
module.exports = router 
