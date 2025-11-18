import 'package:flutter/material.dart';
import '../data/node_struct.dart';

class TreeView extends StatefulWidget {
  final NodeStruct node;
  final double indent;

  const TreeView({super.key, required this.node, this.indent = 0});

  @override
  State<TreeView> createState() => _TreeViewState();
}

class _TreeViewState extends State<TreeView> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasChildren = widget.node.children.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(width: widget.indent),
            if (hasChildren)
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Text(
                  _expanded ? '▽ ' : '▷ ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            else
              const Text('  '), // spacer for alignment
            Expanded(
              child: Text(
                widget.node.message ?? '',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              children: widget.node.children
                  .map(
                    (child) =>
                        TreeView(node: child, indent: widget.indent + 12),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}
