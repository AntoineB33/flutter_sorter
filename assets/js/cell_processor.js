function processCell(value) {
  // take time to process the cell value
  // start = Date.now();
  // while (Date.now() - start < 5000) {
  //   // busy wait for 5 seconds
  // }
  console.log("JS processCell called with:", value);
  return JSON.stringify({
    text: value,
    children: [
      { text: "child1", children: [] },
      { text: "child2", children: [{ text: "grandchild", children: [] }] }
    ]
  });
}



// For Node (debugging)
// if (typeof module !== 'undefined' && module.exports) {
//   module.exports = { processCell };
// }
