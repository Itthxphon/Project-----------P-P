var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  //res.render('index', { title: 'Express' });
    res.status(200).json({
      message:'Hello world'
    })
});

module.exports = router;
