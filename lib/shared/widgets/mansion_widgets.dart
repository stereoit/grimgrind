import 'package:flutter/material.dart';

import '../../models.dart';
import '../../theme_package.dart';

Color difficultyColor(BuildContext context, ChoreDifficulty difficulty) =>
    ThemeScope.of(context).difficultyColor(difficulty);

Color heatColor(BuildContext context, HeatLevel heat) =>
    ThemeScope.of(context).heatColor(heat);

IconData heatIcon(BuildContext context, HeatLevel heat) =>
    ThemeScope.of(context).heatIcon(heat);

class CoinAmount extends StatelessWidget {
  const CoinAmount({
    super.key,
    required this.amount,
    this.prefix = '',
    this.fontSize = 14,
    this.iconSize = 16,
    this.color = const Color(0xFFC6A15B),
    this.fontWeight = FontWeight.bold,
  });

  final int amount;
  final String prefix;
  final double fontSize;
  final double iconSize;
  final Color color;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        '$prefix$amount',
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
      const SizedBox(width: 4),
      ClipOval(
        child: Image.asset(
          'assets/branding/gold_coin.png',
          width: iconSize,
          height: iconSize,
          fit: BoxFit.cover,
        ),
      ),
    ],
  );
}

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.valueWidget,
  });

  final IconData icon;
  final String value;
  final String label;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFF3B3329)),
      borderRadius: BorderRadius.circular(7),
    ),
    child: Column(
      children: [
        Icon(icon, size: 19, color: const Color(0xFFC6A15B)),
        const SizedBox(height: 6),
        valueWidget ??
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            letterSpacing: 1.2,
            color: Color(0xFF776F66),
          ),
        ),
      ],
    ),
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 18, 4, 10),
    child: Text(
      text,
      style: const TextStyle(
        color: Color(0xFF8E8170),
        letterSpacing: 1.8,
        fontSize: 10,
      ),
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.text,
    this.imageAsset,
  });

  final IconData icon;
  final String title;
  final String text;
  final String? imageAsset;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (imageAsset != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                imageAsset!,
                height: 220,
                fit: BoxFit.contain,
              ),
            )
          else
            Icon(icon, size: 52, color: const Color(0xFF5A4931)),
          const SizedBox(height: 18),
          Text(title, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF968C80)),
          ),
        ],
      ),
    ),
  );
}
