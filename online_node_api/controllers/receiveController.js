const models = require('../models/index')
let moments = require('moment')
const Sequelize = require('sequelize');
const  validator = require('validator')


exports.insert = async(req, res, next) => {

   const {f_recvID,
    f_recvdate,
    f_recvRemark,
    f_recvStatus,
    f_recvReceiver,
    f_recvReferance,
    f_recvReferanceDate,
    f_wareID, 
    f_supID } = req.body

    Sequelize.DATE.prototype._stringify = function _stringify(date, options) {
        return this._applyTimezone(date, options).format('YYYY-MM-DD HH:mm:ss.SSS');
      };
  
 

    const receive = await models.Receive.create({    
        f_recvID:f_recvID,
        f_recvdate: moments.utc(moments(f_recvdate).format("YYYY-MM-DD HH:mm:ss")),
        f_recvRemark:f_recvRemark,
        f_recvStatus:f_recvStatus,
        f_recvReceiver:f_recvReceiver,
        f_recvReferance:f_recvReferance,
        f_recvReferanceDate: f_recvReferanceDate =='' ? null : moments.utc(moments(f_recvReferanceDate).format("YYYY-MM-DD HH:mm:ss")),
        f_wareID:f_wareID,
        f_supID:f_supID
    })
    return res.status(200).json({
        message: 'เพิ่มข้อมูลสำเร็จ'
    })

}

exports.searchTop = async(req,res,next) => {
 
    const sql = "select top 1 f_recvID  from trans_receiveHead order by f_recvID desc " ;
    const receiveID = await models.sequelize.query(sql, { 
        type: models.sequelize.QueryTypes.SELECT
     })

    return res.status(200).json({
      data: receiveID
    })

}

exports.getDataAll = async(req,res,next) => { 

    const sql = "select * from trans_receiveHead where f_recvStatus ='1' and f_recvDate >= DATEADD(dd,-45,cast(getdate() as date )) order by f_recvID desc ";
    const receiveDoc = await models.sequelize.query(sql,{
        type: models.sequelize.QueryTypes.SELECT
    })

    return res.status(200).json({
        data: receiveDoc
    })
}


exports.getDataByid = async(req,res,next) => { 

    const {id} = req.params
    var sql = "select * from trans_receiveHead "
    sql = sql + "left join sys_warehouse on sys_warehouse.f_wareID = trans_receiveHead.f_wareID "
    sql = sql + "left join sys_supplier on sys_supplier.f_supID = trans_receiveHead.f_supID "
    sql = sql + "where f_recvID = " + id
    const receiveDoc = await models.sequelize.query(sql,{
       type:models.sequelize.QueryTypes.SELECT
    })          
    return res.status(200).json({
        data:receiveDoc
     })


}

exports.getDataHistory = async(req,res,next) => { 


    const { f_recvID,f_dateStart,f_dateEnd ,f_recvStatus } = req.body

        var sql = "select * from trans_receiveHead "
        sql = sql + "left join sys_warehouse on sys_warehouse.f_wareID = trans_receiveHead.f_wareID "
        sql = sql + "left join sys_supplier on sys_supplier.f_supID = trans_receiveHead.f_supID "


        if (f_dateStart != '' && f_dateEnd != '' && f_recvID != '' && f_recvStatus != ''){

            sql = sql + "where f_recvID like '%" + f_recvID + "%'  and f_recvStatus = '"+ f_recvStatus +"'"

        }else if(f_recvID == '' ){

            sql = sql + "where ( f_recvDate >= '" + f_dateStart + "' and f_recvDate <= '" + f_dateEnd + "' ) and f_recvStatus = '"+ f_recvStatus +"'"

        }else {

            sql = sql + "where f_recvID like '%" + f_recvID + "%' and f_recvStatus = '"+ f_recvStatus +"'"
        }

        sql = sql + " order by f_recvID desc "
       
        const receiveDoc = await models.sequelize.query(sql,{
           type:models.sequelize.QueryTypes.SELECT
        })   

        return res.status(200).json({
           data:receiveDoc
        })
    

}