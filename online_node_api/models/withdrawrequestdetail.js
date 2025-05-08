'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class WithdrawRequestDetail extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  WithdrawRequestDetail.init({
    f_withReqID: {
      type:DataTypes.STRING,
      primaryKey:true
    },
    f_prodID: DataTypes.STRING,
    f_withReqQty: DataTypes.DOUBLE,
    f_index: DataTypes.INTEGER
  }, {
    sequelize,
    modelName: 'WithdrawRequestDetail',
    tableName: 'trans_withdrawReqDetail',
    timestamps:false
  });
  return WithdrawRequestDetail;
};