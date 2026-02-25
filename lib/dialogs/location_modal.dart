import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_extension.dart';
import '../models/exam.dart';
import '../widgets/glass_button.dart';

class LocationModal extends StatelessWidget {
  final ExamLocation location;

  const LocationModal({super.key, required this.location});

  static Future<void> show(BuildContext context, ExamLocation location) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LocationModal(location: location),
    );
  }

  void _openInMaps() async {
    if (location.locationUrl != null) {
      await launchUrl(Uri.parse(location.locationUrl!), mode: LaunchMode.externalApplication);
    } else if (location.address != null) {
      final query = Uri.encodeComponent(location.address!);
      await launchUrl(Uri.parse('https://www.google.com/maps/search/?api=1&query=$query'), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          decoration: BoxDecoration(
            color: colors.modalBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: colors.border.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(width: 40, height: 4, decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),

              // Icon & title
              Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Exam Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                      Text('View location details', style: TextStyle(fontSize: 13, color: colors.textMuted)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Location name
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Location Name', style: TextStyle(fontSize: 12, color: colors.textMuted)),
                    const SizedBox(height: 4),
                    Text(location.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                  ],
                ),
              ),

              if (location.address != null) ...[
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Address', style: TextStyle(fontSize: 12, color: colors.textMuted)),
                      const SizedBox(height: 4),
                      Text(location.address!, style: TextStyle(fontSize: 14, color: colors.textSecondary)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Map placeholder
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: colors.bgTertiary, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.map_rounded, color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(height: 10),
                    Text('Click the button below to view location on map', style: TextStyle(fontSize: 13, color: colors.textMuted), textAlign: TextAlign.center),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              GlassButton(
                text: 'Open in Maps',
                icon: Icons.navigation_rounded,
                onPressed: _openInMaps,
                width: double.infinity,
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text('Close', style: TextStyle(fontSize: 14, color: colors.textMuted, fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
