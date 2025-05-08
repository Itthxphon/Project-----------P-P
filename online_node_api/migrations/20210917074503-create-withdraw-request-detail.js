'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('WithdrawRequestDetails', {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },
      f_withReqID: {
        type: Sequelize.STRING
      },
      f_prodID: {
        type: Sequelize.STRING
      },
      f_withReqQty: {
        type: Sequelize.DOUBLE
      },
      f_index: {
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
    await queryInterface.dropTable('WithdrawRequestDetails');
  }
};