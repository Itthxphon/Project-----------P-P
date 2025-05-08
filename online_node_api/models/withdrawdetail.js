'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class WithdrawDetail extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  WithdrawDetail.init({
    f_withID: {
      type:DataTypes.STRING,
      primaryKey:true,
    },
    f_prodID: DataTypes.STRING,
    f_withQty: DataTypes.DOUBLE
  }, {
    sequelize,
    modelName: 'WithdrawDetail',
    tableName: 'trans_withdrawDetail',
    timestamps:false
  });
  return WithdrawDetail;
};