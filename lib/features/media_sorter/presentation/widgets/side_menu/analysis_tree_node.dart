import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/tree_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/workbook_controller.dart';

class AnalysisTreeNode extends StatelessWidget {
  final NodeStruct node;
  final WorkbookController controller;
  final TreeController treeController;

  const AnalysisTreeNode({
    super.key,
    required this.node,
    required this.controller,
    required this.treeController,
  });

  @override
  Widget build(BuildContext context) {
    if (node.hideIfEmpty && node.children.isEmpty) {
      return const SizedBox.shrink();
    }

    final bool isLeaf = node.children.isEmpty;
    final bool isExpanded = node.isExpanded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLeaf)
                const SizedBox(width: 32, height: 32)
              else
                SizedBox(
                  width: 32,
                  height: 32,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 20,
                    splashRadius: 16,
                    icon: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_right,
                      color: Colors.grey[700],
                    ),
                    onPressed: () {
                      treeController.toggleNodeExpansion(node, !isExpanded);
                    },
                  ),
                ),

              InkWell(
                onTap: () {
                  node.onTap(node);
                  debugPrint("Selected node: ${node.message}");
                },
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6.0,
                    horizontal: 4.0,
                  ),
                  child: Text(
                    node.message ?? node.instruction ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isExpanded && !isLeaf)
          Container(
            margin: const EdgeInsets.only(left: 15.0),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.4),
                  width: 1.0,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: node.children
                    .map(
                      (child) =>
                          AnalysisTreeNode(node: child, controller: controller, treeController: treeController),
                    )
                    .toList(),
              ),
            ),
          ),
      ],
    );
  }
}
