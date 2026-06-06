import 'package:shared_preferences/shared_preferences.dart';
import 'package:vmeet/data/models/meeting_model.dart';

class LocalStorage {
  static const _keyDisplayName = 'user_display_name';
  static const _keyAvatarIndex = 'user_avatar_index';
  static const _keyMeetingHistory = 'meeting_history_list';
  static const _keyMeetingSchedules = 'meeting_schedules_list';

  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  // Profile operations
  Future<void> saveDisplayName(String name) async {
    await _prefs.setString(_keyDisplayName, name);
  }

  String getDisplayName() {
    return _prefs.getString(_keyDisplayName) ?? '';
  }

  Future<void> saveAvatarIndex(int index) async {
    await _prefs.setInt(_keyAvatarIndex, index);
  }

  int getAvatarIndex() {
    return _prefs.getInt(_keyAvatarIndex) ?? 0;
  }

  // History operations
  List<MeetingModel> getMeetingHistory() {
    final list = _prefs.getStringList(_keyMeetingHistory) ?? [];
    return list.map((jsonStr) => MeetingModel.fromJson(jsonStr)).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Most recent first
  }

  Future<void> saveMeetingToHistory(MeetingModel meeting) async {
    final history = getMeetingHistory();
    // Prevent duplicate entries of the same session
    history.removeWhere((item) => item.roomCode == meeting.roomCode);
    history.insert(0, meeting.copyWith(isScheduled: false));
    
    // Keep last 30 entries to optimize local storage size
    if (history.length > 30) {
      history.removeRange(30, history.length);
    }

    final jsonList = history.map((m) => m.toJson()).toList();
    await _prefs.setStringList(_keyMeetingHistory, jsonList);
  }

  Future<void> clearHistory() async {
    await _prefs.remove(_keyMeetingHistory);
  }

  // Schedule operations
  List<MeetingModel> getSchedules() {
    final list = _prefs.getStringList(_keyMeetingSchedules) ?? [];
    return list.map((jsonStr) => MeetingModel.fromJson(jsonStr)).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp)); // Earliest upcoming first
  }

  Future<void> saveSchedule(MeetingModel meeting) async {
    final schedules = getSchedules();
    schedules.removeWhere((item) => item.id == meeting.id);
    schedules.add(meeting.copyWith(isScheduled: true));
    
    final jsonList = schedules.map((m) => m.toJson()).toList();
    await _prefs.setStringList(_keyMeetingSchedules, jsonList);
  }

  Future<void> deleteSchedule(String id) async {
    final schedules = getSchedules();
    schedules.removeWhere((item) => item.id == id);
    
    final jsonList = schedules.map((m) => m.toJson()).toList();
    await _prefs.setStringList(_keyMeetingSchedules, jsonList);
  }
}
