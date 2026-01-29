import '../../domain/entities/daily_bonus_content.dart';

class DailyBonusContentModel {
  final String id;
  final String title;
  final String content;
  final String type;
  final String date;
  final bool isViewed;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;

  const DailyBonusContentModel({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.date,
    required this.isViewed,
    this.imageUrl,
    this.metadata,
  });

  factory DailyBonusContentModel.fromJson(Map<String, dynamic> json) {
    return DailyBonusContentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      type: json['type'] as String,
      date: json['date'] as String,
      isViewed: json['isViewed'] as bool,
      imageUrl: json['imageUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type,
      'date': date,
      'isViewed': isViewed,
      'imageUrl': imageUrl,
      'metadata': metadata,
    };
  }

  DailyBonusContent toEntity() {
    return DailyBonusContent(
      id: id,
      title: title,
      content: content,
      type: ContentType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => ContentType.gameTip,
      ),
      date: DateTime.parse(date),
      isViewed: isViewed,
      imageUrl: imageUrl,
      metadata: metadata,
    );
  }

  factory DailyBonusContentModel.fromEntity(DailyBonusContent content) {
    return DailyBonusContentModel(
      id: content.id,
      title: content.title,
      content: content.content,
      type: content.type.name,
      date: content.date.toIso8601String(),
      isViewed: content.isViewed,
      imageUrl: content.imageUrl,
      metadata: content.metadata,
    );
  }
}