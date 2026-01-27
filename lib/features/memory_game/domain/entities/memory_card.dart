import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class MemoryCard extends Equatable {
  final int id;
  final IconData icon;
  final bool isFlipped;
  final bool isMatched;

  const MemoryCard({
    required this.id,
    required this.icon,
    this.isFlipped = false,
    this.isMatched = false,
  });

  MemoryCard copyWith({
    int? id,
    IconData? icon,
    bool? isFlipped,
    bool? isMatched,
  }) {
    return MemoryCard(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      isFlipped: isFlipped ?? this.isFlipped,
      isMatched: isMatched ?? this.isMatched,
    );
  }

  @override
  List<Object?> get props => [id, icon, isFlipped, isMatched];
}