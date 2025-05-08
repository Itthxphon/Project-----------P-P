const express = require('express');
const router = express.Router();
const companyController = require('../controllers/companyController')

/* GET users listing. */
// http://localhost:3000/users/
router.get('/', companyController.index);



module.exports = router;
