'use strict';
const {
  Model
} = require('sequelize');

const Product = require("./product.js");

module.exports = (sequelize, DataTypes) => {
  class ReceiveDetail extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // models.ReceiveDetail.hasOne(models.Product,{
      //   as:'product',
      //    FOREIGNKEYS: 'f_prodID',
      //    sourceKey: 'f_prodID' 
      // })
    }
  };
  ReceiveDetail.init({

    f_recvID: {
      type:DataTypes.STRING,
      primaryKey:true,
      unique:true,
      allowNull:false
    },
    f_prodID: {
      type:DataTypes.STRING,
      
    },
    f_recvQty: DataTypes.FLOAT,
    f_recvCost: DataTypes.FLOAT,
 
  }, {
    sequelize,
    modelName: 'ReceiveDetail',
    tableName: 'trans_receiveDetail',
    timestamps:false
  });

  //ReceiveDetail.hasOne(Product.default, { as: 'Product', foreignKey: 'f_prodID' });
  return ReceiveDetail;

  
};



