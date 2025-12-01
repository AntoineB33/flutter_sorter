import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';
import 'dart:convert';
import 'package:trying_flutter/data/models/cell.dart';
import 'package:trying_flutter/data/models/node_struct.dart';
import 'package:trying_flutter/data/models/column_type.dart';
import 'package:trying_flutter/logger.dart';
import 'package:trying_flutter/logic/async_utils.dart';
import 'package:trying_flutter/logic/hungarian_algorithm.dart';
import 'package:trying_flutter/data/models/dyn_and_int.dart';
import 'package:trying_flutter/data/models/instr_struct.dart';


class SpreadsheetData {
  String spreadsheetName = "";
  late List<List<String>> table = [];
  List<String> columnTypes = [];
  Cell? selectionStart;
  Cell? selectionEnd;
  
  SpreadsheetData({
    required this.name, 
    required this.table,
    required this.cellMap,
  });
}