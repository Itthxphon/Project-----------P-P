'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class view_DeliveryJob extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  view_DeliveryJob.init({
    F_docJobDeliveryID: {
      type:DataTypes.STRING,primaryKey:true,allowNull:false
    },
    F_docDeliveryID: DataTypes.STRING,
    F_docDeliveryDate: DataTypes.DATE,
    F_deliveryDateSchdule: DataTypes.DATE,
    F_docDeliveryStatus: DataTypes.STRING,
    F_withID:DataTypes.STRING,
    F_deliveryStep:DataTypes.INTEGER,
    F_deliveryDate:DataTypes.DATE,
    F_docJobStatus:DataTypes.INTEGER,
    F_carID:DataTypes.STRING,
    F_carRegistration:DataTypes.STRING,
    F_carDetail:DataTypes.STRING,
    F_carStatus:DataTypes.INTEGER

  }, {
    sequelize,
    modelName: 'view_DeliveryJob',
    tableName:'view_DeliveryJob',
    timestamps:false
  });
  return view_DeliveryJob;
};