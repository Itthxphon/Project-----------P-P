'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Customer extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  Customer.init({
    f_cusID: {
      type:DataTypes.STRING,
      primaryKey:true,
      allowNull:false
    },
    f_cusName: DataTypes.STRING,
    f_cusDetail: DataTypes.STRING,
    f_cusStatus: DataTypes.INTEGER,
    f_cusNo: DataTypes.INTEGER
  }, {
    sequelize,
    modelName: 'Customer',
    tableName: 'sys_customer',
    timestamps:false
  });
  return Customer;
};