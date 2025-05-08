const models = require('../models/index')
const bcryptjt =  require('bcryptjs')



exports.index = async(req, res, next) => {

 // const users = await models.User.findAll()
  //  const users = await models.User.findAll({
  //    attributes:['id','name','email'], // เป็นการเลือกข้อมูลมาแค่ columns ที่ต้องการ 
  //    order :[['id','desc']] //  order :[['id','desc'],['name','desc']]
  //  })

  // const users = await models.User.findAll({
  //   attributes:{exclude:['password']}, // เอาทุก field ยกเว้น password 
  //   where:{
  //     email:'marry@gmail.com'
  //   } ,
  //   order :[['id','desc']] //  order :[['id','desc'],['name','desc']]
  // })

  // const users = await models.User.findAll({
  //   attributes:['id','name',['email','username']], // email as username 
  //   order :[['id','desc']] //  order :[['id','desc'],['name','desc']]
  // })

  // join table
 // const users = await models.User.findAll({
    //    attributes:['id','name','email'], // เป็นการเลือกข้อมูลมาแค่ columns ที่ต้องการ 
    //    include:[{ model :models.Blog,as:'blogs',attributes:['id','name'] }]
    //    order :[['id','desc'],['blogs','id','name']] //  order :[['id','desc'],['name','desc']]
    //  })
  
  const sql = 'select id,name,email,f_created_at from tb_user order by id desc '
  const users = await models.sequelize.query(sql,{
    type:models.sequelize.QueryTypes.SELECT
  })
   return res.status(200).json({
      data:users
    })
}

exports.show = async(req, res, next) => {

  //  const id= req.params.id // รับค่า id ที่มาจาก client
  try {
    const { id } = req.params //แบบนี้ก็หมายความว่าอนาคตเราอาจจะใส่ค่าอื่นมาแล้ว destructgering เข้าตัวแปร id ได้เลย 

    const user = await models.User.findByPk(id,{
      attributes:{exclude :['password']}
    })

    if (!user){ // ถ้าไม่พบ user นี้จะเป็นการ throw error ออกไป เข้า catch 
      const error = new Error('ไม่พบผู้ใช้ในระบบ');
      error.statusCode = 404 ;
      throw error;
    }
    res.status(200).json({
      data:user
    })
  } catch (error) {
    res.status(error.statusCode).json({
      error:{
        message:error.message
      }
    })
  }

}

  exports.insert = async(req, res, next) => {
    //  const id= req.params.id // รับค่า id ที่มาจาก client
    try {      
      const { name ,email ,password } = req.body

        // hash password 
        const salt = await bcryptjt.genSalt(8) //เข้ารหัสผ่าน 8 หลัก 
        const passwordHash = await bcryptjt.hash(password,salt)  //ถ้าแบบนี้จะเป็นการเข้ารหัส password ที่รับเข้ามา  // ถ้าเปรียบเทียบจะใช้ bcryptjs.compare 
  
    //check email ซ้ำ 
    const existEmail = await models.User.findOne({where : { email : email }}) //เป็นการ where column email ในตาราง = email ที่ส่งมา 
    if(existEmail){
      const error = new Error('มีผู้ใช้ email นี้ในระบบแล้วกรุณาใช้ email ใหม่');
      error.statusCode = 400 ;
      throw error;
    }

  
      const user = await models.User.create({
        name: name, // ซ้ายคือ column ในฐานข้อมูล ขวาคือสิ่งที่เรา get มาจาก req.body 
        email: email,
        password: passwordHash
      })

      return res.status(201).json({
        message:'เพิ่มข้อมูลสำเร็จ',
        data:{
          id : user.id, // เป็นการโชว์ข้อมูลล่าสุดที่พึี้่งทำการเพิ่มเข้าไปใน database 
          email :user.email
        }
      })
  
    } catch (error) {
      res.status(error.statusCode).json({
        error:{
          message:error.message
        }
      })
    }
  
}

 exports.update = async(req, res, next) => {

  //  const id= req.params.id // รับค่า id ที่มาจาก client
  try {

    const { id, name ,email ,password } = req.body

    if(req.params.id !== id){
      const error = new Error('รหัสผู้ใช้งานไม่ถูกต้อง');
      error.statusCode = 404 ;
      throw error;
    }

    const salt = await bcryptjt.genSalt(8) //เข้ารหัสผ่าน 8 หลัก 
    const passwordHash = await bcryptjt.hash(password,salt)  //ถ้าแบบนี้จะเป็นการเข้ารหัส password ที่รับเข้ามา  // ถ้าเปรียบเทียบจะใช้ bcryptjs.compare 


    const user = await models.User.update({
      name: name, // ซ้ายคือ column ในฐานข้อมูล ขวาคือสิ่งที่เรา get มาจาก req.body 
      email: email,
      password: passwordHash
    },{
      where :{
        id:id
      }
    })


    return res.status(201).json({
      message:'แก้ไขข้อมูลสำเร็จ',
     
    })

  } catch (error) {
    res.status(error.statusCode).json({
      error:{
        message:error.message
      }
    })
  }

}

exports.destroy = async(req, res, next) => {

  //  const id= req.params.id // รับค่า id ที่มาจาก client
  try {


    const { id } = req.params //แบบนี้ก็หมายความว่าอนาคตเราอาจจะใส่ค่าอื่นมาแล้ว destructgering เข้าตัวแปร id ได้เลย 

    const user = await models.User.findByPk(id)

    if (!user){ // ถ้าไม่พบ user นี้จะเป็นการ throw error ออกไป เข้า catch 
      const error = new Error('ไม่พบผู้ใช้ในระบบ');
      error.statusCode = 404 ;
      throw error;
    }

    //delete user by id 
    await models.User.destroy({
      where:{
        id:id 
      }
    })

 
    return res.status(201).json({
      message:'ลบข้อมูลสำเร็จ',
     
    })

  } catch (error) {
    res.status(error.statusCode).json({
      error:{
        message:error.message
      }
    })
  }

}

exports.searchAll = async(req,res,next) => {

  const {id} = req.params
  const sql = 'select * from sys_users where f_userID=' + id
  const users = await models.sequelize.query(sql,{
    type:models.sequelize.QueryTypes.SELECT
  })

   return res.status(200).json({
      data:users
    })

}

exports.login = async(req,res,next) => {

 // console.log(req.body);
  const { username,password } = req.body
  const user = await models.User.findAll({
    where: {
      f_username: username,
      f_password: password
    }
  })
  const sql = 'select * from Setting_Main'
  const setting = await models.sequelize.query(sql,
    {
    type:models.sequelize.QueryTypes.SELECT
  })
  const transformedSettings = setting.map(setting => {
    const transformedSetting = {};
    for (const [key, value] of Object.entries(setting)) {
      transformedSetting[key] = typeof value === 'number' ? value.toString() : value;
    }
    return transformedSetting;
  });
  return res.status(200).json({
    data: user,
    setting: transformedSettings
  })

}
