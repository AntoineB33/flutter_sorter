import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'rules.dart';

// This is the entry point!
PluginBase createPlugin() => _ExampleLinter();

class _ExampleLinter extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        AvoidAttributeRowAndColumn(), // Register your rule here
      ];
}
