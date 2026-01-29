import 'package:equatable/equatable.dart';
import '../../domain/entities/daily_bonus_content.dart';

abstract class DailyBonusEvent extends Equatable {
  const DailyBonusEvent();

  @override
  List<Object?> get props => [];
}

/// Load today's bonus content
class LoadTodaysBonusContent extends DailyBonusEvent {
  const LoadTodaysBonusContent();
}

/// Load only unviewed bonus content
class LoadUnviewedBonusContent extends DailyBonusEvent {
  const LoadUnviewedBonusContent();
}

/// Mark bonus content as viewed
class MarkBonusContentViewed extends DailyBonusEvent {
  final String contentId;

  const MarkBonusContentViewed({required this.contentId});

  @override
  List<Object?> get props => [contentId];
}

/// Filter content by type
class FilterBonusContentByType extends DailyBonusEvent {
  final ContentType? contentType;

  const FilterBonusContentByType({this.contentType});

  @override
  List<Object?> get props => [contentType];
}

/// Refresh bonus content
class RefreshBonusContent extends DailyBonusEvent {
  const RefreshBonusContent();
}