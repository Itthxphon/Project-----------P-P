'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class DeliveryJob_WithDetail extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  DeliveryJob_WithDetail.init({
    F_withID: {
      type: DataTypes.STRING,
      primaryKey:false,
      allowNull:false
    },
    f_withDate: DataTypes.DATE,
    F_docDeliveryID:DataTypes.STRING,
    F_docJobDeliveryID:DataTypes.STRING,
    F_docDeliveryDate:DataTypes.STRING,
    F_deliveryDateSchdule:DataTypes.STRING,
    F_carRegistration:DataTypes.STRING,
    F_docDeliveryStatus:DataTypes.INTEGER,
    F_docJobStatus:DataTypes.INTEGER,
    F_deliveryStep:DataTypes.INTEGER,
    f_prodID:DataTypes.STRING,
    f_prodName:DataTypes.STRING,
    f_withQty:DataTypes.INTEGER,
    f_index:DataTypes.INTEGER,
    f_Confirm:DataTypes.INTEGER,
    f_shippingCheck:DataTypes.INTEGER,
    f_withWithdrawer:DataTypes.STRING,
    f_wareID:DataTypes.STRING,
    f_wareName:DataTypes.STRING,
    f_withRemark:DataTypes.STRING
  }, {
    sequelize,
    modelName: 'DeliveryJob_WithDetail',
    tableName: 'view_DeliveryJob_WithDetail_Product',
    timestamps:false
    
  });
  return DeliveryJob_WithDetail;
};