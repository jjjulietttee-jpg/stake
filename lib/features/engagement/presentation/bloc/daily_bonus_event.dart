import 'package:equatable/equatable.dart';
import '../../domain/entities/daily_bonus_content.dart';

abstract class DailyBonusEvent extends Equatable {
  const DailyBonusEvent();

  @override
  List<Object?> get props => [];
}

class LoadTodaysBonusContent extends DailyBonusEvent {
  const LoadTodaysBonusContent();
}

class LoadUnviewedBonusContent extends DailyBonusEvent {
  const LoadUnviewedBonusContent();
}

class MarkBonusContentViewed extends DailyBonusEvent {
  final String contentId;

  const MarkBonusContentViewed({required this.contentId});

  @override
  List<Object?> get props => [contentId];
}

class FilterBonusContentByType extends DailyBonusEvent {
  final ContentType? contentType;

  const FilterBonusContentByType({this.contentType});

  @override
  List<Object?> get props => [contentType];
}

class RefreshBonusContent extends DailyBonusEvent {
  const RefreshBonusContent();
}