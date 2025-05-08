'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class StockBalance extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  StockBalance.init({
    f_prodID: {
      type:DataTypes.STRING,
      primaryKey:true,
      unique:true,
      allowNull:false
    },
    f_prodName: DataTypes.STRING,
    f_cateID:DataTypes.STRING,
    f_cateName:DataTypes.STRING,
    f_prodRemark:DataTypes.STRING,
    QTY:DataTypes.INTEGER,
    borrow_qty:DataTypes.INTEGER,
    f_max:DataTypes.INTEGER,
    f_min:DataTypes.INTEGER,
    f_prodCate:DataTypes.STRING,
    f_unitNo:DataTypes.STRING,
    f_unitName:DataTypes.STRING
  }, {
    sequelize,
    modelName: 'StockBalance',
    tableName: 'view_stockbalance',
    timestamps:false
  });
  return StockBalance;
};