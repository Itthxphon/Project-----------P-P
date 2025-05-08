const models = require('../models/index')

exports.getCarActive = async(req,res,next) =>{

    const sql = "select * from sys_car where F_carStatus='1'"
    const dataCar = await models.sequelize.query(sql,{
        type:models.sequelize.QueryTypes.SELECT
    })

    return res.status(200).json({
        data:dataCar
    })
}