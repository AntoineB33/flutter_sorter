function processCell(value) {
  if (!value) return "Empty";
  if (!isNaN(value)) return "Number squared: " + (value * value);
  return "Uppercase: " + value.toUpperCase();
}


// For Node (debugging)
// if (typeof module !== 'undefined' && module.exports) {
//   module.exports = { processCell };
// }
