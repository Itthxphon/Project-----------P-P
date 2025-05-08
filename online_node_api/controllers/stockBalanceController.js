const models = require('../models/index')
const Sequelize = require('sequelize')

exports.getData = async(req,res,next) => {

    try{const sql = "select * from view_stockbalance";
    const stock = await models.sequelize.query(sql,{
        type: models.sequelize.QueryTypes.SELECT  
    })

    return res.status(200).json({
        data: stock
    })}
    catch(error){  
            console.error(error);
            res.status(500).send('Internal Server Error');    
    }
    
}

exports.getDataBywareID = async(req,res,next) => {
    try{const {wareID} = req.params
    const sql = "select * from view_stockBalanceWH where f_wareID =" + wareID
    const stock = await models.sequelize.query(sql,{
        type:models.sequelize.QueryTypes.SELECT
    })
    return res.status(200).json({
        data:stock
    })}
    catch(error){
        console.error(error);
        res.status(500).send('Internal Server Error');
    }
}

exports.getImageID = async(req,res,next)=>{
try {
    const {ID} = req.params
    const sql = "select f_picImage,f_prodID from View_SysProducts where f_prodID ="+ID
    const stock = await models.sequelize.query(sql,{
        type:models.sequelize.QueryTypes.SELECT
    })
    return res.status(200).json({
        data:stock
    })
} catch (error) {
    console.error(error);
        res.status(500).send('Internal Server Error');
}
}

// exports.getDataByID = async(req,res,next) => {
//     const {id} = req.params
//     const sql = "select * from view_stockbalance where f_prodID like '%" + id + "%'"
//     const stock = await models.sequelize.query(sql,{
//         type:models.sequelize.QueryTypes.SELECT
//     })
//     return res.status(200).json({
//         data:stock
//     })
// }


// exports.getDataByID = async(req,res,next) => {
//     const {id} = req.params
//     const {wareID} = req.params
//     var sql;
//     if(wareID==null){
//         sql = "select * from view_stockbalance where f_prodID like '%" + id + "%'"
//     }
//     else{
//         sql =  "select * from view_stockbalanceWH where f_prodID like '%" + id + "%' and f_wareID =" + wareID
//     }
//     const stock = await models.sequelize.query(sql,{
//         type:models.sequelize.QueryTypes.SELECT
//     })
//     return res.status(200).json({
//         data:stock
//     })
// }