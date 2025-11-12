function processCell(value) {
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
