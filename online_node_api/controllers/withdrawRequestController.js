const models= require('../models/index')
let moments = require('moment')
const Sequelize = require('sequelize')

// select ตามเลขที่ใบขอเบิก 
exports.selectAll = async(req,res,next) => {

    const { id } = req.params
    var sql = "select * from trans_withdrawReqHead "
    sql = sql + "left join sys_warehouse on sys_warehouse.f_wareID = trans_withdrawReqHead.f_wareID "
    sql = sql + "left join sys_customer on f_cusID = trans_withdrawReqHead.f_withReqTo "
    sql = sql + "where f_withReqID=" + id 
    //f_withReqStatus='1' and
    const withdrawReq = await models.sequelize.query(sql,{
        type:models.sequelize.QueryTypes.SELECT
    })

    return res.status(200).json({
        data: withdrawReq
    })

}

// Load data ตามช่วงวันที่
exports.getDataHistory = async(req,res,next) => {


   const {f_withReqID,f_dateStart,f_dateEnd,f_withReqStatus} = req.body
 
  
  var sql = "select * from trans_withdrawReqHead "
  
  if (f_dateStart != '' && f_dateEnd != '' && f_withReqID != '' && f_withReqStatus != ''){

      sql = sql + "where f_withReqID like '%" + f_withReqID + "%'  and f_withReqStatus = '"+ f_withReqStatus +"'"

  }else if(f_withReqID == '' ){

      sql = sql + "where ( f_withReqDate >= '" + f_dateStart + "' and f_withReqDate <= '" + f_dateEnd + "' ) and f_withReqStatus = '"+ f_withReqStatus +"'"

  }else {

      sql = sql + "where f_withReqID like '%" + f_withReqID + "%' and f_withReqStatus = '"+ f_withReqStatus +"'"
  }

  sql = sql + " order by f_withReqID desc "


  const withdraw = await models.sequelize.query(sql,{
      type:models.sequelize.QueryTypes.SELECT
  })

  return res.status(200).json({
      data:withdraw
  })
}

// 45 วันล่าสุด
exports.showAll = async(req,res,next) => {

 //   const {f_withReqID,f_dateStart,f_dateEnd,f_withReqStatus} = req.body
 
  
  var sql = "select * from trans_withdrawReqHead "
  sql = sql + " where f_withReqStatus ='1' and  f_withReqDate >= DATEADD(dd,-45,cast(getdate() as date )) order by f_withReqID desc "
 
 
    const withdraw = await models.sequelize.query(sql,{
        type:models.sequelize.QueryTypes.SELECT
    })

    return res.status(200).json({
        data:withdraw
    })
    
}

// update Status เบิกของแล้ว 
exports.update = async(req,res,next) => { 

    const {id} = req.params

    var sql = "update trans_withdrawReqHead set f_withReqStatus='2' where f_withReqID=" + id
    const updateWithdrawReq = await models.sequelize.query(sql,{
        type:models.sequelize.QueryTypes.UPDATE
    })

    // const withdrawReq = await models.WithdrawReq.update({
    //     f_withReqStatus: '2'
    // },{
    //     where:{
    //         f_withReqID:id
    //     }
    // })


    return res.status(200).json({
        message: 'อัพเดทข้อมูลเรียบร้อย'
    })

}

// select top เลขที่เอกสารล่าสุด 
exports.searchTop = async(req,res,next) => {

    const sql = "select top 1 f_withReqID  from trans_withdrawReqHead order by f_withReqID desc " ;
    const withReqID = await models.sequelize.query(sql, { 
        type: models.sequelize.QueryTypes.SELECT
     })

    return res.status(200).json({
      data: withReqID
    })


}

// insert withdraw Req Head 
exports.insert = async(req,res,nex) => {
    const {

        f_withReqID,
        f_withReqDate,
        f_withReqRemark,
        f_withReqStatus,
        f_withReqWithdrawerID,
        f_withReqWithdrawer,
        f_withReqReferance,
        f_withReqReferanceDate,
        f_withReqTo,
        f_wareID,
        f_needDelivery

    } = req.body


    //console.log(f_withReqWithdrawerID)
    
    Sequelize.DATE.prototype._stringify = function _stringify(date, options) {
        return this._applyTimezone(date, options).format('YYYY-MM-DD HH:mm:ss.SSS');
      };

      var refDate
      if ( f_withReqReferanceDate == '' ){
      refDate  = null
      }else {
         refDate =f_withReqReferanceDate
      }

      console.log(refDate)
 
    const withdrawReq = await models.WithdrawRequest.create({

         f_withReqID:f_withReqID,
         f_withReqDate:moments.utc(moments(f_withReqDate).format("YYYY-MM-DD HH:mm:ss")),
         f_withReqRemark:f_withReqRemark,
         f_withReqStatus:f_withReqStatus,
         f_withReqWithdrawerID: f_withReqWithdrawerID,
         f_withReqWithdrawer:f_withReqWithdrawer,
         f_withReqReferance:f_withReqReferance,
         f_withReqReferanceDate: refDate ,
         f_withReqTo:f_withReqTo,
         f_wareID:f_wareID,
         f_needDelivery:f_needDelivery,
      
    })
    return res.status(200).json({
        message:'เพิ่มข้อมูลสำเร็จ'
    })
}
