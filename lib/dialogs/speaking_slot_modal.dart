import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_extension.dart';
import '../models/exam.dart';
import '../providers/exam_provider.dart';
import '../widgets/glass_button.dart';
import '../utils/date_utils.dart';

class SpeakingSlotModal extends StatefulWidget {
  final int examId;
  final String examUserId;
  final ExamProvider examProvider;

  const SpeakingSlotModal({
    super.key,
    required this.examId,
    required this.examUserId,
    required this.examProvider,
  });

  static Future<void> show(BuildContext context, {
    required int examId,
    required String examUserId,
    required ExamProvider examProvider,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SpeakingSlotModal(
        examId: examId,
        examUserId: examUserId,
        examProvider: examProvider,
      ),
    );
  }

  @override
  State<SpeakingSlotModal> createState() => _SpeakingSlotModalState();
}

class _SpeakingSlotModalState extends State<SpeakingSlotModal> {
  List<SpeakingSlot> _slots = [];
  bool _isLoading = true;
  bool _isRegistering = false;
  String? _selectedSlot;
  String? _selectedDay;

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    try {
      final slots = await widget.examProvider.getSpeakingSlots(widget.examId);
      setState(() {
        _slots = slots;
        _isLoading = false;
        if (slots.isNotEmpty) {
          _selectedDay = slots.first.start.split(' ').first;
          final firstAvailable = slots.firstWhere((s) => s.available > 0, orElse: () => slots.first);
          _selectedSlot = firstAvailable.start;
        }
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Map<String, List<SpeakingSlot>> get _groupedByDay {
    final map = <String, List<SpeakingSlot>>{};
    for (final slot in _slots) {
      final day = slot.start.split(' ').first;
      map.putIfAbsent(day, () => []).add(slot);
    }
    return map;
  }

  List<SpeakingSlot> get _activeDaySlots {
    if (_selectedDay == null) return _slots;
    return _groupedByDay[_selectedDay] ?? _slots;
  }

  Future<void> _confirm() async {
    if (_selectedSlot == null) return;
    setState(() => _isRegistering = true);
    try {
      await widget.examProvider.selectSpeakingSlot(widget.examUserId, _selectedSlot!);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      setState(() => _isRegistering = false);
    }
  }

  String _formatDayLabel(String dateStr) {
    try {
      final d = parseTashkentDate('${dateStr}T00:00:00');
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[d.month - 1]} ${d.day}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final days = _groupedByDay.keys.toList();

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
          decoration: BoxDecoration(
            color: colors.modalBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: colors.border.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),

              Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.mic_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select Speaking Time', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                      Text('Choose an available time slot', style: TextStyle(fontSize: 13, color: colors.textMuted)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.primary)),
                      const SizedBox(height: 12),
                      Text('Loading slots...', style: TextStyle(fontSize: 13, color: colors.textMuted)),
                    ],
                  ),
                )
              else if (_slots.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.calendar_today, size: 40, color: colors.textMuted.withValues(alpha: 0.5)),
                      const SizedBox(height: 10),
                      Text('No available speaking slots found', style: TextStyle(fontSize: 13, color: colors.textMuted)),
                    ],
                  ),
                )
              else ...[
                // Day tabs
                if (days.length > 1) ...[
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: days.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemBuilder: (_, i) {
                        final isSelected = _selectedDay == days[i];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedDay = days[i]),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: isSelected ? colors.bgPrimary : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: isSelected ? [BoxShadow(color: colors.glassShadow, blurRadius: 4)] : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _formatDayLabel(days[i]),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: isSelected ? AppColors.primary700 : colors.textMuted,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Time slots grid
                Flexible(
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 2.2,
                    ),
                    itemCount: _activeDaySlots.length,
                    itemBuilder: (_, i) {
                      final slot = _activeDaySlots[i];
                      final isSelected = _selectedSlot == slot.start;
                      final isAvailable = slot.available > 0;

                      return GestureDetector(
                        onTap: isAvailable ? () => setState(() => _selectedSlot = slot.start) : null,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary50 : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : colors.border.withValues(alpha: 0.5),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            slot.startTime,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: !isAvailable
                                  ? colors.textMuted
                                  : isSelected
                                      ? AppColors.primary700
                                      : colors.textPrimary,
                              decoration: !isAvailable ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      text: 'Cancel',
                      isOutlined: true,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GlassButton(
                      text: 'Select',
                      icon: Icons.check,
                      onPressed: _selectedSlot != null ? _confirm : null,
                      isLoading: _isRegistering,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
