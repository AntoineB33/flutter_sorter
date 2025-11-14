## 📁 Folder Structure Overview

```
lib/
│
├── data/
│   ├── spreadsheet_data.dart     # Core spreadsheet model, save/load, row/column logic
│   └── js_node.dart              # Node model for JS tree output
│
├── screens/
│   └── spreadsheet_page.dart     # Main UI screen + JS handling logic
│
├── widgets/
│   ├── spreadsheet_view.dart     # Editable spreadsheet table component
│   └── js_tree_view.dart         # Collapsible JS output tree
│
└── main.dart                     # App entry point

assets/
└── js/
    └── cell_processor.js         # JavaScript logic injected into runtime
```
