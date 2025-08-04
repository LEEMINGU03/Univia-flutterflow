import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'menu_main_model.dart';
export 'menu_main_model.dart';

class MenuMainWidget extends StatefulWidget {
  const MenuMainWidget({super.key});

  static String routeName = 'menuMain';
  static String routePath = '/menuMain';

  @override
  State<MenuMainWidget> createState() => _MenuMainWidgetState();
}

class _MenuMainWidgetState extends State<MenuMainWidget> {
  late MenuMainModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MenuMainModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).info,
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                _buildHeader(),
                SizedBox(height: 20.0),
                _buildMenuSections(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '이민구 님',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                font: GoogleFonts.interTight(
                  fontWeight:
                      FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                  fontStyle:
                      FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                ),
                color: Color(0xFF020000),
                fontSize: 22.0,
                letterSpacing: 0.0,
                fontWeight:
                    FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                fontStyle:
                    FlutterFlowTheme.of(context).headlineMedium.fontStyle,
              ),
        ),
      ],
    );
  }

  Widget _buildMenuSections() {
    return Column(
      children: [
        _buildMenuSection(
          title: '기본 메뉴',
          items: [
            _buildMenuItem(
              title: '홈',
              icon: Icons.home_outlined,
              onTap: () {
                context.pushNamed('HomePage');
              },
            ),
            _buildMenuItem(
              title: '채팅',
              icon: Icons.chat_bubble_outline,
              onTap: () {
                context.pushNamed('ChatingMain');
              },
            ),
            _buildMenuItem(
              title: '공지사항',
              icon: Icons.notifications_outlined,
              onTap: () {
                context.pushNamed('NoticeMain');
              },
            ),
          ],
        ),
        SizedBox(height: 20.0),
        _buildMenuSection(
          title: '서비스',
          items: [
            _buildMenuItem(
              title: '민원신고',
              icon: Icons.report_problem_outlined,
              onTap: () {
                context.pushNamed('CivilcomplaintMain');
              },
            ),
            _buildMenuItem(
              title: '외박신청',
              icon: Icons.nightlife_outlined,
              onTap: () {
                context.pushNamed('SleepoverMain');
              },
            ),
            _buildMenuItem(
              title: '점수관리',
              icon: Icons.score_outlined,
              onTap: () {
                context.pushNamed('ScoreMain');
              },
            ),
          ],
        ),
        SizedBox(height: 20.0),
        _buildMenuSection(
          title: '계정',
          items: [
            _buildMenuItem(
              title: '프로필',
              icon: Icons.person_outline,
              onTap: () {
                context.pushNamed('ProfileMain');
              },
            ),
            _buildMenuItem(
              title: '설정',
              icon: Icons.settings_outlined,
              onTap: () {
                // 설정 페이지
              },
            ),
            _buildMenuItem(
              title: '로그아웃',
              icon: Icons.logout,
              onTap: () {
                // 로그아웃 기능
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              title,
              style: FlutterFlowTheme.of(context).titleMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                    ),
                    fontSize: 16.0,
                  ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color:
                    FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(
                icon,
                color: FlutterFlowTheme.of(context).primary,
                size: 20.0,
              ),
            ),
            SizedBox(width: 12.0),
            Expanded(
              child: Text(
                title,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                      ),
                      fontSize: 14.0,
                    ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: FlutterFlowTheme.of(context).secondaryText,
              size: 16.0,
            ),
          ],
        ),
      ),
    );
  }
}
