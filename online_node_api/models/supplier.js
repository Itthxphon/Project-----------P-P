'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Supplier extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  Supplier.init({
    f_supID: {
      type: DataTypes.STRING(200),
      primaryKey:true,
      allowNull:false,
      unique:true
    },
    f_supName: DataTypes.STRING,
    f_supDetail: DataTypes.STRING,
    f_supStatus: DataTypes.INTEGER
  }, {
    sequelize,
    modelName: 'Supplier',
    tableName: 'sys_supplier',
    timestamps: false
  });
  return Supplier;
};