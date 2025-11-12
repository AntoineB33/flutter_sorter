// debug.js
const path = require('path');
const { addTen } = require(path.join(__dirname, 'cell_processor.js'));

console.log('Result:', addTen(32));
