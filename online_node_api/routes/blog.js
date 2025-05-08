const express = require('express');
const router = express.Router();
const blogController = require('../controllers/blogController')

/* GET users listing. */
// http://localhost:3000/users/
router.get('/', blogController.index);



// http://localhost:3000/users/login
router.get('/login',blogController.login);


module.exports = router;
