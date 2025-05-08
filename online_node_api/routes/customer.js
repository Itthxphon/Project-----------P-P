const express = require('express')
const router = express.Router()
const cusotmerController = require('../controllers/customerController')

router.get('/',cusotmerController.selectAll)

module.exports = router 
