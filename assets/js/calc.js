// calc.js
function addTen(value) {
  console.log("JS: Received value =", value);
  return value + 10;
}

// For Node (debugging)
if (typeof module !== 'undefined' && module.exports) {
  module.exports = { addTen };
}
