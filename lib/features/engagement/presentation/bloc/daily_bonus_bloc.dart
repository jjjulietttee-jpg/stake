import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/daily_bonus_content.dart';
import '../../domain/services/engagement_service.dart';
import 'daily_bonus_event.dart';
import 'daily_bonus_state.dart';

class DailyBonusBloc extends Bloc<DailyBonusEvent, DailyBonusState> {
  final EngagementService engagementService;

  DailyBonusBloc({
    required this.engagementService,
  }) : super(const DailyBonusInitial()) {
    on<LoadTodaysBonusContent>(_onLoadTodaysBonusContent);
    on<LoadUnviewedBonusContent>(_onLoadUnviewedBonusContent);
    on<MarkBonusContentViewed>(_onMarkBonusContentViewed);
    on<FilterBonusContentByType>(_onFilterBonusContentByType);
    on<RefreshBonusContent>(_onRefreshBonusContent);
  }

  Future<void> _onLoadTodaysBonusContent(
    LoadTodaysBonusContent event,
    Emitter<DailyBonusState> emit,
  ) async {
    try {
      emit(const DailyBonusLoading());
      
      final content = await engagementService.getTodaysBonusContent();
      
      if (content.isEmpty) {
        emit(const DailyBonusEmpty());
        return;
      }
      
      final unviewedCount = content.where((item) => !item.isViewed).length;
      
      emit(DailyBonusLoaded(
        content: content,
        unviewedCount: unviewedCount,
      ));
    } catch (e) {
      emit(DailyBonusError(
        message: 'Failed to load bonus content',
        errorCode: 'LOAD_FAILED',
      ));
    }
  }

  Future<void> _onLoadUnviewedBonusContent(
    LoadUnviewedBonusContent event,
    Emitter<DailyBonusState> emit,
  ) async {
    try {
      emit(const DailyBonusLoading());
      
      final unviewedContent = await engagementService.getUnviewedBonusContent();
      
      if (unviewedContent.isEmpty) {
        emit(const DailyBonusEmpty(
          message: 'No new bonus content available',
        ));
        return;
      }
      
      emit(DailyBonusLoaded(
        content: unviewedContent,
        unviewedCount: unviewedContent.length,
      ));
    } catch (e) {
      emit(DailyBonusError(
        message: 'Failed to load unviewed content',
        errorCode: 'LOAD_UNVIEWED_FAILED',
      ));
    }
  }

  Future<void> _onMarkBonusContentViewed(
    MarkBonusContentViewed event,
    Emitter<DailyBonusState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DailyBonusLoaded) return;

    try {
      emit(DailyBonusViewing(
        content: currentState.content,
        viewingContentId: event.contentId,
      ));
      
      final success = await engagementService.viewBonusContent(event.contentId);
      
      if (success) {
        final updatedContent = currentState.content.map((item) {
          if (item.id == event.contentId) {
            return item.copyWith(isViewed: true);
          }
          return item;
        }).toList();
        
        final newUnviewedCount = updatedContent.where((item) => !item.isViewed).length;
        
        emit(DailyBonusContentViewed(
          content: updatedContent,
          viewedContentId: event.contentId,
          unviewedCount: newUnviewedCount,
        ));
        
        emit(DailyBonusLoaded(
          content: updatedContent,
          activeFilter: currentState.activeFilter,
          unviewedCount: newUnviewedCount,
        ));
      } else {
        emit(DailyBonusError(
          message: 'Failed to mark content as viewed',
          errorCode: 'VIEW_FAILED',
        ));
        
        emit(currentState);
      }
    } catch (e) {
      emit(DailyBonusError(
        message: 'An error occurred while viewing content',
        errorCode: 'VIEW_ERROR',
      ));
      
      emit(currentState);
    }
  }

  Future<void> _onFilterBonusContentByType(
    FilterBonusContentByType event,
    Emitter<DailyBonusState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DailyBonusLoaded) return;

    emit(currentState.copyWith(
      activeFilter: event.contentType,
      clearFilter: event.contentType == null,
    ));
  }

  Future<void> _onRefreshBonusContent(
    RefreshBonusContent event,
    Emitter<DailyBonusState> emit,
  ) async {
    add(const LoadTodaysBonusContent());
  }

  List<DailyBonusContent> get currentContent {
    final currentState = state;
    if (currentState is DailyBonusLoaded) {
      return currentState.content;
    }
    if (currentState is DailyBonusViewing) {
      return currentState.content;
    }
    if (currentState is DailyBonusContentViewed) {
      return currentState.content;
    }
    return [];
  }

  int get unviewedCount {
    final currentState = state;
    if (currentState is DailyBonusLoaded) {
      return currentState.unviewedCount;
    }
    if (currentState is DailyBonusContentViewed) {
      return currentState.unviewedCount;
    }
    return 0;
  }

  bool isContentBeingViewed(String contentId) {
    final currentState = state;
    if (currentState is DailyBonusViewing) {
      return currentState.viewingContentId == contentId;
    }
    return false;
  }

  List<DailyBonusContent> getContentByType(ContentType type) {
    return currentContent.where((item) => item.type == type).toList();
  }

  bool get hasNewContent {
    return unviewedCount > 0;
  }
}