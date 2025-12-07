// import 'dart:convert';
// import 'dart:isolate';
// import 'dart:typed_data';
// import 'dart:async';
// import 'package:flutter/foundation.dart'; // Contains 'compute'
// import '../../domain/entities/analysis_result.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/services.dart';
// import 'package:collection/collection.dart';
// import 'dart:convert';
// import 'package:trying_flutter/src/features/media_sorter/domain/entities/cell.dart';
// import 'package:trying_flutter/src/features/media_sorter/domain/entities/node_struct.dart';
// import 'package:trying_flutter/src/features/media_sorter/domain/entities/column_type.dart';
// import 'package:trying_flutter/logger.dart';
// import 'package:trying_flutter/logic/async_utils.dart';
// import 'package:trying_flutter/logic/hungarian_algorithm.dart';
// import 'package:trying_flutter/src/features/media_sorter/domain/entities/dyn_and_int.dart';
// import 'package:trying_flutter/src/features/media_sorter/domain/entities/instr_struct.dart';
// import 'package:trying_flutter/data/repositories/spreadsheet_repository.dart';
// import 'package:trying_flutter/data/models/spreadsheet_data.dart';
// import 'package:trying_flutter/src/features/media_sorter/domain/constants/spreadsheet_constants.dart';

// class NodeStruct {
//   final String? message;
//   final int? row;
//   final int? col;
//   final AttAndCol? att;
//   final int? dist;
//   final int? minDist;
//   List<NodeStruct> children;
//   List<NodeStruct>? newChildren;
//   final bool hideIfEmpty;
//   final bool startOpen;
//   int
//   depth; // 0 if expanded, 1 if shown but not expanded, 2 if hidden but parent is shown, 3 otherwise

//   NodeStruct({
//     this.message,
//     this.row,
//     this.col,
//     this.att,
//     this.dist,
//     this.minDist,
//     List<NodeStruct>? newChildren,
//     this.hideIfEmpty = false,
//     this.startOpen = false,
//   }) : children = [],
//        depth = startOpen ? 0 : 1;
// }
