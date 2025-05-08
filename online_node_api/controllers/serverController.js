
const sql = require("mssql");
const config = {
    user: 'sa',
    password: '@Admin1132',
    port:8021,
    server: 'nippomobileapi.ddns.net', 
    database: 'Stock_BrownA00419' ,
    options: {          
        trustedConnection: true,
        encrypt: false
    }
 
};

exports.connects = function (req, res,next) {
   
 
    // config for your database
   

    // connect to your database
    sql.connect(config, function (err) {
        
        if (err) console.log(err);

        // create Request object
        const request = new sql.Request();
           
        // query to the database and get the records
        request.query('select * from sys_users', function (err, datauser) {
            
            if (err) console.log(err)
           // res.status(200)
            // send records as a respons
           res.json(datauser);

            
        });

      
    });
}



exports.connserver = (req,res,next)=>{

    sql.connect(config, function (err) {
       const request = new sql.Request()
       const dataarr  = new Array()

        request.query("select * from sys_users where f_username = 'admin' ",function (err,recordset) {
           
         //   dataarr.push({'data':recordset.recordset[0]})

            res.json(recordset.recordset[0])
        })
    })
  
}

