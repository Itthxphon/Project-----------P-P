const models = require('../models/index')


exports.selectAll = async(req,res,next) => {

    const sql ="select * from sys_warehouse where f_wareStatus='1' "
    const inventory = await models.sequelize.query(sql,{
        type: models.sequelize.QueryTypes.SELECT
    })

    return res.status(200).json({
        data:inventory
    })

}