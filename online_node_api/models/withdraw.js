'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Withdraw extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  Withdraw.init({
    f_withID: {
      type: DataTypes.STRING,
      primaryKey:true,
      unique:true,
      allowNull:false
    },
    f_withDate:{
      type:DataTypes.DATE
    },
    f_withRemark:DataTypes.STRING,
    f_withStatus:DataTypes.INTEGER,
    f_withRemark:DataTypes.INTEGER,
    f_withWithdrawer:DataTypes.STRING,
    f_withReferance:DataTypes.STRING,
    f_withReferanceDate:{
      type:DataTypes.DATE
    },
    f_withTo:DataTypes.STRING,
    f_wareID:DataTypes.STRING,
    f_withReq:DataTypes.STRING,
    f_isArrive:DataTypes.INTEGER,
    f_arriveDate:{
      type:DataTypes.DATE
    },
    //f_shippingCheck:DataTypes.INTEGER,
    //f_finishShipping:DataTypes.INTEGER

  }, {
    sequelize,
    modelName: 'Withdraw',
    tableName: 'trans_withdrawHead',
    timestamps:false

  });
  return Withdraw;
};