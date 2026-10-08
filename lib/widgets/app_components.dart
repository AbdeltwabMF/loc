import 'package:flutter/material.dart';
import 'package:loc/themes/tokens.dart';

/// Standard section card using the app's card shape and spacing tokens.
class AppSectionCard extends StatelessWidget {
  const AppSectionCard({
    required this.icon,
    required this.title,
    required this.child,
    super.key,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: colors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.compact),
            child,
          ],
        ),
      ),
    );
  }
}

class AppWarningCard extends StatelessWidget {
  const AppWarningCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.busy = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colors.tertiaryContainer,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
      child: InkWell(
        borderRadius: AppRadius.cardRadius,
        onTap: busy ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.card,
            vertical: 16,
          ),
          child: Row(
            children: [
              Icon(icon, color: colors.onTertiaryContainer, size: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.onTertiaryContainer,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onTertiaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.compact),
              if (busy)
                SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.onTertiaryContainer,
                  ),
                )
              else
                Icon(
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.chevron_left_rounded
                      : Icons.chevron_right_rounded,
                  color: colors.onTertiaryContainer,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Switch with reduced visual bulk but a full 48dp touch area.
///
/// The switch itself is painted slightly smaller while hit testing uses the
/// unscaled 48dp box, so touch targets stay accessible.
class CompactSwitch extends StatelessWidget {
  const CompactSwitch({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppControlHeights.control,
      height: AppControlHeights.control,
      child: Center(
        child: Transform.scale(
          scale: 0.85,
          transformHitTests: false,
          child: Switch(value: value, onChanged: onChanged),
        ),
      ),
    );
  }
}

/// Numbered step row used by the external-map guidance dialog.
class NumberedStep extends StatelessWidget {
  const NumberedStep({
    required this.number,
    required this.label,
    this.trailing,
    super.key,
  });

  final int number;
  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$number',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: colors.onPrimaryContainer),
          ),
        ),
        const SizedBox(width: AppSpacing.compact),
        Expanded(child: Text(label)),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.sm),
          trailing!,
        ],
      ],
    );
  }
}
