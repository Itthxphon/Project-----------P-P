'use strict';
const {
  Model
} = require('sequelize');
//const { FOREIGNKEYS } = require('sequelize/types/lib/query-types');
module.exports = (sequelize, DataTypes) => {
  class User extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {//สำหรับใช้ในการ Join table 
      // define association here

      // เขียนที่ USER
      // models.User.hasMany(models.Blog,{
        // as:'blogs',
        // FOREIGNKEYS:'user_id' FK blogs table
        // sourceKey:'id' // PK ของ User table
      //})

    
      //เขียนที่ BLOG
      //models.Blog.belongsTO(models.User,{as:'user',
       // FOREIGNKEYS:'id' FK blogs table
        // sourceKey:'user_id' // PK ของ User table})
    }
  };
  User.init({
    f_userID: { 
      type: DataTypes.STRING(200),
      primaryKey:true,
      unique:true,
      allowNull:false
     },
    f_username:  DataTypes.STRING(200),   
    f_password: DataTypes.STRING(200),
    f_group_user_id:DataTypes.STRING(200),
    f_userStatus: DataTypes.INTEGER,
    f_fullname:DataTypes.STRING(200),

    // f_created_at: {
    //   type: DataTypes.DATE,
    //   defaultValue: sequelize.fn('getdate')
    // }
  }, {
    sequelize,
    modelName: 'User',
    tableName: 'sys_users',// map เข้ากับ ชื่อ table 
    timestamps: false // close crateap and update at

  });
  return User;
};
