import 'package:analyzer/error/error.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidAttributeRowAndColumn extends DartLintRule {
  const AvoidAttributeRowAndColumn() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_attribute_row_and_column',
    problemMessage: 'Do not instantiate Attribute with rowId and colId simultaneously.',
  );

  // Define a temporary debug code to verify the linter is running
  static const _debugCode = LintCode(
    name: 'debug_linter_active',
    problemMessage: 'The linter is alive and checking this node.',
    errorSeverity: ErrorSeverity.INFO,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      // 1. SAFET CHECK: Use toSource() to get the class name.
      // This is safer than .name2.lexeme as it handles prefixes (e.g., ui.Attribute) automatically.
      final sourceName = node.constructorName.type.toSource();
      
      // DEBUG: Uncomment this line if you still see nothing. 
      // It will mark EVERY class instantiation in your app as an Info warning.
      reporter.reportErrorForNode(_debugCode, node);

      // Check if the class is Attribute
      if (!sourceName.endsWith('Attribute')) {
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