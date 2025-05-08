'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class WithdrawRequest extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  WithdrawRequest.init({
    f_withReqID: {
      type:DataTypes.STRING,
      primaryKey:true,
    },
    f_withReqDate:{
      type:DataTypes.DATE
    },
    f_withReqRemark:DataTypes.STRING,
    f_withReqStatus:DataTypes.INTEGER,
    f_withReqWithdrawerID:DataTypes.INTEGER,
    f_withReqWithdrawer:DataTypes.STRING,
    f_withReqReferance:DataTypes.STRING,
    f_withReqReferanceDate:DataTypes.DATE,
    f_withReqTo:DataTypes.STRING,
    f_wareID:DataTypes.STRING,
    f_needDelivery:DataTypes.INTEGER

  },{
    sequelize,
    modelName: 'WithdrawRequest',
    tableName: 'trans_withdrawReqHead',
    timestamps:false
  });
  return WithdrawRequest;
};