const express = require('express');
const router = express.Router();
const serverController = require('../controllers/serverController')

/* GET users listing. */
// http://localhost:3000/users/
router.get('/', serverController.connserver);



module.exports = router;
