import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidAttributeRowAndColumn extends DartLintRule {
  const AvoidAttributeRowAndColumn() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_attribute_row_and_column',
    problemMessage:
        'Do not instantiate Attribute with rowId and colId at the same time.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      print('Checking node: ${node.constructorName.type.toSource()}');
      // 1. ROBUST CHECK: Check the name from the code text (AST)
      // instead of waiting for the analyzer to resolve the element type.
      final typeName = node.constructorName.type.name2.lexeme; // .name2.lexeme handles newer analyzer versions
      
      // If you are using an older analyzer where .name2 doesn't exist yet, 
      // use: node.constructorName.type.name.name;
      
      // We accept 'Attribute' or 'some_prefix.Attribute'
      if (typeName != 'Attribute' && !typeName.endsWith('.Attribute')) {
        return;
      }

      // 2. Check for the presence of both arguments
      bool hasRowId = false;
      bool hasColumnId = false;

      for (final argument in node.argumentList.arguments) {
        if (argument is NamedExpression) {
          final name = argument.name.label.name;
          if (name == 'rowId') hasRowId = true;
          if (name == 'colId') hasColumnId = true;
        }
      }

      // 3. Report error if both exist
      if (hasRowId && hasColumnId) {
        reporter.reportErrorForNode(_code, node);
      }
    });
  }
}