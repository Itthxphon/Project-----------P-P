'use strict';
const {
  Model, STRING
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Product extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      //  Product.belongsTO(models.ReceiveDetail,{as:'receiveDetail',
      //  FOREIGNKEYS: 'f_prodID' ,
      //  sourceKey: 'f_prodID' })
    }
  };
  Product.init({
    f_prodID: { 
      type: DataTypes.STRING(255),
      unique:true,
      allowNull:false
     },
    f_prodName: DataTypes.STRING(200),
    f_prodCate:DataTypes.STRING,
    f_unitNo:DataTypes.INTEGER,
    f_prodRemark:DataTypes.STRING,
    f_prodStatus:DataTypes.INTEGER,
    f_costprice:DataTypes.DOUBLE,
    f_max:DataTypes.INTEGER,
    f_min:DataTypes.INTEGER,
    f_minmaxStatus:DataTypes.INTEGER,
    f_picImage:DataTypes.BLOB,
    f_serial:DataTypes.INTEGER,
    f_brandID:DataTypes.INTEGER,
    f_DateRegister:DataTypes.DATE,
    f_Barcode:DataTypes.STRING,
    f_Package:DataTypes.STRING,
    f_Age:DataTypes.INTEGER
  }, {
    sequelize,
    modelName: 'Product',
    tableName: 'sys_products',
    timestamps:false
  });
  return Product;
};