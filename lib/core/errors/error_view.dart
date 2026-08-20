import 'package:flutter/material.dart';

import 'app_failure.dart';
import '../ui/noki_state_views.dart';

/// Standard full-area error state: message + retry action. Used by every
/// feature screen instead of ad-hoc error handling.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.failure, this.onRetry});

  final AppFailure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) =>
      NokiErrorState(failure: failure, onRetry: onRetry);
}

/// Standard full-area loading state.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) => const NokiLoadingState();
}

/// Standard empty state with an icon, title and body copy.
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.icon,
    required this.title,
    this.body,
  });

  final IconData icon;
  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) =>
      NokiEmptyState(icon: icon, title: title, body: body);
}
