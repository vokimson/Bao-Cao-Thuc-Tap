import pool from "../config/connectDB"

// đăng ký tài khoản
let signupUser = async (req,res) => {
  let {phone, password, fullname, role_name} = req.body;
    if ( !phone || !password || !fullname || !role_name) {
        return res.status(400).json({
            message: "Please complete all information"
        })
    }

    const [rows, fields] = await pool.execute('CALL SP_SIGNIN (?, ?, ?, ?)', [phone, password, fullname, role_name]);

    return res.status(200).json({
        message: 'ok',
        body: rows
    });
}


// let signupUser = async (req,res) => {
//     let {phone, password, fullname, role_name} = req.body;
//     if ( !phone || !password || !fullname) {
//         return res.status(400).json({
//             message: "Please complete all information"
//         })
//     }
    
    // thêm customer nếu đăng ký là khách hàng
    // if (getRoleId(role_name) === 4){
    //     await pool.execute('INSERT INTO customers (shopping_area) VALUES ("Hồ Chí Minh")')
    // }
    // let [rowsCusId] = await pool.execute('SELECT LAST_INSERT_ID() as customer_id')
    // const customer_id = rowsCusId[0].customer_id

    // // kiểm tra phone có tồn tại với quyền đang chọn hay không
    // const [userRows] = await pool.execute('SELECT * FROM users WHERE phone = ?', [phone])
    // if (userRows.length > 0) {
    //     const user_id = userRows[0].user_id

    //     const [roleRows] = await pool.execute('SELECT * FROM users_roles WHERE user_id = ? and role_id = ?', [user_id, getRoleId(role_name)])

    //     if (roleRows.length > 0) {
    //         return res.status(400).json({
    //             message: 'Phone already exists with this role',
    //             data: roleRows
    //         })
    //     } else {
    //         await addRoleToUser(getRoleId(role_name), user_id)
    //         return res.status(200).json({
    //             message: 'ok',
    //             data: user_id
    //         })
    //     }
    // }
    
    // try{
    //     // if (getRoleId(role_name) === 4){
    //     //     await pool.execute('INSERT INTO users ( phone, password, full_name, customer_id) VALUES (?, ?, ?, ?)', 
    //     //                 [ phone, password, fullname, customer_id])
    //     // }
    //     // else{
    //     //     await pool.execute('INSERT INTO users ( phone, password, full_name, customer_id) VALUES (?, ?, ?)', 
    //     //     [ phone, password, fullname])
    //     // }
        
    
    //     // let [rows, fields] = await pool.execute('SELECT LAST_INSERT_ID() as user_id')
    //     // const user_id = rows[0].user_id
    
    //     // await addRoleToUser(getRoleId(role_name), user_id)
    //     // return res.status(200).json({
    //     //     message: 'ok',
    //     //     data: rows
    //     // })
    // }catch(error){
    //     return res.status(500).json({
    //         message: 'Internal Server Error',
    //         error: error.message
    //       });
    // }
    
// }

// let getRoleId = (roleName) => {
//     if (!roleName || roleName === 'customer') {
//         return 4
//     } else if (roleName === 'admin') {
//         return 1
//     } else if (roleName === 'staff') {
//         return 2
//     } else if (roleName === 'shipper') {
//         return 3
//     }
// }

// let addRoleToUser = async (roleId, userId) => {
//     await pool.execute('INSERT INTO users_roles (role_id, user_id) VALUES (?, ?)', [roleId, userId]);
// }

// đăng nhập
let loginUser = async (req,res) => {
    let {phone, password} = req.query;
    if(!phone || !password){
      return res.status(400).json({
        message: "Please complete all information"
      })
    }
    const [userRows, userFields] = await pool.execute('SELECT u.user_id, r.role_name FROM users u INNER JOIN users_roles ur ON u.user_id = ur.user_id INNER JOIN role r ON ur.role_id = r.role_id WHERE u.phone = ? AND u.password = ?', 
                [phone, password]);
    if (userRows.length === 0) {
        return res.status(404).json({
            message: 'Phone or password is incorrect'
        })
    } 
    // else if (userRows.length > 0){
    //     const [roleRows, roleFields] = await pool.execute('select role_id from role_user where user_id = ?', 
    //                 [userRows[0].user_id]);
    //     if (roleRows.length >= 2) {
    //         return res.status(200).json({
    //             message: 'select role',
    //             roles: roleRows
    //         });
    //     }
    // }
    let roleNames = userRows.map((row) => row.role_name);
    return res.status(200).json({
        message: 'ok',
        body: {
            phone: phone,
            password: password,
            user_id: userRows[0].user_id,
            role_name: roleNames

        }
    })
}

// đổi mật khẩu
let changePassword = async (req,res) => {
    let {user_id, password} = req.body;
    await pool.execute('UPDATE users SET password = ? WHERE user_id = ?', [password, user_id]);

    return res.status(200).json({
        message: 'ok'
    })
}

// tạo đơn đặt hàng
var check1 = true;
let createOrder = async (req,res) => {
    let {user_id, product_id} = req.body;
    
    if ( !user_id || !product_id) {
        return res.status(400).json({
            message: 'Bad Request'
        })
    }

    try{
      let [rows, fields1] = await pool.execute('CALL create_order(?, ?)', [user_id, product_id])
      return res.status(200).json({
            message: 'ok',
            body: rows
          })
      // if (check1){
      //   await pool.execute('INSERT INTO orders (user_id) VALUES (?)',
      //           [user_id]);
      //   let [rowsOdId, fields1] = await pool.execute('SELECT LAST_INSERT_ID() as order_id')
      //   const order_id = rowsOdId[0].order_id
        
      //   const [priceRows, priceFields] = await pool.execute('INSERT INTO orders_product (order_id, product_id) VALUES (?,?)',
      //   [order_id, product_id]);
        
      //   check1 = false;
      //   return res.status(200).json({
      //     message: 'ok',
      //   })
      // }
    }catch (error) {
        return res.status(500).json({
          message: 'Internal Server Error',
          error: error.message
        });
      }
}

// thêm sản phẩm vào đơn hàng
let addProductToOrder = async (req,res) => {
    let {order_id, product_id} = req.body;
    if ( !order_id || !product_id) {
        return res.status(400).json({
            message: 'Bad Request'
        })
    }
    try{
        const [rows] = await pool.execute('SELECT * FROM orders_product WHERE product_id = ? AND order_id = ? ', [product_id, order_id]);
        if (Array.isArray(rows) && rows.length === 0){
            const [priceRows, priceFields] = await pool.execute('INSERT INTO orders_product (order_id, product_id) VALUES (?,?)',
                 [order_id, product_id]);
    
            return res.status(200).json({
                message: 'ok'
            })
        }
        else{
            const [updateRows, updateFields] = await pool.execute('UPDATE orders_product SET quantity = quantity + 1 WHERE product_id = ? AND order_id = ?', [product_id, order_id]);

            return res.status(200).json({
            message: 'ok'
            });
        }
    }catch (error) {
        return res.status(500).json({
          message: 'Internal Server Error',
          error: error.message
        });
      }
    
    
}
            

// lấy thông tin tất cả customer
let getAllCustomer = async (req,res) => {
    const [rows, fields] = await pool.execute('SELECT u.*, tax_code FROM users u INNER JOIN customers c ON u.customer_id = c.customer_id ORDER BY user_id DESC')

    return res.status(200).json({
        message: 'ok',
        body: rows
    })
}

// lấy thông tin tất cả admin
let getAllAdmin = async (req,res) => {
  const [rows, fields] = await pool.execute('SELECT u.* FROM users u INNER JOIN users_roles ur ON u.user_id = ur.user_id INNER JOIN role r ON r.role_id=ur.role_id WHERE role_name = "ADMIN" ORDER BY user_id DESC')

  return res.status(200).json({
      message: 'ok',
      body: rows
  })
}


// lấy tất cả sản phẩm
let getAllProduct = async (req,res) => {
    const [rows, fields] = await pool.execute('SELECT p.*, price, manufacturer_name FROM product p INNER JOIN (SELECT product_id, MAX(applicable_date) applicable_date FROM pricelist_product GROUP BY product_id ) last_price ON last_price.product_id = p.product_id INNER JOIN pricelist_product pp ON last_price.product_id = pp.product_id AND last_price.applicable_date = pp.applicable_date INNER JOIN pricelist pl ON pl.price_id = pp.price_id JOIN manufacturer m ON m.manufacturer_id = p.manufacturer_id ORDER BY p.product_id;');

    return res.status(200).json({
        message: 'ok',
        data: rows
    })
}



// lấy sản phẩm theo id
let getProductById = async (req,res) => {
    let {product_id} = req.query;
    if(!product_id){
        return res.status(400).json({
            message: 'Bad request'
        })
    }
    try {
        const [rows, fields] = await pool.execute(`SELECT p.*, price, manufacturer_name, vendor_name FROM pricelist pl INNER JOIN products_prices pp ON pp.pricelist_id = pl.pricelist_id INNER JOIN products p ON p.product_id = pp.product_id INNER JOIN manufacturer m ON m.manufacturer_id = p.manufacturer_id INNER JOIN vendor v ON p.vendor_id = v.vendor_id WHERE p.product_id = ? AND type = "X"`,                                        
        [product_id]);

        return res.status(200).json({
            message: 'ok',
            body: rows
        })
    }catch (error) {
        return res.status(500).json({
          message: 'Internal Server Error',
          error: error.message
        });
      }
}


// lấy thông tin sản phẩm bằng tên sp
let getProductByName = async (req,res) => {
    let{area,product_name}  = req.query
    const [rows, fields] = await pool.execute(`SELECT p.* FROM products p INNER JOIN products_warehouse pw ON p.product_id=pw.product_id INNER JOIN warehouse w ON pw.warehouse_id=w.warehouse_id WHERE area = ? AND name LIKE ? ORDER BY create_date DESC`, 
            [ area,`%${product_name}%`]);
    return res.status(200).json({
        message: 'ok',
        body: rows
    })
}

// lấy thông tin sản phẩm bằng tên nhà chế tạo
// let getProductByManufacturer = async (req,res) => {
//     const manufacturer_name = req.params.manufacturer_name
//     const [rows, fields] = await pool.execute(`SELECT p.*, price, manufacturer_name FROM product p INNER JOIN (SELECT product_id, MAX(applicable_date) applicable_date FROM pricelist_product GROUP BY product_id ) last_price ON last_price.product_id = p.product_id INNER JOIN pricelist_product pp ON last_price.product_id = pp.product_id AND last_price.applicable_date = pp.applicable_date INNER JOIN pricelist pl ON pl.price_id = pp.price_id JOIN manufacturer m ON m.manufacturer_id = p.manufacturer_id WHERE m.manufacturer_name LIKE ? ORDER BY p.product_id;`, 
//             [`%${manufacturer_name}%`]);

//     return res.status(200).json({
//         message: 'ok',
//         data: rows
//     })
// }

// cập nhật thông tin user
let user = {
  full_name: '',
  date_of_birth: null,
  phone: '',
  email: '',
  address: '',
  tax: ''
};
const updateUserInfo = async (req, res) => {
  let { user_id, full_name, date_of_birth, email, phone, address, tax } = req.body;

  if (!user_id || !full_name || !phone) {
      return res.status(400).json({
          message: 'ok'
      });
  }

  try {
      const [rows, fields] = await pool.execute(
          'CALL SP_UpdateUserInfo(?, ?, ?, ?, ?, ?);',
          [user_id, full_name, date_of_birth || null, phone, email || null, address || null]
      );

      if (tax !== null) {
          const [rows1, fields1] = await pool.execute(
              'UPDATE customers c INNER JOIN users u ON u.customer_id = c.customer_id SET tax_code = ? WHERE user_id = ?',
              [tax, user_id]
          );
      }

      return res.status(200).json({
          message: 'ok',
          user
      });
  } catch (error) {
      return res.status(500).json({
          message: 'Internal Server Error',
          error: error.message
      });
  }
};


let getListManufacturerWithProduct = async (req,res) => {
  let {shopping_area} = req.query;
  if( !shopping_area){
    return res.status(400).json({
        message: 'Bad Request'
      });
  }
    try {
        const [rows, fields] = await pool.execute('SELECT DISTINCT manufacturer_name from manufacturer m INNER JOIN products p ON m.manufacturer_id=p.manufacturer_id INNER JOIN products_warehouse pw ON p.product_id=pw.product_id INNER JOIN warehouse w ON pw.warehouse_id = w.warehouse_id WHERE area = ? ORDER BY manufacturer_name ASC',
        [shopping_area]);
    
        const manufacturerNames = rows.map(row => row.manufacturer_name);
    
        return res.status(200).json({
          message: 'ok',
          manufacturerNames: manufacturerNames
        });
      } catch (error) {
        return res.status(500).json({
          message: 'Internal Server Error',
          error: error.message
        });
      }
}

let getProductsOfManu = async (req,res) => {
    let {manufacturer_name, shopping_area} = req.query;
    if(!manufacturer_name || !shopping_area){
        return res.status(400).json({
            message: 'Bad Request'
          });
    }
    try {
        const [rows, fields] = await pool.execute('SELECT p.* FROM products p, manufacturer m, products_warehouse pw, warehouse w WHERE p.product_id = pw.product_id AND pw.warehouse_id=w.warehouse_id AND p.manufacturer_id=m.manufacturer_id AND manufacturer_name = ? AND area = ? ORDER BY create_date DESC', 
        [manufacturer_name, shopping_area]);
    
        return res.status(200).json({
          
          body: rows
        });
      } catch (error) {
        return res.status(500).json({
          message: 'Internal Server Error',
          error: error.message
        });
      }
}

let getPriceOfProduct = async (req,res) => {
    
    try {
        const [rows, fields] = await pool.execute('SELECT p.product_id, price FROM products p INNER JOIN products_prices pp ON p.product_id=pp.product_id INNER JOIN pricelist pl ON pp.pricelist_id=pl.pricelist_id WHERE type = "X" ORDER BY product_id ASC');
    
        return res.status(200).json({
          message: 'ok',
          body: rows
        });
      } catch (error) {
        return res.status(500).json({
          message: 'Internal Server Error',
          error: error.message
        });
      }
}

let getNewProducts = async (req,res) => {
  let {shopping_area} = req.query;
  if( !shopping_area){
    return res.status(400).json({
        message: 'Bad Request'
      });
}
    try {
        const [rows, fields] = await pool.execute('SELECT p.* FROM products p, products_warehouse pw, warehouse w WHERE area = ? AND create_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 6 MONTH) AND CURDATE() AND p.product_id = pw.product_id AND pw.warehouse_id=w.warehouse_id ORDER BY create_date DESC',
        [shopping_area]);
    
        return res.status(200).json({
          message: 'ok',
          body: rows
        });
      } catch (error) {
        return res.status(500).json({
          message: 'Internal Server Error',
          error: error.message
        });
      }
}

let getCartOfUser = async (req,res) => {
    let{user_id} = req.query
    if(!user_id){
        return res.status(400).json({
            message: 'Bad Request'
          });
    }
    try {
        const [rows, fields] = await pool.execute('SELECT o.order_id, p.product_id, name, price, quantity, tax_rate, picture FROM users u INNER JOIN orders o ON u.user_id=o.user_id INNER JOIN orders_product op ON o.order_id=op.order_id INNER JOIN products p ON op.product_id=p.product_id WHERE u.user_id = ? AND status = "processing"',
                    [user_id]);
    
        return res.status(200).json({
          message: 'ok',
          body: rows
        });
      } catch (error) {
        return res.status(500).json({
          message: 'Internal Server Error',
          error: error.message
        });
      }
}

let getDetailOrderById = async (req,res) => {
    let{order_id} = req.query
    if(!order_id){
        return res.status(400).json({
            message: 'Bad Request'
          });
    }
    try {
        const [rows, fields] = await pool.execute('SELECT o.order_id, p.product_id, name, price, quantity, tax_rate, picture FROM orders o INNER JOIN orders_product op ON o.order_id=op.order_id INNER JOIN products p ON op.product_id=p.product_id WHERE o.order_id = ?',
                    [order_id]);
    
        return res.status(200).json({
          message: 'ok',
          body: rows
        });
      } catch (error) {
        return res.status(500).json({
          message: 'Internal Server Error',
          error: error.message
        });
      }
}

let getTotalOfCart = async (req,res) => {
    let{order_id} = req.query
    if(!order_id){
        return res.status(400).json({
            message: 'Bad Request'
          });
    }
    try {
        const [rows, fields] = await pool.execute('SELECT order_id, total_amount, tax_amount FROM orders WHERE order_id = ?',
                    [order_id]);
    
        return res.status(200).json({
          message: 'ok',
          body: rows
        });
      } catch (error) {
        return res.status(500).json({
          message: 'Internal Server Error',
          error: error.message
        });
      }
}

let deleteProductOfCart = async (req,res) => {
    let{order_id, product_id} = req.query
    if(!order_id || !product_id){
        return res.status(400).json({
            message: 'Bad Request'
          });
    }

    try {
        const [rows, fields] = await pool.execute('DELETE FROM orders_product WHERE order_id = ? AND product_id = ?',
                    [order_id, product_id]);
    
        return res.status(200).json({
          message: 'ok'
        });
      } catch (error) {
        return res.status(500).json({
          message: 'Internal Server Error',
          error: error.message
        });
      }
}

let getInfoCustomerById = async (req,res) => {
    let{user_id} = req.query
    if(!user_id){
        return res.status(400).json({
            message: 'Bad Request'
          });
    }

    try {
        const [rows, fields] = await pool.execute('SELECT * FROM users u INNER JOIN customers c ON u.customer_id=c.customer_id WHERE user_id = ?',
                    [user_id]);
    
        return res.status(200).json({
          message: 'ok',
          body: rows
        });
      } catch (error) {
        return res.status(500).json({
          message: 'Internal Server Error',
          error: error.message
        });
      }
}

let getInfoUserById = async (req,res) => {
  let{user_id} = req.query
  if(!user_id){
      return res.status(400).json({
          message: 'Bad Request'
        });
  }

  try {
      const [rows, fields] = await pool.execute('SELECT * FROM users u WHERE user_id = ?',
                  [user_id]);
  
      return res.status(200).json({
        message: 'ok',
        body: rows
      });
    } catch (error) {
      return res.status(500).json({
        message: 'Internal Server Error',
        error: error.message
      });
    }
}

let getTaxOfCustomer = async (req,res) => {
    let{user_id} = req.query
    if(!user_id){
        return res.status(400).json({
            message: 'Bad Request'
          });
    }
    try {
        const [rows, fields] = await pool.execute('SELECT c.customer_id, tax_code FROM customers c INNER JOIN users u WHERE user_id = ? and c.customer_id=u.customer_id ',
                    [user_id]);
    
        return res.status(200).json({
          message: 'ok',
          body: rows
        });
      } catch (error) {
        return res.status(500).json({
          message: 'Internal Server Error',
          error: error.message
        });
      }
}

let updateQuantityProductOrder = async (req,res) => {
    let{order_id, product_id, quantity} = req.query

    if(!product_id || !order_id || !quantity){
        return res.status(400).json({
            message: 'Bad Request'
          });
    }

    try {
        const [rows, fields] = await pool.execute('UPDATE orders_product SET quantity = ? WHERE order_id = ? AND product_id = ?',
                    [quantity, order_id, product_id ]);
    
        return res.status(200).json({
          message: 'ok'
        });
      } catch (error) {
        return res.status(500).json({
          message: 'Internal Server Error',
          error: error.message
        });
      }
}

let updatePayOrder = async (req,res) => {
    let{pay_id, description, address, shopping_area, order_id} = req.body

    if(!pay_id || !order_id || !shopping_area){
        return res.status(400).json({
            message: 'Bad Request'
          });
    }

    try {
        const [rows, fields] = await pool.execute('UPDATE orders SET pay_id = ?, description = ?, address = ?, order_date = CURDATE(), status = "placed" , shopping_area = ? WHERE order_id = ?',
                    [pay_id, `${description}`, address, shopping_area, order_id]);
    
        return res.status(200).json({
          message: 'ok'
        });
      } catch (error) {
        return res.status(500).json({
          message: 'Internal Server Error',
          error: error.message
        });
      }
}


let getOrderProcessingOfUser = async (req,res) => {
    let{user_id} = req.query
    if (!user_id){
        return res.status(400).json({
            message: 'ok',
            body: rows
          });
    }
    try {
        const [rows, fields] = await pool.execute('SELECT order_id FROM orders WHERE status = "processing" AND user_id = ?',
         [user_id]);
        if (rows.length > 0){
            return res.status(200).json({
              message: 'ok',
              body: rows
            });

        }
        else if (Array.isArray(rows) && rows.length === 0){
            return res.status(404).json({
                message: 'Not Found',
                body: rows
              });
        }
      } catch (error) {
        return res.status(500).json({
          message: 'Internal Server Error',
          error: error.message
        });
      }
}

let getOrderOfUserWithStatus = async (req,res) => {
  let{user_id, status} = req.query
  if (!user_id || !status){
      return res.status(400).json({
          message: 'ok',
          body: rows
        });
  }
  try {
      const [rows, fields] = await pool.execute('CALL SP_GetOrderOfUserWithStatus(?, ?);',
                [user_id, status]);
      if (rows.length > 0){
          return res.status(200).json({
            message: 'ok',
            body: rows
          });

      }
      else if (Array.isArray(rows) && rows.length === 0){
          return res.status(404).json({
              message: 'Not Found',
              body: rows
            });
      }
    } catch (error) {
      return res.status(500).json({
        message: 'Internal Server Error',
        error: error.message
      });
    }
}

let getProductQuantityOfWarehouse = async (req, res) => {
  const { shopping_area } = req.query;
  if (!shopping_area ) {
    return res.status(400).json({
      message: 'Bad Request',
    });
  }
  try{
    const [rows, fields] = await pool.execute('SELECT p.product_id, quantity FROM products p INNER JOIN products_warehouse pw ON p.product_id=pw.product_id INNER JOIN warehouse w ON w.warehouse_id=pw.warehouse_id WHERE area = ? GROUP BY product_id', 
    [shopping_area]);
    if(rows.length > 0){
      return res.status(200).json({
        message: 'ok',
        body: rows
      })
    }
    else {
      return res.status(404).json({
        message: 'No data found',
      });
    }
  }catch (error) {
    console.error('Error executing query:', error);
      return res.status(500).json({
        message: 'Internal Server Error',
        error: error.message
      });
    }
}

let getProductQuantityById = async (req, res) => {
  let { shopping_area, product_id } = req.query
  try{
    const [rows, fields] = await pool.execute('SELECT SUM(quantity) AS quantity FROM products p INNER JOIN products_warehouse pw ON p.product_id=pw.product_id INNER JOIN warehouse w ON w.warehouse_id=pw.warehouse_id WHERE area = ? AND p.product_id = ? GROUP BY p.product_id',
             [shopping_area, product_id]);
    if(rows.length > 0){
      return res.status(200).json({
        message: 'ok',
        body: rows
      })
    }
    else {
      return res.status(404).json({
        message: 'No data found',
      });
    }
  }catch (error) {
    console.error('Error executing query:', error);
      return res.status(500).json({
        message: 'Internal Server Error',
        error: error.message
      });
    }
}

let getProductQuantityOfOrder = async (req, res) => {
  let { order_id } = req.query
  try{
    const [rows, fields] = await pool.execute('SELECT SUM(quantity) AS quantity FROM orders_product WHERE order_id = ?',
             [order_id]);
    if(rows.length > 0){
      return res.status(200).json({
        message: 'ok',
        body: rows
      })
    }
    else {
      return res.status(404).json({
        message: 'No data found',
      });
    }
  }catch (error) {
    console.error('Error executing query:', error);
      return res.status(500).json({
        message: 'Internal Server Error',
        error: error.message
      });
    }
}

let getAllAreaWarehouse = async (req, res) => {
  try{
    const [rows, fields] = await pool.execute('SELECT area FROM warehouse');
    if(rows.length > 0){
      return res.status(200).json({
        message: 'ok',
        body: rows
      })
    }
    else {
      return res.status(404).json({
        message: 'No data found',
      });
    }
  }catch (error) {
    console.error('Error executing query:', error);
      return res.status(500).json({
        message: 'Internal Server Error',
        error: error.message
      });
    }
}

let updateShoppingArea = async (req, res) => {
  const { shopping_area, customer_id } = req.body;
  if (!shopping_area || !customer_id) {
    return res.status(400).json({
      message: 'Bad Request',
    });
  }
  try {
    const [rows, fields] = await pool.execute(
      'UPDATE customers SET shopping_area = ? WHERE customer_id = ?',
      [`${shopping_area}`, customer_id]
    );

    return res.status(200).json({
      message: 'ok',
    });
  } catch (error) {
    console.error('Error executing query:', error);
    return res.status(500).json({
      message: 'Internal Server Error',
      error: error.message,
    });
  }
}

let getFirstLogin = async (req, res) => {
  const { customer_id } = req.query;
  if ( !customer_id) {
    return res.status(400).json({
      message: 'Bad Request',
    });
  }
  try {
    const [rows, fields] = await pool.execute(
      'SELECT first_login FROM customers WHERE customer_id = ?',
      [ customer_id]
    );

    return res.status(200).json({
      message: 'ok',
      body: rows
    });
  } catch (error) {
    console.error('Error executing query:', error);
    return res.status(500).json({
      message: 'Internal Server Error',
      error: error.message,
    });
  }
}

let updateFirstLogin = async (req, res) => {
  const { customer_id } = req.query;
  if ( !customer_id) {
    return res.status(400).json({
      message: 'Bad Request',
    });
  }
  try {
    const [rows, fields] = await pool.execute(
      'UPDATE customers SET first_login = 1 WHERE customer_id = ?',
      [ customer_id]
    );

    return res.status(200).json({
      message: 'ok',
    });
  } catch (error) {
    console.error('Error executing query:', error);
    return res.status(500).json({
      message: 'Internal Server Error',
      error: error.message,
    });
  }
}

let getShoppingAreaOfCustomer = async (req, res) => {
  const { customer_id } = req.query;
  if ( !customer_id) {
    return res.status(400).json({
      message: 'Bad Request',
    });
  }
  try {
    const [rows, fields] = await pool.execute(
      'SELECT shopping_area FROM customers WHERE customer_id = ?',
      [ customer_id]
    );

    return res.status(200).json({
      message: 'ok',
      body: rows
    });
  } catch (error) {
    console.error('Error executing query:', error);
    return res.status(500).json({
      message: 'Internal Server Error',
      error: error.message,
    });
  }
}

let getQuantityOfProductWithCart = async (req, res) => {
  let { order_id, product_id } = req.query;
  if ( !order_id || !product_id) {
    return res.status(400).json({
      message: 'Bad Request',
    });
  }
  try {
    const [rows, fields] = await pool.execute(
      'SELECT quantity FROM orders_product WHERE order_id = ? AND product_id = ?',
      [ order_id, product_id]
    );

    return res.status(200).json({
      message: 'ok',
      body: rows
    });
  } catch (error) {
    console.error('Error executing query:', error);
    return res.status(500).json({
      message: 'Internal Server Error',
      error: error.message,
    });
  }
}

let updateOrderConfirm = async (req, res) => {
  let { product_id, quantity, shopping_area } = req.body;
  if ( !quantity || !product_id || !shopping_area) {
    return res.status(400).json({
      message: 'Bad Request',
    });
  }
  try {
    const [rows, fields] = await pool.execute('CALL SP_UpdateOrderConfirm(?,?,?)',
      [ product_id, quantity, shopping_area ]);
    // const [rows, fields] = await pool.execute('UPDATE products_warehouse SET quantity = quantity - ? WHERE product_id = ? AND warehouse_id = ?',
    //   [ quantity, product_id, warehouse_id ]);

    return res.status(200).json({
      message: 'ok'
    });
  } catch (error) {
    console.error('Error executing query:', error);
    return res.status(500).json({
      message: 'Internal Server Error',
      error: error.message,
    });
  }
}

let getPayNameById = async (req, res) => {
  let { pay_id } = req.query;
  if ( !pay_id ) {
    return res.status(400).json({
      message: 'Bad Request',
    });
  }
  try {
    const [rows, fields] = await pool.execute(
      'SELECT pay_name FROM payment_method WHERE pay_id = ?',
      [ pay_id]
    );

    return res.status(200).json({
      message: 'ok',
      body: rows
    });
  } catch (error) {
    console.error('Error executing query:', error);
    return res.status(500).json({
      message: 'Internal Server Error',
      error: error.message,
    });
  }
}

let updateOrderStatus = async (req, res) => {
  let { user_id, order_id, status } = req.body;
  if ( !user_id || !order_id || !status) {
    return res.status(400).json({
      message: 'Bad Request',
    });
  }
  try {
    const [rows, fields] = await pool.execute('CALL SP_UpdateOrderStatus(?,?,?);',
      [ user_id, order_id, status ]);

    return res.status(200).json({
      message: 'ok'
    });
  } catch (error) {
    console.error('Error executing query:', error);
    return res.status(500).json({
      message: 'Internal Server Error',
      error: error.message,
    });
  }
}

let updateCancelOrder = async (req, res) => {
  let { order_id, product_id, quantity } = req.body;
  if ( !quantity || !product_id || !order_id) {
    return res.status(400).json({
      message: 'Bad Request',
    });
  }
  try {
    const [rows, fields] = await pool.execute('CALL SP_CancelOrder(?,?,?)',
      [ order_id, product_id, quantity ]);

    return res.status(200).json({
      message: 'ok'
    });
  } catch (error) {
    console.error('Error executing query:', error);
    return res.status(500).json({
      message: 'Internal Server Error',
      error: error.message,
    });
  }
}

let getUserByName = async (req, res) => {
  let { full_name } = req.query;
  if ( !full_name ) {
    return res.status(400).json({
      message: 'Bad Request',
    });
  }
  try {
    const [rows, fields] = await pool.execute(
      'SELECT * FROM users u LEFT JOIN customers c ON c.customer_id=u.customer_id WHERE full_name LIKE ? OR u.phone LIKE ? ORDER BY user_id DESC',
      [ `%${full_name}%`, `%${full_name}%`]
    );

    return res.status(200).json({
      message: 'ok',
      body: rows
    });
  } catch (error) {
    console.error('Error executing query:', error);
    return res.status(500).json({
      message: 'Internal Server Error',
      error: error.message,
    });
  }
}

let user1 = {
  phone: '',
  full_name: '',
  date_of_birth: null,
  email: '',
  address: '',
  password: '',
  role_name: '',
};
let AdminCreateUser = async (req, res) => {
  let { phone, full_name, date_of_birth, email, address, password, role_name } = req.body;
  if ( !full_name || !phone || !password || !role_name ) {
    return res.status(400).json({
      message: 'Bad Request',
    });
  }

  if (phone) user1.phone = phone;
  if (full_name) user1.full_name = full_name;
  if (date_of_birth) user1.date_of_birth = date_of_birth;
  if (email) user1.email = email;
  if (address) user1.address = address;
  if (password) user1.password = password;
  if (role_name) user1.role_name = role_name;
    

  try {
    const [rows, fields] = await pool.execute(
      'CALL SP_AdminCreateUser(?, ?, ?, ?, ?, ?, ?);',
      [user1.phone, user1.full_name, user1.date_of_birth, user1.email,user1. address, user1.password, user1.role_name]
    );

    return res.status(200).json({
      message: 'ok',
      body: user1
    });
  } catch (error) {
    console.error('Error executing query:', error);
    return res.status(500).json({
      message: 'Internal Server Error',
      error: error.message,
    });
  }
}

module.exports = {
    signupUser, loginUser, changePassword, createOrder, addProductToOrder,
    getProductByName, getProductById,
    // getAllProduct,
    // OK
    //  getProductByManufacturer,
    updateUserInfo,
    
    getListManufacturerWithProduct, getProductsOfManu, getPriceOfProduct, getNewProducts,
    getCartOfUser, getTotalOfCart,deleteProductOfCart, getInfoCustomerById, getTaxOfCustomer, getInfoUserById,
    updatePayOrder, updateQuantityProductOrder,
    getOrderProcessingOfUser, 
    getOrderOfUserWithStatus, 
    getProductQuantityOfWarehouse, getProductQuantityById, getProductQuantityOfOrder,
    getAllAreaWarehouse,updateShoppingArea,
    getFirstLogin, updateFirstLogin, getShoppingAreaOfCustomer, 
    getQuantityOfProductWithCart, 
    updateOrderConfirm, getDetailOrderById, getPayNameById, updateOrderStatus,
    updateCancelOrder, getAllCustomer, getAllAdmin, getUserByName, AdminCreateUser, 
}




// let getAllUsers = async (req,res) => {
//     const [rows, fields] = await pool.execute('select * from users')

//     return res.status(200).json({
//         message: 'ok',
//         data: rows
//     })
// }

// let getUserId = async (req,res) => {
//     let id = req.params.id
//     let [user] = await pool.execute('select * from users where user_id = ?',[id])
//     return res.status(200).json({
//         message: 'ok',
//         data: user
//     })
// }

// let createNewUser = async (req,res) => {
//     let { firstName, lastName, email, address } = req.body;
//     if ( !firstName || !lastName || !email || !address){
//         return res.status(200).json({
//             message: "missing require params"
//         })
//     }

//     await pool.execute('insert into users(firstName, lastName, email, address) values (?,?,?,?)',
//              [firstName, lastName, email, address])

//     return res.status(200).json({
//         message: 'ok'
        
//     })
// }

// let updateUser = async (req,res) => {
//     let { firstName, lastName, email, address, id } = req.body;
//     if ( !firstName || !lastName || !email || !address || !id ){
//         return res.status(200).json({
//             message: 'missing require params'
//         })
//     }

//     await pool.execute('update users set firstName = ?, lastName = ?, email = ?, address = ? where id = ?',
//                  [firstName, lastName, email, address, id])

//     return res.status(200).json({
//         message: 'ok'
//     })
// }

// let deleteUser = async (req,res) => {
//     let id = req.params.id;
//     if (!id){
//         return res.status(200).json({
//             message: 'missing require params'
//         })
//     }
//     await pool.execute('delete from users where id = ?', [id])
//     return res.status(200).json({
//         message: 'ok'
//     })
// }

// module.exports = {
    // getAllUsers, getUserId, createNewUser, updateUser, deleteUser

// }