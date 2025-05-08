'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Car extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  Car.init({
    F_carID: {
      type:DataTypes.STRING,
      primaryKey:true,
      allowNull:false
    },
    F_carRegistration: DataTypes.STRING,
    F_carDetail: DataTypes.STRING,
    F_carStatus: DataTypes.INTEGER
  }, {
    sequelize,
    modelName: 'Car',
    tableName: 'sys_car',
    timestamps:false
  });
  return Car;
};