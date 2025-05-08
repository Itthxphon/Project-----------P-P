const models = require('../models/index')
const Sequelize = require('sequelize')



exports.insertDetail = async(req,res,index) =>{

    const {f_recvID,f_prodID,f_recvQty,f_recvCost} = req.body

    console.log(req.body)

    Sequelize.DATE.prototype._stringify = function _stringify(date, options) {
        return this._applyTimezone(date, options).format('YYYY-MM-DD HH:mm:ss.SSS');
      };
  
    const receiveDetail = await models.ReceiveDetail.create({
        f_recvID:f_recvID,
        f_prodID:f_prodID,
        f_recvQty:f_recvQty,
        f_recvCost:f_recvCost,     
    })

    return res.status(201).json({
        message:'เพิ่มข้อมูลสำเร็จ'
    })

}


exports.getDetailByid = async(req,res,next) => {

    const {id} = req.params
    var sql = "select trans_receiveDetail.*,trans_receiveHead.f_wareID,sys_products.f_prodName,sys_warehouse.f_wareName,sys_supplier.f_supName "
    sql = sql + "from trans_receiveDetail "
    sql = sql + "left join sys_products  on sys_products.f_prodID = trans_receiveDetail.f_prodID "
    sql = sql + "left join trans_receiveHead on trans_receiveHead.f_recvID = trans_receiveDetail.f_recvID "
    sql = sql + "left join sys_warehouse on sys_warehouse.f_wareID = trans_receiveHead.f_wareID "
    sql = sql + "left join sys_supplier on sys_supplier.f_supID = trans_receiveHead.f_supID "
    sql = sql + "where trans_receiveHead.f_recvID= " + id 
        

    const recDetail = await models.sequelize.query(sql,{
        type:models.sequelize.QueryTypes.SELECT,
        
    })

    // const {id} = req.params
    // const recDetail = await models.ReceiveDetail.findAll({
    //     include:[{
    //         models:'Product' ,as:'products'}]
    // })
    
    return res.status(200).json({
        data:recDetail
    })
}