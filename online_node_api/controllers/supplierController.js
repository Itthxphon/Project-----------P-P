const models = require('../models/index')
const Sequelize  = require('sequelize')

exports.selectAll = async(req,res,next) => {

  const sql = "select * from sys_supplier where f_supStatus='1' "
  const supplier = await models.sequelize.query(sql,{
      type:models.sequelize.QueryTypes.SELECT
  })

  return res.status(200).json({
      data:supplier
  })

}