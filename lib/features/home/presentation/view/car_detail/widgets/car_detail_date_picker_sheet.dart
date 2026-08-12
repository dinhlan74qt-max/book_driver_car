import 'package:book_drive_car/core/theme/app_colors.dart';
import 'package:book_drive_car/features/home/data/datasources/booking_remote_data_source.dart';
import 'package:book_drive_car/shared/widget/app_toast.dart';
import 'package:flutter/material.dart';

class CarDetailDatePickerSheet extends StatefulWidget {
  final int vehicleId;
  final BookingRemoteDataSource bookingRemoteDataSource;
  final DateTime initialStart;
  final DateTime initialEnd;
  final DateTime minDate;
  final DateTime maxDate;
  final DateTime Function(DateTime) dateOnly;
  final bool Function(DateTime, DateTime) isSameDay;
  final bool hasInitialSelection;
  final String Function(int weekday) weekdayShortLabel;
  final String Function(DateTime month) monthLabel;
  final List<DateTime?> Function(DateTime month) daysForMonth;
  final String Function(DateTimeRange range) formatBookingRange;
  final String Function(DateTimeRange range) formatBookingRangeWithTime;

  const CarDetailDatePickerSheet({
    super.key,
    required this.vehicleId,
    required this.bookingRemoteDataSource,
    required this.initialStart,
    required this.initialEnd,
    required this.hasInitialSelection,
    required this.minDate,
    required this.maxDate,
    required this.dateOnly,
    required this.isSameDay,
    required this.weekdayShortLabel,
    required this.monthLabel,
    required this.daysForMonth,
    required this.formatBookingRange,
    required this.formatBookingRangeWithTime,
  });

  @override
  State<CarDetailDatePickerSheet> createState() => _CarDetailDatePickerSheetState();
}

class _CarDetailDatePickerSheetState extends State<CarDetailDatePickerSheet> {
  late DateTime _focusedMonth;
  DateTime? _startDate;
  late DateTime? _endDate;
  bool _isLoadingBlockedRanges = true;
  String? _loadError;
  List<DateTimeRange> _blockedRanges = [];

  @override
  void initState() {
    super.initState();
    _startDate = widget.hasInitialSelection
        ? widget.dateOnly(widget.initialStart)
        : null;
    _endDate = widget.hasInitialSelection
        ? widget.dateOnly(widget.initialEnd)
        : null;
    final focusDate = _startDate ?? widget.dateOnly(DateTime.now());
    _focusedMonth = DateTime(focusDate.year, focusDate.month, 1);
    _loadBlockedRanges();
  }

  Future<void> _loadBlockedRanges() async {
    try {
      final ranges = await widget.bookingRemoteDataSource.getBookedRanges(
        widget.vehicleId,
      );
      if (!mounted) return;
      setState(() {
        _blockedRanges = ranges
            .map(
              (item) => DateTimeRange(
                start: widget.dateOnly(item.startDate),
                end: widget.dateOnly(item.endDate),
              ),
            )
            .where((range) => !range.end.isBefore(widget.minDate))
            .toList();
        _isLoadingBlockedRanges = false;
        _loadError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingBlockedRanges = false;
        _loadError = e.toString().replaceFirst('Exception: ', '');
      });
      AppToast.show(
        null,
        message: _loadError ?? 'Không thể tải lịch đã đặt',
        type: AppToastType.error,
      );
    }
  }

  bool get _canGoPrevious {
    final previousMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month - 1,
      1,
    );
    return !previousMonth.isBefore(
      DateTime(widget.minDate.year, widget.minDate.month, 1),
    );
  }

  bool get _canGoNext {
    final nextMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    return !nextMonth.isAfter(
      DateTime(widget.maxDate.year, widget.maxDate.month, 1),
    );
  }

  void _moveMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(
        _focusedMonth.year,
        _focusedMonth.month + delta,
        1,
      );
    });
  }

  bool _isBlockedDay(DateTime day) {
    final normalized = widget.dateOnly(day);
    return _blockedRanges.any(
      (range) =>
          !normalized.isBefore(range.start) && !normalized.isAfter(range.end),
    );
  }

  bool _doesCandidateOverlapBlockedRange(DateTime start, DateTime end) {
    final candidateStart = widget.dateOnly(start);
    final candidateEnd = widget.dateOnly(end);
    return _blockedRanges.any((range) {
      return !candidateStart.isAfter(range.end) &&
          !candidateEnd.isBefore(range.start);
    });
  }

  void _showOverlapWarning() {
    AppToast.show(
      null,
      message:
          'Trong khoảng thời gian này đã có người đặt lịch. Vui lòng chọn ngày khác.',
      type: AppToastType.warning,
    );
  }

  void _handleDayTap(DateTime day) {
    final normalized = widget.dateOnly(day);
    if (normalized.isBefore(widget.minDate) ||
        normalized.isAfter(widget.maxDate) ||
        _isBlockedDay(normalized)) {
      return;
    }

    if (_endDate != null || _startDate == null) {
      setState(() {
        _startDate = normalized;
        _endDate = null;
      });
      return;
    }

    if (widget.isSameDay(normalized, _startDate!)) {
      return;
    }

    final candidateStart = normalized.isBefore(_startDate!)
        ? normalized
        : _startDate!;
    final candidateEnd = normalized.isBefore(_startDate!)
        ? _startDate!
        : normalized;

    if (_doesCandidateOverlapBlockedRange(candidateStart, candidateEnd)) {
      setState(() {
        _startDate = normalized;
        _endDate = null;
      });
      _showOverlapWarning();
      return;
    }

    setState(() {
      _startDate = candidateStart;
      _endDate = candidateEnd;
    });
  }

  bool _isSelected(DateTime day) {
    final normalized = widget.dateOnly(day);
    return _endDate != null &&
        _startDate != null &&
        !normalized.isBefore(_startDate!) &&
        !normalized.isAfter(_endDate!);
  }

  Widget _buildDayCell(DateTime day) {
    final normalized = widget.dateOnly(day);
    final isStart =
        _startDate != null && widget.isSameDay(normalized, _startDate!);
    final isEnd = _endDate != null && widget.isSameDay(normalized, _endDate!);
    final isInRange = _isSelected(day);
    final isToday = widget.isSameDay(
      normalized,
      widget.dateOnly(DateTime.now()),
    );
    final isSelectedDay = isStart || isEnd || isInRange;
    final isDisabled =
        !isSelectedDay &&
        (normalized.isBefore(widget.minDate) ||
            normalized.isAfter(widget.maxDate) ||
            _isBlockedDay(normalized));

    BoxDecoration? decoration;
    Color textColor = AppColors.textPrimary;
    FontWeight fontWeight = FontWeight.w600;

    if (_isBlockedDay(normalized)) {
      decoration = BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(14),
      );
      textColor = AppColors.danger.withValues(alpha: 0.65);
    } else if (isStart) {
      decoration = BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      );
      textColor = Colors.white;
      fontWeight = FontWeight.w800;
    } else if (isEnd) {
      decoration = BoxDecoration(
        color: AppColors.danger,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: AppColors.danger.withValues(alpha: 0.26),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      );
      textColor = Colors.white;
      fontWeight = FontWeight.w800;
    } else if (isInRange) {
      decoration = BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      );
      textColor = AppColors.primary;
      fontWeight = FontWeight.w700;
    } else if (isToday) {
      decoration = BoxDecoration(
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(999),
      );
      textColor = AppColors.primary;
    }

    return GestureDetector(
      onTap: isDisabled ? null : () => _handleDayTap(day),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: decoration,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: isDisabled
                    ? textColor.withValues(alpha: 0.35)
                    : textColor,
                fontWeight: fontWeight,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarContent() {
    final days = widget.daysForMonth(_focusedMonth);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 4,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (context, index) {
              final day = days[index];
              if (day == null) {
                return const SizedBox.shrink();
              }
              return _buildDayCell(day);
            },
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                LegendRow(color: AppColors.primary, label: 'Ngày bắt đầu'),
                const SizedBox(height: 8),
                LegendRow(color: AppColors.danger, label: 'Ngày kết thúc'),
                const SizedBox(height: 8),
                LegendRow(
                  color: AppColors.danger.withValues(alpha: 0.1),
                  label: 'Ngày đã có lịch',
                  isRange: true,
                ),
                const SizedBox(height: 8),
                LegendRow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  label: 'Các ngày nằm giữa',
                  isRange: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.event_rounded, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _startDate == null || _endDate == null
                        ? 'Vui lòng chọn thời gian thuê xe'
                        : '${widget.formatBookingRangeWithTime(DateTimeRange(start: _startDate!, end: _endDate!))} (${_endDate!.difference(_startDate!).inDays < 1 ? 1 : _endDate!.difference(_startDate!).inDays} ngày)',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(maxHeight: size.height * 0.88),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Chọn ngày thuê xe',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _canGoPrevious
                              ? () => _moveMonth(-1)
                              : null,
                          icon: const Icon(Icons.chevron_left_rounded),
                          color: AppColors.primary,
                        ),
                        Text(
                          widget.monthLabel(_focusedMonth),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          onPressed: _canGoNext ? () => _moveMonth(1) : null,
                          icon: const Icon(Icons.chevron_right_rounded),
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(7, (index) {
                          final weekday = index + DateTime.monday;
                          return Expanded(
                            child: Center(
                              child: Text(
                                widget.weekdayShortLabel(weekday),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _isLoadingBlockedRanges
                      ? const Center(
                          key: ValueKey('loading'),
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : _loadError != null
                      ? Center(
                          key: const ValueKey('error'),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.cloud_off_rounded,
                                  color: AppColors.danger,
                                  size: 36,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _loadError!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                OutlinedButton(
                                  onPressed: _loadBlockedRanges,
                                  child: const Text('Thử lại'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _buildCalendarContent(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Hủy'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            (_isLoadingBlockedRanges || _loadError != null)
                            ? null
                            : () {
                                if (_endDate == null) {
                                  AppToast.show(
                                    null,
                                    message: 'Vui lòng chọn thời gian thuê xe',
                                    type: AppToastType.error,
                                  );
                                  return;
                                }

                                if (_doesCandidateOverlapBlockedRange(
                                  _startDate!,
                                  _endDate!,
                                )) {
                                  _showOverlapWarning();
                                  return;
                                }
                                Navigator.of(context).pop(
                                  DateTimeRange(
                                    start: _startDate!,
                                    end: _endDate!,
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.primary.withValues(
                            alpha: 0.35,
                          ),
                          disabledForegroundColor: Colors.white.withValues(
                            alpha: 0.9,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Xác nhận',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final bool isRange;

  const LegendRow({
    super.key,
    required this.color,
    required this.label,
    this.isRange = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            shape: isRange ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: isRange ? BorderRadius.circular(6) : null,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
