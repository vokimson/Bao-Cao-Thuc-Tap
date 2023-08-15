import express from 'express'
import APIController from '../controller/APIController'
let router = express.Router();

const initAPIRoute = (app) => {

    // account
    router.post("/account/signup/", APIController.signupUser);
    router.get("/account/login", APIController.loginUser);
    router.put("/account/changePassword/", APIController.changePassword);

    // order
    router.post("/order/createOrder", APIController.createOrder);
    router.post("/order/addProductToOrder", APIController.addProductToOrder);

    router.get("/order/getTotalOfCart", APIController.getTotalOfCart);
    router.delete("/order/deleteProductOfCart", APIController.deleteProductOfCart);
    router.put("/order/updatePayOrder", APIController.updatePayOrder);
    router.put("/order/updateQuantityProductOrder", APIController.updateQuantityProductOrder);

    router.get("/order/getOrderProcessingOfUser", APIController.getOrderProcessingOfUser);
    router.get("/order/getOrderOfUserWithStatus", APIController.getOrderOfUserWithStatus);

    router.get("/product/getProductByName/", APIController.getProductByName);
    router.get("/product/getProductById/", APIController.getProductById);

    // router.get("/product/getProductByManufacturer/", APIController.getProductByManufacturer);

    // user
    router.put("/user/updateUserInfo", APIController.updateUserInfo);
    router.get("/user/getCartOfUser", APIController.getCartOfUser);
    router.get("/user/getInfoCustomerById", APIController.getInfoCustomerById);
    router.get("/user/getInfoUserById", APIController.getInfoUserById);
    router.get("/user/getTaxOfCustomer", APIController.getTaxOfCustomer);


    router.get("/getListManufacturerWithProduct", APIController.getListManufacturerWithProduct);
    router.get("/getProductsOfManu", APIController.getProductsOfManu);
    router.get("/getPriceOfProduct", APIController.getPriceOfProduct);
    router.get("/getNewProducts", APIController.getNewProducts);

    router.get("/product/getProductQuantityOfWarehouse", APIController.getProductQuantityOfWarehouse);
    router.get("/product/getProductQuantityById", APIController.getProductQuantityById);
    router.get("/product/getProductQuantityOfOrder", APIController.getProductQuantityOfOrder);

    router.get("/getAllAreaWarehouse", APIController.getAllAreaWarehouse);
    router.put("/updateShoppingArea", APIController.updateShoppingArea);

    router.get("/getFirstLogin", APIController.getFirstLogin);
    router.put("/updateFirstLogin", APIController.updateFirstLogin);

    router.get("/getQuantityOfProductWithCart", APIController.getQuantityOfProductWithCart);

    router.put("/order/updateOrderConfirm", APIController.updateOrderConfirm);

    router.get("/user/getShoppingAreaOfCustomer", APIController.getShoppingAreaOfCustomer);

    router.get("/order/getDetailOrderById", APIController.getDetailOrderById);

    router.get("/order/getPayNameById", APIController.getPayNameById);

    router.put("/order/updateOrderStatus", APIController.updateOrderStatus);
    router.put("/order/updateCancelOrder", APIController.updateCancelOrder);

    // admin
    router.get("/admin/getAllCustomer", APIController.getAllCustomer);
    router.get("/admin/getAllAdmin", APIController.getAllAdmin);
    
    router.get("/admin/getUserByName", APIController.getUserByName);

    router.post("/admin/AdminCreateUser", APIController.AdminCreateUser);



    // product
    // router.get("/product/getAllProduct", APIController.getAllProduct);



    return app.use('/api/v1/', router)
}
// http://localhost:8080/api/v1
module.exports = initAPIRoute;