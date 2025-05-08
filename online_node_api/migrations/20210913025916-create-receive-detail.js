'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('ReceiveDetails', {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },
      f_recvID: {
        type: Sequelize.STRING
      },
      f_prodID: {
        type: Sequelize.STRING
      },
      f_prodQTY: {
        type: Sequelize.FLOAT
      },
      f_amountPrice: {
        type: Sequelize.FLOAT
      },
      sale_index: {
        type: Sequelize.INTEGER
      },
      f_creditID: {
        type: Sequelize.STRING
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
    await queryInterface.dropTable('ReceiveDetails');
  }
};