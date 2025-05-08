'use strict';
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('view_DeliveryJobs', {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },
      F_docJobDeliveryID: {
        type: Sequelize.STRING
      },
      F_docDeliveryID: {
        type: Sequelize.STRING
      },
      F_docDeliveryDate: {
        type: Sequelize.DATE
      },
      F_deliveryDateSchdule: {
        type: Sequelize.DATE
      },
      F_carID: {
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
    await queryInterface.dropTable('view_DeliveryJobs');
  }
};