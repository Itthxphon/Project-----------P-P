const models = require('../models/index')
let moments = require('moment')
const Sequelize = require('sequelize')



exports.insert = async(req,res,next) =>{
    const {
        f_withID,
        f_withDate,
        f_withRemark,
        f_withStatus,
        f_withWithdrawer,
        f_withReferance,
        f_withReferanceDate,
        f_withTo,
        f_wareID,
        f_withReq,
        f_isArrive,
        f_arriveDate

    } = req.body

    Sequelize.DATE.prototype._stringify = function _stringify(date, options) {
        return this._applyTimezone(date, options).format('YYYY-MM-DD HH:mm:ss.SSS');
      };


    const withdraw = await models.Withdraw.create({
        f_withID:f_withID,
        f_withDate: moments.utc(moments(f_withDate).format("YYYY-MM-DD HH:mm:ss")),
        f_withRemark:f_withRemark,
        f_withStatus:f_withStatus,
        f_withWithdrawer:f_withWithdrawer,
        f_withReferance:f_withReferance,
        f_withReferanceDate: f_withReferanceDate == '' ? null : moments.utc(moments(f_withReferanceDate).format("YYYY-MM-DD HH:mm:ss")),
        f_withTo:f_withTo ,
        f_wareID:f_wareID,
        f_withReq:f_withReq == '' ? null : f_withReq,
        f_isArrive:f_isArrive,
        f_arriveDate:f_arriveDate == '' ? null : moments.utc(moments(f_arriveDate).format("YYYY-MM-DD HH:mm:ss"))
    })
    return res.status(200).json({
        message:'เพิ่มข้อมูลสำเร็จ'
    })

}

exports.searchTop = async(req,res,next) => {

    const sql = "select top 1 f_withID from trans_withdrawHead order by f_withID desc ";
    const withdrawID = await models.sequelize.query(sql,{
        type:models.sequelize.QueryTypes.SELECT
    })

    return res.status(200).json({
        data:withdrawID
    })

}

exports.getHistoryAll = async(req,res,next) => {

    const sql = "select * from trans_withdrawHead where f_withStatus='1' and f_withDate >= DATEADD(dd,-45,cast(getdate() as date )) order by f_withID desc ";
    const withDraw = await models.sequelize.query(sql,{
        type:models.sequelize.QueryTypes.SELECT
    })

    return res.status(200).json({
        data:withDraw
    })
}

exports.getbyID = async(req,res,next) => {

    const { id } = req.params
    var sql = "select * from trans_withdrawHead "
    sql = sql + " left join sys_warehouse on sys_warehouse.f_wareID = trans_withdrawHead.f_wareID "
    sql = sql + " left join sys_customer on sys_customer.f_cusID = trans_withdrawHead.f_withTo"
    sql = sql +  " where f_withID=" + id
    const withDraw = await models.sequelize.query(sql,{
        type:models.sequelize.QueryTypes.SELECT
    })

    return res.status(200).json({
        data:withDraw
    })
}

exports.getDataHistory = async(req,res,next) => {


    const {f_withID,f_dateStart,f_dateEnd ,f_withStatus} = req.body

    var sql = "select * from trans_withdrawHead "
    sql = sql + " left join sys_warehouse on sys_warehouse.f_wareID = trans_withdrawHead.f_wareID "


    if (f_dateStart != '' && f_dateEnd != '' && f_withID != ''){

        sql = sql + "where f_withID like '%" + f_withID + "%'  and f_withStatus = '"+ f_withStatus +"'"

    }else if(f_withID == '' ){

        sql = sql + "where ( f_withDate >= '" + f_dateStart + "' and f_withDate <= '" + f_dateEnd + "' ) and f_withStatus = '"+ f_withStatus +"'"

    }else {

        sql = sql + "where f_withID like '%" + f_withID + "%' and f_withStatus = '"+ f_withStatus +"'"
    }

    sql = sql + " order by f_withID desc "
   
    const withdrawDoc = await models.sequelize.query(sql,{
       type:models.sequelize.QueryTypes.SELECT
    })   

    return res.status(200).json({
       data:withdrawDoc
    })
}

exports.getDataHistoryAllCheck = async(req,res,next) => {


    const {f_withID,f_dateStart,f_dateEnd ,f_shippingCheck} = req.body

    var sql = "select * from trans_withdrawHead "
    sql = sql + " left join sys_warehouse on sys_warehouse.f_wareID = trans_withdrawHead.f_wareID "


    if (f_dateStart != '' && f_dateEnd != '' && f_withID != '' && f_shippingCheck != ''){

        sql = sql + "where f_withID like '%" + f_withID + "%'  and f_withStatus = '1' and f_shippingCheck = '"+ f_shippingCheck +"'"

    }else if (f_withID == '' && f_shippingCheck == '0'){

        sql = sql + "where ( f_withDate >= '" + f_dateStart + "' and f_withDate <= '" + f_dateEnd + "' ) and f_withStatus = '1' and   f_shippingCheck is null "

    }else if(f_withID == '' && f_shippingCheck == '1'){

        sql = sql + "where ( f_withDate >= '" + f_dateStart + "' and f_withDate <= '" + f_dateEnd + "' ) and f_withStatus = '1' and   f_shippingCheck = '"+ f_shippingCheck +"' "

    }else {

        sql = sql + "where f_withID like '%" + f_withID + "%' and f_withStatus = '1' and f_shippingCheck is null "
    }

    
    sql = sql + " and f_withDate >= DATEADD(dd,-45,cast(getdate() as date )) "
    sql = sql + " order by f_withID desc "
   
    const withdrawDoc = await models.sequelize.query(sql,{
       type:models.sequelize.QueryTypes.SELECT
    })   

    return res.status(200).json({
       data:withdrawDoc
    })
}

exports.getbyship = async(req,res,next) => {

    const sql = "select * from trans_withdrawHead where f_withStatus='1' and f_shippingCheck is null  and f_withDate >= DATEADD(dd,-45,cast(getdate() as date )) order by f_withID desc ";
    const ship = await models.sequelize.query(sql,{type:models.sequelize.QueryTypes.SELECT})
    return res.status(200).json({
        data:ship
    })
}

exports.getbyshipSuccess = async(req,res,next) => {

    const sql = "select * from trans_withdrawHead where f_withStatus='1' and f_shippingCheck ='1' and f_finishShipping is null   and f_withDate >= DATEADD(dd,-45,cast(getdate() as date )) order by f_withID desc ";
    const ship = await models.sequelize.query(sql,{type:models.sequelize.QueryTypes.SELECT})
    return res.status(200).json({
        data:ship
    })
}

exports.updateShipSuccess = async(req,res,next) => {

    const { f_withID,f_shippingCheck } = req.body
    var sql = "update trans_withdrawHead set f_shippingCheck ='"+ f_shippingCheck + "' "
    sql = sql + " where f_withID='"+ f_withID +"'"

    const withdrawConfirm = await models.sequelize.query(sql,{
        type:models.sequelize.QueryTypes.UPDATE
    })

    return res.status(200).json({
        message: 'อัพเดทข้อมูลเรียบร้อย'
    })

}

exports.getdoFinishShipping = async(req,res,next) => {

    const sql = "select * from trans_withdrawHead where f_finishShipping is null and f_shippingCheck = '1'  and f_withDate >= DATEADD(dd,-45,cast(getdate() as date )) order by f_withID desc ";
    const ship = await models.sequelize.query(sql,{type:models.sequelize.QueryTypes.SELECT})
    return res.status(200).json({
        data:ship
    })
}

exports.updateFinishShipping = async(req,res,next) => {

    const { f_withID,f_finishShipping } = req.body
    var sql = "update trans_withdrawHead set f_finishShipping ='"+ f_finishShipping + "' "
    sql = sql + " where f_withID='"+ f_withID +"'"

    const withdrawConfirm = await models.sequelize.query(sql,{
        type:models.sequelize.QueryTypes.UPDATE
    })

    return res.status(200).json({
        message: 'อัพเดทข้อมูลเรียบร้อย'
    })

}


