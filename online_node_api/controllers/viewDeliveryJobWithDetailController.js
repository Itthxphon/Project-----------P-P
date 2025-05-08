const models = require('../models/index')
let moment = require('moment')
const Sequelize = require('sequelize')


exports.getDataByJobID = async (req,res,next) => {


    const { id } = req.params
    const sql = "select * from view_DeliveryJob_WithDetail_Product where F_docJobDeliveryID='"+id+"'"
    const JobDeliveryData = await models.sequelize.query(sql,{
        type:models.sequelize.QueryTypes.SELECT
    })

    return res.status(200).json({
        data:JobDeliveryData
    })

}



exports.getDataSuccessHistory = async(req,res,next) => {

    const { id } = req.params
    const sql = "select * from view_DeliveryJob_Success_WithDetail_Product where F_docJobDeliveryID='"+id+"'"
    const JobDeliveryData = await models.sequelize.query(sql,{
        type:models.sequelize.QueryTypes.SELECT
    })

    return res.status(200).json({
        data:JobDeliveryData
    })



}