class JsNode {
  final String text;
  final List<JsNode> children;

  JsNode({required this.text, required this.children});

  factory JsNode.fromJson(Map<String, dynamic> json) {
    return JsNode(
      text: json['text'] ?? '',
      children: (json['children'] as List<dynamic>? ?? [])
          .map((c) => JsNode.fromJson(c))
          .toList(),
    );
  }
}
