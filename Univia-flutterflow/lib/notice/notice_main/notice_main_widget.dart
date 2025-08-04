import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'notice_main_model.dart';
export 'notice_main_model.dart';

class NoticeMainWidget extends StatefulWidget {
  const NoticeMainWidget({super.key});

  static String routeName = 'NoticeMain';
  static String routePath = '/noticeMain';

  @override
  State<NoticeMainWidget> createState() => _NoticeMainWidgetState();
}

class _NoticeMainWidgetState extends State<NoticeMainWidget> {
  late NoticeMainModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NoticeMainModel());
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
          child: Column(
            children: [
              // 헤더
              _buildHeader(),
              // 공지사항 목록
              Expanded(
                child: _buildNoticeList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          FlutterFlowIconButton(
            borderRadius: 8.0,
            buttonSize: 40.0,
            icon: Icon(
              Icons.arrow_back,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 24.0,
            ),
            onPressed: () async {
              context.pushNamed(HomePageWidget.routeName);
            },
          ),
          SizedBox(width: 12.0),
          Expanded(
            child: Text(
              '공지 사항',
              style: FlutterFlowTheme.of(context).titleLarge.override(
                    font: GoogleFonts.interTight(
                      fontWeight:
                          FlutterFlowTheme.of(context).titleLarge.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).titleLarge.fontStyle,
                    ),
                    letterSpacing: 0.0,
                    fontWeight:
                        FlutterFlowTheme.of(context).titleLarge.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).titleLarge.fontStyle,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: 10, // 임시 데이터
      itemBuilder: (context, index) {
        return _buildNoticeCard(
          title: '공지사항 ${index + 1}',
          content: '공지사항 내용입니다. 이 공지사항은 중요한 정보를 포함하고 있습니다.',
          date: '2024-01-${(index + 1).toString().padLeft(2, '0')}',
          isImportant: index < 3,
        );
      },
    );
  }

  Widget _buildNoticeCard({
    required String title,
    required String content,
    required String date,
    required bool isImportant,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          context.pushNamed('NoticeBig');
        },
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isImportant)
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: Color(0xFFFF5722),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        '중요',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (isImportant) SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      title,
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                            font: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                            ),
                            fontSize: 16.0,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Text(
                content,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(),
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 14.0,
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    date,
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          font: GoogleFonts.inter(),
                          color: FlutterFlowTheme.of(context).secondaryText,
                          fontSize: 12.0,
                        ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    size: 16.0,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
