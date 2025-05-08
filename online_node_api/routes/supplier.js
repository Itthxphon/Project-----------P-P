const express = require('express')
const router = express.Router()
const supplierController = require('../controllers/supplierController')

router.get('/',supplierController.selectAll)
module.exports = router