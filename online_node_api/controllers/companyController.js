exports.index = (req, res, next) => {
    res.status(200).json({
       data:{
           name:'Nippo Tech',
           address :{
               province : 'Bangkok',
           }
       }
    })
  }