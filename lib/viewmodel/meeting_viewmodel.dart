import 'package:flutter/foundation.dart';
import '../core/state/load_state.dart';
import '../core/repository/meeting_repository.dart';
import '../core/model/meeting_model.dart';
import '../core/model/meeting_member_model.dart';

class MeetingViewModel extends ChangeNotifier {
  final MeetingRepository _meetingRepository;
  final LoadState loadState = LoadState();
  final LoadState actionState = LoadState();

  List<MeetingModel> _meetings = [];
  List<MeetingModel> get meetings => _meetings;

  MeetingModel? _activeMeeting;
  MeetingModel? get activeMeeting => _activeMeeting;

  List<MeetingMemberModel> _meetingMembers = [];
  List<MeetingMemberModel> get meetingMembers => _meetingMembers;

  MeetingViewModel(this._meetingRepository);

  bool get hasUncompletedMeeting => _meetings.any((m) => m.status == 'SCHEDULED' || m.status == 'OPEN');

  MeetingModel? get currentUncompletedMeeting {
    for (var m in _meetings) {
      if (m.status == 'SCHEDULED' || m.status == 'OPEN') {
        return m;
      }
    }
    return null;
  }

  Future<void> fetchMeetings() async {
    loadState.loading();
    notifyListeners();

    try {
      _meetings = await _meetingRepository.getMeetings();
      loadState.success();
    } catch (e) {
      loadState.error(e.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadMeetingDetails(int meetingId) async {
    loadState.loading();
    notifyListeners();

    try {
      _meetings = await _meetingRepository.getMeetings();
      _activeMeeting = _meetings.firstWhere((m) => m.id == meetingId, orElse: () => _meetings.first);
      _meetingMembers = await _meetingRepository.getMeetingMembers(meetingId);
      loadState.success();
    } catch (e) {
      loadState.error(e.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<bool> scheduleMeeting(String meetingDate, {String? notes}) async {
    actionState.loading();
    notifyListeners();

    try {
      await _meetingRepository.scheduleMeeting(meetingDate, notes: notes);
      actionState.success("Meeting scheduled successfully");
      fetchMeetings();
      return true;
    } catch (e) {
      actionState.error(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<bool> openMeeting(int meetingId) async {
    actionState.loading();
    notifyListeners();

    try {
      await _meetingRepository.openMeeting(meetingId);
      actionState.success("Meeting opened successfully");
      loadMeetingDetails(meetingId);
      return true;
    } catch (e) {
      actionState.error(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeMeeting(int meetingId) async {
    actionState.loading();
    notifyListeners();

    try {
      await _meetingRepository.completeMeeting(meetingId);
      actionState.success("Meeting completed and next Sunday meeting scheduled!");
      loadMeetingDetails(meetingId);
      return true;
    } catch (e) {
      actionState.error(e.toString());
      notifyListeners();
      return false;
    }
  }
}
