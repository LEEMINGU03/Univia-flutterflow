import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'massage_detail_roommate_copy_widget.dart'
    show MassageDetailRoommateCopyWidget;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MassageDetailRoommateCopyModel
    extends FlutterFlowModel<MassageDetailRoommateCopyWidget> {
  // 채팅 관련 변수들
  TextEditingController? messageController;
  String? selectedRole; // 실장님, 사감님, 층장
  String? currentUserId;
  String? currentUserName;
  String? currentStudentId; // 학생 학번

  // Firestore 인스턴스
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 채팅 스트림
  Stream<QuerySnapshot>? chatStream;

  // 메시지 목록 (임시로 사용)
  List<Map<String, dynamic>> messages = [];

  @override
  void initState(BuildContext context) {
    messageController = TextEditingController();
    _initializeChat();
  }

  void _initializeChat() {
    // 현재 사용자 정보 가져오기
    User? user = _auth.currentUser;
    if (user != null) {
      currentUserId = user.uid;
      _getUserInfo();
    } else {
      // 임시 사용자 정보 설정 (학생 시뮬레이션)
      print('Firebase 인증 사용자가 없어 임시 사용자 정보 설정');
      currentUserId = 'student_001';
      currentUserName = '이민구';
      currentStudentId = '20230709';

      // 빈 메시지 목록으로 시작
      messages = [];
    }

    // 채팅 스트림 초기화
    _initializeChatStream();
  }

  void _getUserInfo() async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(currentUserId).get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        currentUserName = userData['name'];
        currentStudentId = userData['studentId'];
      } else {
        // 사용자 정보가 없는 경우 기본값 설정
        currentUserName = '학생';
        currentStudentId = '20230709';
      }
    } catch (e) {
      print('사용자 정보 가져오기 오류: $e');
      currentUserName = '학생';
      currentStudentId = '20230709';
    }
  }

  // URL 파라미터에서 역할 설정
  void setRoleFromParameter(String? role) {
    if (role != null) {
      selectedRole = role;
      _initializeChatStream();
    }
  }

  void _initializeChatStream() {
    if (selectedRole != null && currentStudentId != null) {
      // 학생별 채팅방 ID 생성
      String chatId = _getChatId();

      // 역할별 관리자 타입 매핑
      String adminType = _getAdminType(selectedRole!);

      // 채팅방 생성 또는 업데이트
      _createOrUpdateChatRoom(chatId, adminType);

      // 메시지 스트림 설정 - chats 컬렉션 사용
      try {
        chatStream = _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .orderBy('timestamp', descending: false)
            .snapshots();

        print('채팅 스트림 초기화 성공: $chatId');
      } catch (e) {
        print('채팅 스트림 초기화 오류: $e');
        // 오류 발생 시 기본 메시지 사용
        chatStream = null;
      }
    } else {
      print(
          '채팅 스트림 초기화 실패: selectedRole=$selectedRole, currentStudentId=$currentStudentId');
      chatStream = null;
    }
  }

  String _getChatId() {
    // 학생 학번과 관리자 타입으로 채팅방 ID 생성
    String adminType = _getAdminType(selectedRole!);
    return 'chat_${currentStudentId}_$adminType';
  }

  String _getAdminType(String role) {
    switch (role) {
      case '실장님':
        return 'director';
      case '사감님':
        return 'supervisor';
      case '층장':
        return 'floor_manager';
      default:
        return 'general';
    }
  }

  void _createOrUpdateChatRoom(String chatId, String adminType) async {
    try {
      // chats 컬렉션에 채팅방 정보 저장
      await _firestore.collection('chats').doc(chatId).set({
        'studentName': currentUserName ?? '학생',
        'studentId': currentStudentId ?? 'unknown',
        'participants': [currentStudentId ?? 'unknown', 'admin'],
        'adminType': adminType,
        'lastMessage': '채팅방이 생성되었습니다.',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageBy': 'admin',
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('채팅방 생성/업데이트 성공: $chatId');
    } catch (e) {
      print('채팅방 생성/업데이트 오류: $e');
    }
  }

  void sendMessage() async {
    if (messageController?.text.trim().isEmpty ?? true) return;

    print('메시지 전송 시작: ${messageController!.text.trim()}');
    print('selectedRole: $selectedRole');
    print('currentStudentId: $currentStudentId');

    // 메시지 텍스트 저장
    String messageText = messageController!.text.trim();

    // 입력 필드 초기화
    messageController!.clear();

    try {
      String chatId = _getChatId();
      print('채팅방 ID: $chatId');

      // Firebase 인증 여부와 관계없이 Firestore에 메시지 저장
      print('Firestore에 메시지 저장 중...');
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'text': messageText,
        'senderId': 'student',
        'senderName': currentUserName ?? '학생',
        'timestamp': FieldValue.serverTimestamp(),
        'isAdmin': false,
      });

      // 채팅방 정보 업데이트 - 웹에서 목록에 표시되도록
      print('채팅방 정보 업데이트 중...');
      await _firestore.collection('chats').doc(chatId).set({
        'studentName': currentUserName ?? '학생',
        'studentId': currentStudentId ?? 'unknown',
        'participants': [currentStudentId ?? 'unknown', 'admin'],
        'adminType': _getAdminType(selectedRole!),
        'lastMessage': messageText,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageBy': 'student',
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('메시지 전송 성공: $messageText');
    } catch (e) {
      print('메시지 전송 오류: $e');
      // 오류 발생 시 임시 메시지 추가
      messages.add({
        'text': messageText,
        'senderId': 'student',
        'senderName': currentUserName ?? '학생',
        'timestamp': DateTime.now(),
        'isAdmin': false,
      });
      print('오류로 인한 임시 메시지 추가 완료: ${messages.length}개 메시지');
    }
  }

  void updateRole(String newRole) {
    selectedRole = newRole;
    _initializeChatStream();
  }

  @override
  void dispose() {
    messageController?.dispose();
  }
}
