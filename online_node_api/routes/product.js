const express = require('express')
const router = express.Router()
const productController = require('../controllers/productController')

router.get('/search/:prodID/:wareID',productController.searchProductByID)
router.get('/:prodID/:wareID',productController.searchProductByIDandwarehouseID)
// router.get('/search', productController.searchProductByIDandwarehouseID);

module.exports = router