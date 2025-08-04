import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'massage_detail_roommate_copy_widget.dart'
    show MassageDetailRoommateCopyWidget;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'chat_service.dart';

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
      case 'chatbot':
        return 'chatbot';
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

      // 챗봇인 경우 자동 응답
      if (selectedRole == 'chatbot') {
        _sendChatbotResponse(messageText);
      }
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

  // 챗봇 자동 응답 메서드
  void _sendChatbotResponse(String userMessage) async {
    try {
      // 잠시 대기 후 응답 (자연스러운 느낌을 위해)
      await Future.delayed(Duration(seconds: 1));

      // ChatGPT API를 사용한 응답 생성
      String response = await _generateChatbotResponseWithGPT(userMessage);

      String chatId = _getChatId();

      // 챗봇 응답을 Firestore에 저장
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'text': response,
        'senderId': 'admin',
        'senderName': 'AI 어시스턴트',
        'timestamp': FieldValue.serverTimestamp(),
        'isAdmin': true,
      });

      // 채팅방 정보 업데이트
      await _firestore.collection('chats').doc(chatId).set({
        'studentName': currentUserName ?? '학생',
        'studentId': currentStudentId ?? 'unknown',
        'participants': [currentStudentId ?? 'unknown', 'admin'],
        'adminType': 'chatbot',
        'lastMessage': response,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageBy': 'admin',
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('챗봇 응답 전송 완료: $response');
    } catch (e) {
      print('챗봇 응답 전송 오류: $e');
    }
  }

  // ChatGPT API를 사용한 응답 생성
  Future<String> _generateChatbotResponseWithGPT(String userMessage) async {
    try {
      print('🔧 ChatbotService 호출 시작: $userMessage');
      // ChatbotService 사용
      final chatbotService = ChatbotService();
      print('🔧 ChatbotService 인스턴스 생성 완료');
      final response = await chatbotService.chatWithAI(userMessage, messages);
      print('🔧 ChatbotService 응답: $response');
      return response;
    } catch (e) {
      print('❌ ChatbotService 호출 오류: $e');
      print('❌ 오류 스택: ${StackTrace.current}');
      return _generateChatbotResponse(userMessage);
    }
  }

  // ChatGPT API 호출
  Future<String> _callChatGPTAPI(String apiKey, String userMessage) async {
    try {
      // 시스템 메시지 설정
      String systemMessage = '''
당신은 기숙사 관리 AI 어시스턴트입니다. 
학생들의 기숙사 생활과 관련된 질문에 친절하고 도움이 되는 답변을 제공해주세요.
긴급한 상황이나 복잡한 문제의 경우 실장님, 사감님, 층장님께 직접 문의하도록 안내해주세요.
답변은 한국어로 해주시고, 친근하고 이해하기 쉽게 설명해주세요.
''';

      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'system', 'content': systemMessage},
            {'role': 'user', 'content': userMessage},
          ],
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ??
            '죄송합니다. 응답을 생성할 수 없습니다.';
      } else {
        print('ChatGPT API 오류: ${response.statusCode}');
        return _generateChatbotResponse(userMessage);
      }
    } catch (e) {
      print('ChatGPT API 호출 실패: $e');
      return _generateChatbotResponse(userMessage);
    }
  }

  // 챗봇 응답 생성 메서드
  String _generateChatbotResponse(String userMessage) {
    String message = userMessage.toLowerCase();

    // 기본 인사말
    if (message.contains('안녕') ||
        message.contains('hello') ||
        message.contains('hi')) {
      return '안녕하세요! AI 어시스턴트입니다. 무엇을 도와드릴까요?';
    }

    // 기숙사 관련 질문
    if (message.contains('기숙사') || message.contains('숙소')) {
      return '기숙사 관련 문의사항이 있으시면 실장님, 사감님, 또는 층장님께 직접 문의해주세요.';
    }

    // 생활 관련 질문
    if (message.contains('생활') ||
        message.contains('규칙') ||
        message.contains('규정')) {
      return '기숙사 생활 규칙은 각 층에 게시되어 있습니다. 자세한 내용은 층장님께 문의해주세요.';
    }

    // 긴급 상황
    if (message.contains('긴급') ||
        message.contains('응급') ||
        message.contains('사고')) {
      return '긴급한 상황이시군요. 즉시 실장님(010-1234-5678) 또는 사감님(010-9876-5432)께 연락해주세요.';
    }

    // 일반적인 질문
    if (message.contains('도움') ||
        message.contains('help') ||
        message.contains('어떻게')) {
      return '도움이 필요하시군요. 구체적인 내용을 말씀해주시면 더 정확한 안내를 드릴 수 있습니다.';
    }

    // 기본 응답
    return '죄송합니다. 더 구체적으로 말씀해주시면 도움을 드릴 수 있습니다. 긴급한 사항은 실장님, 사감님, 층장님께 직접 문의해주세요.';
  }

  @override
  void dispose() {
    messageController?.dispose();
  }
}
