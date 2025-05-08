const models = require('../models/index')
let moments = require('moment')
const Sequelize = require('sequelize')


exports.insert = async(req,res,next) => {

    const {
        f_withID,
        f_prodID,
        f_withQty
    } = req.body

    Sequelize.DATE.prototype._stringify = function _stringify(date, options) {
        return this._applyTimezone(date, options).format('YYYY-MM-DD HH:mm:ss.SSS');
      };

    const withdrawDetail = await models.WithdrawDetail.create({

        f_withID:f_withID,
        f_prodID:f_prodID,
        f_withQty:f_withQty

    })
    return res.status(200).json({
        message:'เพิ่มข้อมูลสำเร็จ'
    })

}


exports.getDatabyID = async(req,res,next) => { 

    const {id} = req.params
    var sql = "select trans_withdrawDetail.*,sys_products.f_prodName from trans_withdrawDetail " 
    sql = sql + " left join sys_products on sys_products.f_prodID = trans_withdrawDetail.f_prodID "
    sql = sql + " where f_withID=" + id
    const withDrawDetail = await models.sequelize.query(sql,{
        type:models.sequelize.QueryTypes.SELECT
    })

    return res.status(200).json({
        data:withDrawDetail
    })


}

exports.confirmwithdraw = async(req,res,next) => { 

    const { f_withID,f_prodID,f_Confirm } = req.body
    var sql = "update trans_withdrawDetail set f_Confirm ='"+ f_Confirm + "' "
    sql = sql + " where f_withID='"+ f_withID +"' and f_prodID ='"+ f_prodID +"'"

    const withdrawConfirm = await models.sequelize.query(sql,{
        type:models.sequelize.QueryTypes.UPDATE
    })

    return res.status(200).json({
        message: 'อัพเดทข้อมูลเรียบร้อย'
    })

}