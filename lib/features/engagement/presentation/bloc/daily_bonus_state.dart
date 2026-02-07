import 'package:equatable/equatable.dart';
import '../../domain/entities/daily_bonus_content.dart';

abstract class DailyBonusState extends Equatable {
  const DailyBonusState();

  @override
  List<Object?> get props => [];
}

class DailyBonusInitial extends DailyBonusState {
  const DailyBonusInitial();
}

class DailyBonusLoading extends DailyBonusState {
  const DailyBonusLoading();
}

class DailyBonusLoaded extends DailyBonusState {
  final List<DailyBonusContent> content;
  final ContentType? activeFilter;
  final int unviewedCount;

  const DailyBonusLoaded({
    required this.content,
    this.activeFilter,
    required this.unviewedCount,
  });

  @override
  List<Object?> get props => [content, activeFilter, unviewedCount];

  DailyBonusLoaded copyWith({
    List<DailyBonusContent>? content,
    ContentType? activeFilter,
    int? unviewedCount,
    bool clearFilter = false,
  }) {
    return DailyBonusLoaded(
      content: content ?? this.content,
      activeFilter: clearFilter ? null : (activeFilter ?? this.activeFilter),
      unviewedCount: unviewedCount ?? this.unviewedCount,
    );
  }

  List<DailyBonusContent> get filteredContent {
    if (activeFilter == null) return content;
    return content.where((item) => item.type == activeFilter).toList();
  }

  List<DailyBonusContent> get unviewedContent {
    return content.where((item) => !item.isViewed).toList();
  }

  List<DailyBonusContent> getContentByType(ContentType type) {
    return content.where((item) => item.type == type).toList();
  }
}

class DailyBonusViewing extends DailyBonusState {
  final List<DailyBonusContent> content;
  final String viewingContentId;

  const DailyBonusViewing({
    required this.content,
    required this.viewingContentId,
  });

  @override
  List<Object?> get props => [content, viewingContentId];
}

class DailyBonusContentViewed extends DailyBonusState {
  final List<DailyBonusContent> content;
  final String viewedContentId;
  final int unviewedCount;

  const DailyBonusContentViewed({
    required this.content,
    required this.viewedContentId,
    required this.unviewedCount,
  });

  @override
  List<Object?> get props => [content, viewedContentId, unviewedCount];
}

class DailyBonusEmpty extends DailyBonusState {
  final String message;

  const DailyBonusEmpty({
    this.message = 'No bonus content available today',
  });

  @override
  List<Object?> get props => [message];
}

class DailyBonusError extends DailyBonusState {
  final String message;
  final String? errorCode;

  const DailyBonusError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}