// const express = require('express');
import express from 'express'
import cors from 'cors';

// import configViewEngine from './config/viewEngine';

import initAPIRouter from './route/api';

const path = require('path');
const app = express();
const port = process.env.PORT || 8080;

app.use(express.urlencoded({ extended: true }))
app.use(express.json())

initAPIRouter(app);

app.listen(port, () => {
    console.log(`Example app listening at http://localhost:${port}`)
})