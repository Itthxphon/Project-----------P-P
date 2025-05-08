'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Inventory extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  Inventory.init({
    f_wareID: {
      type:DataTypes.STRING,
      primaryKey:true,
      allowNull: false
    },
    f_wareName: DataTypes.STRING,
    f_wareRemark: DataTypes.STRING,
    f_wareStatus: DataTypes.INTEGER,
    f_whID: DataTypes.INTEGER
  }, {
    sequelize,
    modelName: 'Inventory',
    tableName: 'sys_warehouse',
    timestamps:false
  });
  return Inventory;
};