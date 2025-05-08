'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('Inventories', {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },
      f_wareID: {
        type: Sequelize.STRING
      },
      f_wareName: {
        type: Sequelize.STRING
      },
      f_wareRemark: {
        type: Sequelize.STRING
      },
      f_wareStatus: {
        type: Sequelize.INTEGER
      },
      f_whID: {
        type: Sequelize.INTEGER
      },
      createdAt: {
        allowNull: false,
        type: Sequelize.DATE
      },
      updatedAt: {
        allowNull: false,
        type: Sequelize.DATE
      }
    });
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('Inventories');
  }
};