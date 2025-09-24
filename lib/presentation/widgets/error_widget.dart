import 'package:flutter/material.dart';

enum ErrorType { network, validation, unknown }

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final ErrorType type;
  final VoidCallback? onRetry;

  const CustomErrorWidget({
    Key? key,
    required this.message,
    this.type = ErrorType.unknown,
    this.onRetry,
  }) : super(key: key);

  String _getTitle() {
    switch (type) {
      case ErrorType.network:
        return 'Network Error';
      case ErrorType.validation:
        return 'Validation Error';
      default:
        return 'An Error Occurred';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 48),
            const SizedBox(height: 16),
            Text(_getTitle(), style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
