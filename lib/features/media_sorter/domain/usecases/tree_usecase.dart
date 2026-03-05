import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_request.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/tree_repository.dart';

class TreeUsecase {
  final TreeRepository treeRepository;

  Stream<SelectionRequest> get nodeTapStream => treeRepository.nodeTapStream;

  TreeUsecase(this.treeRepository);

  void onTap(NodeStruct node) {
    treeRepository.onTap(node);
  }
}