const models = require('../models/index')
const Sequelize = require('sequelize')

exports.selectAll = async(req,res,next) => {

    const { id } = req.params

    var sql = "select trans_withdrawReqDetail.f_withReqID,trans_withdrawReqDetail.f_prodID,f_withReqQty,f_index,f_prodName, f_Barcode, QTY from trans_withdrawReqDetail"
    sql = sql + " left join trans_withdrawReqHead on trans_withdrawReqDetail.f_withReqID = trans_withdrawReqHead.f_withReqID "
    sql = sql + " left join view_stockBalanceWH on view_stockBalanceWH.f_prodID = trans_withdrawReqDetail.f_prodID and view_stockBalanceWH.f_wareID =  trans_withdrawReqHead.f_wareID "
    sql = sql + " where trans_withdrawReqDetail.f_withReqID = '" +id + "'"  

    const withdrawRequestDetail = await models.sequelize.query(sql,{
        type:models.sequelize.QueryTypes.SELECT
    })

    return res.status(200).json({
        data:withdrawRequestDetail
    })
}

exports.insert = async(req,res,next) => {

    const {
        f_withReqID,
        f_prodID,
        f_withReqQty
    } = req.body    


    const withdraw = await models.WithdrawRequestDetail.create({  
        f_withReqID:f_withReqID,
        f_prodID:f_prodID,
        f_withReqQty: f_withReqQty
    })

    return res.status(200).json({
        message:'เพิ่มข้อมูลสำเร็จ'
    })

}