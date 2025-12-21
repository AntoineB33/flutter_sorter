import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidAttributeRowAndColumn extends DartLintRule {
  const AvoidAttributeRowAndColumn() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_attribute_row_and_column',
    problemMessage:
        'Do not instantiate Attribue with rowId and colId at the same time.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      // Fix 2: Change .element to .staticElement
      final element = node.constructorName.staticElement;

      // We check the enclosing element (the class) of the constructor
      // Note: In very new versions, enclosingElement might require enclosingElement3, 
      // but usually this still works.
      final type = element?.enclosingElement;

      if (type?.name != 'Attribute') return;

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
