import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmeet/data/models/meeting_model.dart';
import 'package:vmeet/data/sources/local_storage.dart';

/// Provider for LocalStorage, overridden in main.dart once SharedPreferences loads
final localStorageProvider = Provider<LocalStorage>((ref) {
  throw UnimplementedError('localStorageProvider was not initialized in main.dart');
});

// ==========================================
// User Profile State Management
// ==========================================

class ProfileState {
  final String displayName;
  final int avatarIndex;
  final bool isOnboarded;

  ProfileState({
    required this.displayName,
    required this.avatarIndex,
    required this.isOnboarded,
  });

  ProfileState copyWith({
    String? displayName,
    int? avatarIndex,
    bool? isOnboarded,
  }) {
    return ProfileState(
      displayName: displayName ?? this.displayName,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      isOnboarded: isOnboarded ?? this.isOnboarded,
    );
  }
}

class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    final local = ref.watch(localStorageProvider);
    return ProfileState(
      displayName: local.getDisplayName(),
      avatarIndex: local.getAvatarIndex(),
      isOnboarded: local.getDisplayName().isNotEmpty,
    );
  }

  Future<void> saveProfile(String name, int avatarIdx) async {
    final local = ref.read(localStorageProvider);
    await local.saveDisplayName(name);
    await local.saveAvatarIndex(avatarIdx);
    state = ProfileState(
      displayName: name,
      avatarIndex: avatarIdx,
      isOnboarded: true,
    );
  }
}

final profileStateProvider = NotifierProvider<ProfileNotifier, ProfileState>(() {
  return ProfileNotifier();
});

// ==========================================
// Meeting History State Management
// ==========================================

class MeetingHistoryNotifier extends Notifier<List<MeetingModel>> {
  @override
  List<MeetingModel> build() {
    final local = ref.watch(localStorageProvider);
    return local.getMeetingHistory();
  }

  Future<void> addMeeting(MeetingModel meeting) async {
    final local = ref.read(localStorageProvider);
    await local.saveMeetingToHistory(meeting);
    state = local.getMeetingHistory();
  }

  Future<void> clearHistory() async {
    final local = ref.read(localStorageProvider);
    await local.clearHistory();
    state = [];
  }
}

final meetingHistoryProvider = NotifierProvider<MeetingHistoryNotifier, List<MeetingModel>>(() {
  return MeetingHistoryNotifier();
});

// ==========================================
// Scheduled Meetings State Management
// ==========================================

class SchedulesNotifier extends Notifier<List<MeetingModel>> {
  @override
  List<MeetingModel> build() {
    final local = ref.watch(localStorageProvider);
    return local.getSchedules();
  }

  Future<void> addSchedule(MeetingModel meeting) async {
    final local = ref.read(localStorageProvider);
    await local.saveSchedule(meeting);
    state = local.getSchedules();
  }

  Future<void> removeSchedule(String id) async {
    final local = ref.read(localStorageProvider);
    await local.deleteSchedule(id);
    state = local.getSchedules();
  }
}

final schedulesProvider = NotifierProvider<SchedulesNotifier, List<MeetingModel>>(() {
  return SchedulesNotifier();
});
