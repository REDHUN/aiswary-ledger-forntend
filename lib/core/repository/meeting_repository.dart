import 'package:ashgledger/core/network/api_client.dart';
import 'package:ashgledger/core/network/api_endpoints.dart';
import 'package:ashgledger/core/model/meeting_model.dart';
import 'package:ashgledger/core/model/meeting_member_model.dart';

class MeetingRepository {
  final ApiClient _apiClient;

  MeetingRepository(this._apiClient);

  Future<List<MeetingModel>> getMeetings() async {
    final response = await _apiClient.request(
      path: ApiEndpoints.meetings,
      method: RequestType.get,
    );

    List rawList = [];
    if (response['data'] is List) {
      rawList = response['data'];
    } else if (response['data'] is Map && response['data']['content'] is List) {
      rawList = response['data']['content'];
    }

    return rawList.map((m) => MeetingModel.fromJson(m)).toList();
  }

  Future<MeetingModel> scheduleMeeting(String meetingDate, {String? notes}) async {
    final response = await _apiClient.request(
      path: ApiEndpoints.meetings,
      method: RequestType.post,
      body: {
        'meetingDate': meetingDate,
        'notes': notes,
      },
    );
    return MeetingModel.fromJson(response['data']);
  }

  Future<MeetingModel> openMeeting(int id) async {
    final response = await _apiClient.request(
      path: ApiEndpoints.openMeeting(id),
      method: RequestType.post,
    );
    return MeetingModel.fromJson(response['data']);
  }

  Future<MeetingModel> completeMeeting(int id) async {
    final response = await _apiClient.request(
      path: ApiEndpoints.completeMeeting(id),
      method: RequestType.post,
    );
    return MeetingModel.fromJson(response['data']);
  }

  Future<List<MeetingMemberModel>> getMeetingMembers(int meetingId) async {
    final response = await _apiClient.request(
      path: ApiEndpoints.meetingMembers(meetingId),
      method: RequestType.get,
    );
    final data = response['data'] as List? ?? [];
    return data.map((mm) => MeetingMemberModel.fromJson(mm)).toList();
  }
}
