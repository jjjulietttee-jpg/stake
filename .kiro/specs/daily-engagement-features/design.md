# Design Document: Daily Engagement Features

## Overview

This design implements lightweight daily engagement features for a Flutter gaming app using clean architecture principles. The solution adds two main features: Daily Challenges and Daily Bonus Content, both designed to increase daily usage while maintaining the existing app's stability and architecture patterns.

The design follows the existing BLoC pattern, reuses current UI components, and integrates seamlessly with the existing profile and achievement systems. All new features are isolated and can be removed without affecting core functionality.

## Architecture

The engagement features follow a layered architecture that mirrors the existing app structure:

### Presentation Layer
- **DailyChallengeScreen**: Displays current daily challenge and completion status
- **DailyBonusScreen**: Shows daily bonus content using existing CardWidget components
- **EngagementBlocs**: State management for daily challenge and bonus content features
- **Existing UI Components**: Reuse CardWidget, CustomText, CustomElevatedButton

### Domain Layer
- **EngagementRepository**: Abstract interface for engagement data operations
- **DailyChallenge**: Entity representing a daily challenge with completion status
- **DailyBonusContent**: Entity representing daily bonus content items
- **EngagementUseCases**: Business logic for challenge completion, streak tracking, and bonus content access

### Data Layer
- **EngagementRepositoryImpl**: Concrete implementation using existing storage patterns
- **EngagementLocalDataSource**: Local storage for engagement data using existing mechanisms
- **EngagementModels**: Data models that map to domain entities

### Integration Points
- **ProfileService Extension**: Extends existing profile to include engagement metrics
- **AchievementService Integration**: Awards badges and tracks streaks through existing system
- **Router Extension**: Adds new routes without modifying existing navigation

## Components and Interfaces

### Core Entities

```dart
class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final Map<String, dynamic> parameters;
  final DateTime date;
  final bool isCompleted;
  final List<Reward> rewards;
}

class DailyBonusContent {
  final String id;
  final String title;
  final String content;
  final ContentType type;
  final DateTime date;
  final bool isViewed;
}

class EngagementProfile {
  final int currentStreak;
  final int longestStreak;
  final int totalChallengesCompleted;
  final int totalBonusContentViewed;
  final DateTime lastEngagementDate;
}
```

### Repository Interface

```dart
abstract class EngagementRepository {
  Future<DailyChallenge?> getTodaysChallenge();
  Future<void> markChallengeCompleted(String challengeId);
  Future<List<DailyBonusContent>> getTodaysBonusContent();
  Future<void> markBonusContentViewed(String contentId);
  Future<EngagementProfile> getEngagementProfile();
  Future<void> updateEngagementProfile(EngagementProfile profile);
  Future<void> resetDailyData();
}
```

### BLoC State Management

```dart
// Daily Challenge BLoC
class DailyChallengeBloc extends Bloc<DailyChallengeEvent, DailyChallengeState> {
  final GetTodaysChallengeUseCase getTodaysChallengeUseCase;
  final CompleteChallengeUseCase completeChallengeUseCase;
  final UpdateStreakUseCase updateStreakUseCase;
}

// Daily Bonus BLoC  
class DailyBonusBloc extends Bloc<DailyBonusEvent, DailyBonusState> {
  final GetTodaysBonusContentUseCase getTodaysBonusContentUseCase;
  final MarkBonusViewedUseCase markBonusViewedUseCase;
}
```

### Service Integration

```dart
class EngagementService {
  final EngagementRepository repository;
  final AchievementService achievementService;
  final ProfileService profileService;
  
  Future<void> completeChallenge(String challengeId) async {
    // Mark challenge complete
    // Update streak
    // Award achievements
    // Update profile
  }
  
  Future<void> viewBonusContent(String contentId) async {
    // Mark content viewed
    // Update engagement metrics
  }
}
```

## Data Models

### Challenge Types
- **PlayGames**: Complete N games in a day
- **AchieveScore**: Reach a target score in any game
- **PlayTime**: Play for N minutes total
- **PerfectGame**: Complete a game without mistakes
- **Streak**: Maintain a playing streak

### Bonus Content Types
- **GameTip**: Strategy tips for improving gameplay
- **FunFact**: Interesting facts related to memory and gaming
- **Achievement**: Spotlight on specific achievements to pursue
- **Milestone**: Celebration of user progress milestones

### Data Storage Schema

```dart
// Local storage keys following existing patterns
class EngagementStorageKeys {
  static const String dailyChallenge = 'daily_challenge';
  static const String bonusContent = 'daily_bonus_content';
  static const String engagementProfile = 'engagement_profile';
  static const String lastResetDate = 'last_reset_date';
}
```

### Daily Reset Logic

```dart
class DailyResetService {
  Future<bool> shouldResetDaily() async {
    final lastReset = await getLastResetDate();
    final now = DateTime.now();
    return !isSameDay(lastReset, now);
  }
  
  Future<void> performDailyReset() async {
    // Generate new challenge
    // Refresh bonus content
    // Reset completion status
    // Update last reset date
  }
}
```

## Navigation Integration

### Router Extension

```dart
// Add to existing GoRouter configuration
final engagementRoutes = [
  GoRoute(
    path: '/daily-challenge',
    builder: (context, state) => const DailyChallengeScreen(),
  ),
  GoRoute(
    path: '/daily-bonus',
    builder: (context, state) => const DailyBonusScreen(),
  ),
];
```

### Home Screen Integration

```dart
// Add engagement options to existing home screen
class EngagementHomeWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    return Column(
      children: [
        CardWidget(
          child: ListTile(
            title: CustomText('Daily Challenge'),
            subtitle: CustomText('Complete today\'s challenge'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () => context.go('/daily-challenge'),
          ),
        ),
        CardWidget(
          child: ListTile(
            title: CustomText('Daily Bonus'),
            subtitle: CustomText('Discover today\'s bonus content'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () => context.go('/daily-bonus'),
          ),
        ),
      ],
    );
  }
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Daily Challenge Uniqueness
*For any* two consecutive days, the daily challenge generated for day N should be different from the challenge generated for day N-1
**Validates: Requirements 1.1**

### Property 2: Challenge Completion Round Trip
*For any* daily challenge, completing it should mark it as completed, prevent re-completion on the same day, and trigger appropriate achievement updates
**Validates: Requirements 1.2, 1.4**

### Property 3: Daily Reset Consistency
*For any* system state, when a new day begins, all daily data (challenges, bonus content, completion status) should reset to fresh state while preserving historical data
**Validates: Requirements 1.3, 2.3, 6.5**

### Property 4: Streak Calculation Accuracy
*For any* sequence of daily challenge completions, the streak count should accurately reflect the number of consecutive days with completed challenges
**Validates: Requirements 1.5**

### Property 5: Challenge Display Completeness
*For any* daily challenge state, the display should include all required information: challenge details, completion status, and available rewards
**Validates: Requirements 1.6**

### Property 6: Challenge Expiration Handling
*For any* uncompleted challenge from a previous day, it should be marked as expired and replaced with the current day's challenge
**Validates: Requirements 1.7**

### Property 7: Bonus Content Daily Refresh
*For any* two different days, the bonus content available should be different, ensuring daily variety
**Validates: Requirements 2.1**

### Property 8: Content Viewing Status Tracking
*For any* bonus content item, viewing it should mark it as viewed and record the interaction for analytics
**Validates: Requirements 2.2, 2.6**

### Property 9: Content Rotation Completeness
*For any* extended period of daily usage, bonus content should rotate through the complete curated set without repetition until all items are shown
**Validates: Requirements 2.5**

### Property 10: Profile Integration Consistency
*For any* engagement activity (challenge completion or bonus content viewing), the user profile should be updated with accurate engagement metrics and persisted correctly
**Validates: Requirements 3.1, 3.4**

### Property 11: Profile Display Completeness
*For any* user profile with engagement data, the display should show current streak, longest streak, and engagement statistics alongside existing metrics
**Validates: Requirements 3.2, 3.3**

### Property 12: Graceful Degradation
*For any* system state where engagement data is missing or corrupted, core profile functionality should remain unaffected and engagement features should reset to safe defaults
**Validates: Requirements 3.5, 6.4**

### Property 13: Navigation Integration Preservation
*For any* existing navigation route, adding engagement features should not modify or break existing navigation patterns
**Validates: Requirements 4.1, 4.3**

### Property 14: UI Consistency Compliance
*For any* engagement screen or component, it should use existing UI components (CardWidget, CustomText, CustomElevatedButton) and follow the existing dark theme
**Validates: Requirements 2.4, 4.2, 4.4**

### Property 15: Home Screen Integration Harmony
*For any* home screen state, engagement navigation options should be present and complement existing menu items without disrupting the layout
**Validates: Requirements 4.5**

### Property 16: Feature Removability
*For any* system configuration, completely removing engagement features should leave all existing functionality intact and operational
**Validates: Requirements 5.4**

### Property 17: Data Persistence Round Trip
*For any* engagement data (challenge completion, bonus content viewing, streak information), saving and restoring the data should preserve all information accurately
**Validates: Requirements 6.1, 6.2**

### Property 18: Performance Compliance
*For any* engagement feature operation (initialization, challenge generation, content loading), it should complete within acceptable time limits without blocking the UI
**Validates: Requirements 7.1, 7.2, 7.3**

### Property 19: Resource Efficiency
*For any* system state where engagement features are inactive, background resource consumption should be minimal, and existing service instances should be reused
**Validates: Requirements 7.4, 7.5**

## Error Handling

### Challenge Generation Failures
- **Fallback Challenges**: If challenge generation fails, use a predefined set of fallback challenges
- **Error Logging**: Log generation failures for debugging without affecting user experience
- **Graceful Degradation**: Display a simple default challenge if all generation methods fail

### Data Persistence Failures
- **Retry Logic**: Implement exponential backoff for failed persistence operations
- **Local Caching**: Cache engagement data in memory as backup during persistence failures
- **User Notification**: Inform users if critical data cannot be saved, with retry options

### Network and External Dependencies
- **Offline Mode**: All engagement features should work offline using local data
- **Sync Recovery**: When connectivity returns, sync any pending engagement data
- **Timeout Handling**: Set reasonable timeouts for any external service calls

### State Corruption Recovery
- **Data Validation**: Validate engagement data on load and reset if corrupted
- **Safe Defaults**: Provide safe default values for all engagement metrics
- **Isolation**: Ensure engagement feature failures don't affect core app functionality

## Testing Strategy

### Dual Testing Approach

The testing strategy employs both unit testing and property-based testing to ensure comprehensive coverage:

**Unit Tests** focus on:
- Specific examples of challenge generation and completion
- Edge cases like day boundary transitions
- Integration points with existing profile and achievement systems
- Error conditions and recovery scenarios
- UI component rendering with specific data

**Property-Based Tests** focus on:
- Universal properties that hold across all possible inputs
- Challenge uniqueness across random date ranges
- Streak calculation accuracy with various completion patterns
- Data persistence round-trip properties
- UI consistency across different engagement states

### Property-Based Testing Configuration

- **Testing Library**: Use the `test` package with custom property generators for Flutter
- **Minimum Iterations**: Each property test runs 100+ iterations to ensure comprehensive coverage
- **Test Tagging**: Each property test includes a comment referencing its design document property
- **Tag Format**: `// Feature: daily-engagement-features, Property N: [property description]`

### Test Organization

```dart
// Example property test structure
group('Daily Challenge Properties', () {
  testProperty('Challenge uniqueness across days', (random) {
    // Feature: daily-engagement-features, Property 1: Daily Challenge Uniqueness
    // Generate random consecutive days and verify challenges differ
  });
  
  testProperty('Challenge completion round trip', (random) {
    // Feature: daily-engagement-features, Property 2: Challenge Completion Round Trip
    // Generate random challenges, complete them, verify state changes
  });
});
```

### Integration Testing

- **BLoC Integration**: Test engagement BLoCs with existing app BLoCs
- **Navigation Testing**: Verify engagement screens integrate with existing router
- **Profile Integration**: Test engagement data integration with existing profile system
- **Achievement Integration**: Verify engagement activities trigger existing achievement system

### Performance Testing

- **Startup Impact**: Measure app startup time with engagement features enabled
- **Memory Usage**: Monitor memory consumption during extended engagement feature usage
- **UI Responsiveness**: Verify UI remains responsive during challenge generation and content loading
- **Background Resource Usage**: Measure resource consumption when features are inactive