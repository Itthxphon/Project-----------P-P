const express = require('express')
const router = express.Router()
const withdrawReqDetailController = require('../controllers/withdrawRequestDetailController')

router.get('/:id',withdrawReqDetailController.selectAll)
router.post('/insert',withdrawReqDetailController.insert)

module.exports = router 