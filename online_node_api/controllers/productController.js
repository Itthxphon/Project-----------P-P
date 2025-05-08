const models = require('../models/index')

exports.searchProductByID = async (req, res, next) => {

  const { prodID, wareID } = req.params
  const sql = "select * from sys_products left join sys_unit on sys_unit.f_unitNo = sys_products.f_unitNo left join sys_whlocate on sys_whlocate.f_prodID = sys_products.f_prodID where f_Barcode = " + prodID + " and f_wareID= " + wareID
  const products = await models.sequelize.query(sql, {
    type: models.sequelize.QueryTypes.SELECT
  })

  return res.status(200).json({
    data: products
  })
}

exports.searchProductByIDandwarehouseID = async (req, res, next) => {
  try {
    const { prodID, wareID } = req.params;
    const sql = "select * from view_stockBalanceWH where f_Barcode=" + prodID + " and f_wareID= " + wareID + " "
    const products = await models.sequelize.query(sql, {
      type: models.sequelize.QueryTypes.SELECT
    })
    return res.status(200).json({
      data: products
    })
  }
  catch (error) {
    console.error(error)
    res.status(403).send("Client Error")
  }
}

