'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Receive extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  };
  Receive.init({
    f_recvID:{ 
      type: DataTypes.STRING(200),
      primaryKey: true,
      unique:true,
      allowNull:false
     },
    f_recvdate: {
       type: DataTypes.DATE, 
    
    }, 
    f_recvRemark:DataTypes.STRING,
    f_recvStatus:DataTypes.INTEGER,
    f_recvReceiver:DataTypes.STRING,
    f_recvReferance:DataTypes.STRING,
    f_recvReferanceDate:{
      type: DataTypes.DATE,     
    
    },
    f_wareID:DataTypes.STRING,
    f_supID:DataTypes.STRING
  }, {
    sequelize,
    modelName: 'Receive',
    tableName: 'trans_receiveHead',
    timestamps:false
  });
  return Receive;
};
