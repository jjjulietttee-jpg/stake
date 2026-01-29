import 'package:equatable/equatable.dart';

enum ContentType {
  gameTip,
  funFact,
  achievement,
  milestone,
}

class DailyBonusContent extends Equatable {
  final String id;
  final String title;
  final String content;
  final ContentType type;
  final DateTime date;
  final bool isViewed;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;

  const DailyBonusContent({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.date,
    required this.isViewed,
    this.imageUrl,
    this.metadata,
  });

  DailyBonusContent copyWith({
    String? id,
    String? title,
    String? content,
    ContentType? type,
    DateTime? date,
    bool? isViewed,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) {
    return DailyBonusContent(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      date: date ?? this.date,
      isViewed: isViewed ?? this.isViewed,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        type,
        date,
        isViewed,
        imageUrl,
        metadata,
      ];
}