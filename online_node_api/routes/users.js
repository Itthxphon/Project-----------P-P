const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController')

/* GET users listing. */
// http://localhost:3000/users/
router.post('/', userController.login);

// // http://localhost:3000/users/login
// router.get('/login',userController.login );


router.get('/:id',userController.searchAll) // เป็นการส่ง parameter ที่เป็น Id เข้าไป 

router.post('/',userController.insert)


// router.put('/:id',userController.update)

// router.delete('/:id',userController.destroy)

module.exports = router;
