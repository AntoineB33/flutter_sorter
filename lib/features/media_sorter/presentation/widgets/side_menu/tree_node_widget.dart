// import 'package:trying_flutter/features/media_sorter/presentation/logic/tree_manager.dart';
// import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';


// class TreeNodeWidget extends StatelessWidget {
//   final NodeStruct node;
//   // We might not even need the whole controller here, just the callback
//   final Function(NodeStruct) onToggleExpansion;
//   final Function(NodeStruct) onTap;

//   const TreeNodeWidget({
//     super.key, 
//     required this.node,
//     required this.onToggleExpansion,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (node.hideIfEmpty && node.children.isEmpty) return const SizedBox.shrink();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//            // ... Copy row UI logic here ...
//            IconButton(
//              onPressed: () => onToggleExpansion(node),
//              // ...
//            ),
//            InkWell(
//              onTap: () => onTap(node),
//              // ...
//            )
//         ),
//         if (node.isExpanded)
//           Padding(
//             padding: const EdgeInsets.only(left: 15.0),
//             child: Column(
//               children: node.children.map((child) => TreeNodeWidget(
//                 node: child, 
//                 onToggleExpansion: onToggleExpansion,
//                 onTap: onTap,
//               )).toList(),
//             ),
//           )
//       ],
//     );
//   }
// }