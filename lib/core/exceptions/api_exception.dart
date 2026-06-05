class ApiException implements Exception {
  final int? statusCode;
  final dynamic data;

  ApiException(this.statusCode, this.data);

  @override
  String toString() {
    final message = _messageFromData(data);
    return message ??
        'Request failed${statusCode == null ? '' : ' ($statusCode)'}';
  }

  String? _messageFromData(dynamic value) {
    if (value is! Map) return value?.toString();

    final errors = _fieldMessages(value['errors']);
    if (errors != null) return errors;

    final details = _fieldMessages(value['details']);
    if (details != null) return details;

    final error = value['error'];
    if (error is Map) {
      final errorDetails = _fieldMessages(error['details']);
      if (errorDetails != null) return errorDetails;
      final errorMessage = error['message'];
      if (errorMessage != null) return errorMessage.toString();
    }

    final message = value['message'];
    return message?.toString();
  }

  String? _fieldMessages(dynamic value) {
    if (value is! Map || value.isEmpty) return null;

    final messages = <String>[];
    for (final entry in value.entries) {
      final field = entry.key.toString();
      final fieldValue = entry.value;
      if (fieldValue is List) {
        messages.addAll(fieldValue.map((message) => '$field: $message'));
      } else if (fieldValue != null) {
        messages.add('$field: $fieldValue');
      }
    }

    return messages.isEmpty ? null : messages.join('\n');
  }
}
