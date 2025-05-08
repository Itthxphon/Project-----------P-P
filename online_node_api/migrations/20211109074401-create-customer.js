'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('Customers', {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },
      f_cusID: {
        type: Sequelize.STRING
      },
      f_cusName: {
        type: Sequelize.STRING
      },
      f_cusDetail: {
        type: Sequelize.STRING
      },
      f_cusStatus: {
        type: Sequelize.INTEGER
      },
      f_cusNo: {
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
    await queryInterface.dropTable('Customers');
  }
};