// debug.js
const path = require('path');
const { addTen } = require(path.join(__dirname, 'calc.js'));

console.log('Result:', addTen(32));
