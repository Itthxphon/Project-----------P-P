const express = require('express');
const path = require('path');
const cookieParser = require('cookie-parser');
const logger = require('morgan');

const indexRouter = require('./routes/index');
const usersRouter = require('./routes/users');
const companyRouter = require('./routes/company')
const serverRouter = require ('./routes/server')
const blogRouter = require('./routes/blog')
const productRouter = require('./routes/product')
const receiveRouter = require('./routes/receive')
const receiveDetailController = require('./routes/receiveDetail')
const inventoryController = require('./routes/inventory')
const withdrawController = require('./routes/withdraw')
const withdrawDetailController = require ('./routes/withdrawDetail')
const withdrawReqController = require('./routes/withdrawReqHead')
const withdrawReqDetailController = require('./routes/withdrawReqDetail')
const supplierController = require('./routes/supplier')
const stockbalanceController = require('./routes/stockbalance')
const cusotmerController = require('./routes/customer')
const deliveryJobController = require('./routes/view_DeliveryJob')
const JobWithDetailController = require('./routes/jobwithdetail')
const carController = require('./routes/car')

const app = express();

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));


app.use('/', indexRouter);
app.use('/api/users', usersRouter);
app.use('/api/company',companyRouter)
app.use('/api/server',serverRouter)
app.use('/api/blog',blogRouter)
app.use('/api/product',productRouter)
app.use('/api/receive',receiveRouter)
app.use('/api/receivedetail',receiveDetailController)
app.use('/api/inventory',inventoryController)
app.use('/api/withdraw',withdrawController)
app.use('/api/withdrawdetail',withdrawDetailController)
app.use('/api/withdrawReq',withdrawReqController)
app.use('/api/withdrawReqDetail',withdrawReqDetailController)
app.use('/api/supplier',supplierController)
app.use('/api/stockbalance',stockbalanceController)
app.use('/api/customer',cusotmerController)
app.use('/api/deliveryJob',deliveryJobController)
app.use('/api/jobwithdetail',JobWithDetailController)
app.use('/api/getCar',carController)

module.exports = app;
console.log("Ready");