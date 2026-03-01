import 'dart:isolate';

import 'package:trying_flutter/features/media_sorter/domain/entities/sorting_response.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sorting_rule.dart';

class SortUsecase {

  /// Sorts integers based on constraints using a bipartite matching approach (DFS).
  static List<int>? sortConstrainedIntegers(int n, List<List<int>> validIndices) {
    int count = n + 1;
    List<int> indexOwner = List.filled(count, -1);
    List<bool> assignedIntegers = List.filled(count, false);

    // Initial greedy assignment
    for (int i = 0; i < count; i++) {
      for (int position in validIndices[i]) {
        if (indexOwner[position] == -1) {
          indexOwner[position] = i;
          assignedIntegers[i] = true;
          break;
        }
      }
    }

    // DFS for augmenting paths
    bool dfs(int u, List<bool> visited) {
      for (int v in validIndices[u]) {
        if (!visited[v]) {
          visited[v] = true;
          if (indexOwner[v] == -1 || dfs(indexOwner[v], visited)) {
            indexOwner[v] = u;
            return true;
          }
        }
      }
      return false;
    }

    for (int i = 0; i < count; i++) {
      if (!assignedIntegers[i]) {
        List<bool> visited = List.filled(count, false);
        if (!dfs(i, visited)) {
          return null;
        }
      }
    }

    return indexOwner;
  }

  /// Identifies valid values that can be placed at the specific index `id`.
  static List<int> getValidStarters(int n, int id, List<List<int>> validIndexesMap) {
    List<int> candidates = [];

    for (int value = 0; value < validIndexesMap.length; value++) {
      List<int> allowedIndices = validIndexesMap[value];
      for (int idx in allowedIndices) {
        if (idx == id) {
          candidates.add(value);
        }
      }
    }

    List<int> validResults = [];
    for (int val in candidates) {
      // Deep copy of validIndexesMap
      List<List<int>> validIndexesMapIfVal =
          validIndexesMap.map((lst) => List<int>.from(lst)).toList();
      
      // Force this value to be at index id
      validIndexesMapIfVal[val] = [id];

      if (sortConstrainedIntegers(n - 1, validIndexesMapIfVal) != null) {
        validResults.add(val);
      }
    }

    validResults.sort();
    return validResults;
  }

  /// Updates valid areas for other values based on the placement of `i` at `id`.
  static List<List<int>>? getValidPlaces(
    Map<int, Map<int, List<SortingRule>>> rules,
    List<List<int>> validAreas,
    int id,
    int i,
  ) {
    // Deep copy validAreas
    List<List<int>> newValidAreas =
        validAreas.map((e) => List<int>.from(e)).toList();
    
    newValidAreas[i] = [id];

    // Forward checking: Rules defined for the current value `i`
    if (rules[i] != null) {
      rules[i]!.forEach((rel, ruleList) {
        if (validAreas[rel].length > 1 || (validAreas[rel].isNotEmpty && validAreas[rel][0] > id)) {
          List<bool> nowValid = List.filled(validAreas[rel].length, false);
          
          for (int vAId = 0; vAId < validAreas[rel].length; vAId++) {
            int index = validAreas[rel][vAId];
            for (SortingRule rule in ruleList) {
              if (rule.minVal <= -(index - id) && -(index - id) <= rule.maxVal) {
                nowValid[vAId] = true;
              }
            }
          }
          // Filter valid indices
          List<int> filtered = [];
          for (int k = 0; k < validAreas[rel].length; k++) {
            if (nowValid[k]) filtered.add(validAreas[rel][k]);
          }
          newValidAreas[rel] = filtered; // Update newValidAreas, not validAreas directly
        }
      });
    }

    // Backward checking: Rules defined elsewhere that reference `i`
    for (int rowId in rules.keys) {
      // rulesId corresponds to rules[rowId]
      var rulesId = rules[rowId];
      
      if (validAreas[rowId].length > 1 || (validAreas[rowId].isNotEmpty && validAreas[rowId][0] > id)) {
        List<bool> nowValid = List.filled(validAreas[rowId].length, false);
        
        // Check if `i` is involved in this row's rules
        if (rulesId!.containsKey(i)) {
          List<SortingRule> ruleList = rulesId[i]!;
          
          for (int vAId = 0; vAId < validAreas[rowId].length; vAId++) {
            int index = validAreas[rowId][vAId];
            for (SortingRule rule in ruleList) {
              if (rule.minVal <= index - id && index - id <= rule.maxVal) {
                nowValid[vAId] = true;
              }
            }
          }
          
          // Filter valid indices
          List<int> filtered = [];
          for (int k = 0; k < validAreas[rowId].length; k++) {
            if (nowValid[k]) filtered.add(validAreas[rowId][k]);
          }
          newValidAreas[rowId] = filtered;
        }
      }
    }

    return newValidAreas;
  }

  /// Main solver function using backtracking.
  static void solveSorting((SendPort, Map<int, Map<int, List<SortingRule>>>, List<List<int>>, List<int>, int) args) {
    // Destructure the record back into individual variables for easy use
    final (sendPort, rules, validAreas, bestDistFound, n) = args;
    
    List<int> sortedList = List.filled(n, -1);
    List<List<int>> possibleIntsById = List.generate(n, (_) => []);
    List<int> cursors = List.filled(n, 0);
    
    // validAreasById[id] stores the state of validAreas at that depth
    List<List<List<int>>> validAreasById = List.generate(n + 1, (_) => []);
    validAreasById[0] = validAreas;

    int id = 0;
    while (id >= 0) {
      possibleIntsById[id] = getValidStarters(n, id, validAreasById[id]);
      
      bool found = false;
      
      // Note: Python enumerate logic starts from 0 every time in the snippet provided.
      // If you intended to skip previously tried candidates on backtrack,
      // you would use: int c = cursors[id]; c < possibleIntsById[id].length; c++
      for (int c = 0; c < possibleIntsById[id].length; c++) {
        // logic to skip already tried paths if strictly following backtracking patterns,
        // but adhering to Python snippet provided which resets loop:
        // If strict backtracking is needed, uncomment check below:
        // if (c < cursors[id]) continue; 

        int i = possibleIntsById[id][c];
        sortedList[id] = i;
        
        List<List<int>>? newValidPlaces = getValidPlaces(rules, validAreasById[id], id, i);
        
        if (newValidPlaces != null) { // Assuming empty list is valid, null is failure (if logic dictates)
          // Python `if new_valid_places:` checks for non-empty. 
          // Adjust based on whether getValidPlaces returns empty list on fail or valid state.
          // Usually solvers return null on fail. If it returns list, we check if it's usable.
          // Here assuming non-null is success.
          
          cursors[id] = c; // Save current cursor (state)
          id += 1;
          if (id <= n) {
            validAreasById[id] = newValidPlaces;
          }
          found = true;
          break; 
        }
      }
      if (found) {
        List<int> newDist = getDist();
        int comparison = compareDist(bestDistFound, newDist, id);
        if (comparison == -1) {
          found = false;
        } else if (id == n) {
          if (comparison == 1) {
            bool isNaturalOrderValid = true;
            if (bestDistFound.isEmpty) {
              for (int k = 0; k < sortedList.length; k++) {
                if (sortedList[k] != k) {
                  isNaturalOrderValid = false;
                  break;
                }
              }
            }
            bestDistFound.setAll(0, newDist);
            sendPort.send(SortingResponse(sortedIds: sortedList, isNaturalOrderValid: isNaturalOrderValid));
          } else {
            found = false;
          }
        }
      }
      if (!found) {
        id -= 1;
        if (id >= 0) {
          cursors[id]++; 
        }
      }
    }
    if (bestDistFound.isEmpty) {
      sendPort.send(SortingResponse(sortedIds: null, isNaturalOrderValid: false));
    }
  }

  static List<int> getDist() {
    return;
  }

  // Returns 1 if distNew is better, -1 if distRef is better, 0 if equal.
  static int compareDist(List<int> distRef, List<int> distNew, int id) {
    return;
  }

}