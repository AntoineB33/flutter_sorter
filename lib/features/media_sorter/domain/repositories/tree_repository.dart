import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_request.dart';

abstract class TreeRepository {
  void onTap(NodeStruct node);
}