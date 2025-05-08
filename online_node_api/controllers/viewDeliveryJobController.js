const models = require('../models/index')
let moment = require('moment')
const Sequelize = require('sequelize')


exports.getDataAll = async(req,res,next) => {

    const sql = "select * from view_DeliveryJob"
    const deliveryJob = await models.sequelize.query(sql,{
        type:models.sequelize.QueryTypes.SELECT
    })

    return res.status(200).json({
        data:deliveryJob
    })
}

exports.getDataByID = async(req,res,next) => {

    const { F_docJobDeliveryID,F_carID } = req.body
    const sql = "select * from view_DeliveryJob where F_docJobDeliveryID like '%"+ F_docJobDeliveryID +"%' and F_carID='"+F_carID+"'"
    const deliveryJob = await models.sequelize.query(sql,{
        type:models.sequelize.QueryTypes.SELECT
    })

    return res.status(200).json({
        data:deliveryJob
    })

}

// exports.getDataByIDHistory = async(req,res,next) => {

//     const { F_docJobDeliveryID,F_carID } = req.body
//     const sql = "select * from view_DeliveryJob_Success where F_docJobDeliveryID like '%"+ F_docJobDeliveryID +"%' and F_carID='"+F_carID+"'"
//     const deliveryJob = await models.sequelize.query(sql,{
//         type:models.sequelize.QueryTypes.SELECT
//     })

//     return res.status(200).json({
//         data:deliveryJob
//     })

// }


exports.updateJob = async(req,res,next) => { 

    const {F_docJobDeliveryID} = req.params
    const sql = "update view_DeliveryJob set F_deliveryStep='2' where F_docJobDeliveryID='"+F_docJobDeliveryID+"'"
    const deliveryJob = await models.sequelize.query(sql,{
        type:models.sequelize.QueryTypes.UPDATE
    })

    return res.status(200).json({
        data:'อัพเดทข้อมูลเรียบร้อย'
    })


}

exports.getDataJobDeliverySuccess = async(req,res,next) => {


    const {F_docJobDeliveryID,f_dateStart,f_dateEnd,F_carID} = req.body
    var sql = "select * from view_DeliveryJob_Success "

    if(F_docJobDeliveryID !='' && f_dateStart != '' && f_dateEnd != ''){
        sql = sql + " where F_docJobDeliveryID like '%"+ F_docJobDeliveryID +"%'" 
    }else if(F_docJobDeliveryID == ''){
        sql = sql + " where ( F_docDeliveryDate >= '"+ f_dateStart +"' and F_docDeliveryDate <= '"+ f_dateEnd +"') and F_carID ='"+F_carID+"'"
    }

   sql = sql + " order by F_docJobDeliveryID desc"

    const deliveryJob = await models.sequelize.query(sql,{
        type:models.sequelize.QueryTypes.SELECT
    })

    return res.status(200).json({
        data:deliveryJob
    })


}


exports.getDatJobSuccessAll = async(req,res,next) => {

    const sql = "select * from view_DeliveryJob_Success where F_docDeliveryDate >= DATEADD(dd,-45,cast(getdate() as date )) order by F_docJobDeliveryID desc "
    const deliveryJob = await models.sequelize.query(sql,{
        type:models.sequelize.QueryTypes.SELECT
    })

    return res.status(200).json({
        data:deliveryJob
    })

}