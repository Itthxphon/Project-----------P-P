exports.index = (req, res, next) => {
    res.send('Hello blog');
  }


exports.login = function(req, res, next) {
    res.send('Hello blog login');
  }