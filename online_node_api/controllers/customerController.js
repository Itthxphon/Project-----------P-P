const models = require('../models/index')

exports.selectAll = async(req,res,next) => {

    const sql ="select * from sys_customer where f_cusStatus ='1' "
    const customer = await models.sequelize.query(sql,{
        type: models.sequelize.QueryTypes.SELECT
    })

    return res.status(200).json({
        data:customer 
    })
}