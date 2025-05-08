const express = require('express')
const router = express.Router()
const withdrawDetailController = require('../controllers/withdrawDetailController')

router.post('/',withdrawDetailController.insert)
router.get('/:id',withdrawDetailController.getDatabyID)
router.put('/',withdrawDetailController.confirmwithdraw)
module.exports = router 