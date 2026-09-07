import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/navigator/custom_go_router.dart';
import 'package:musahi/core/widgets/base_scaffold.dart';
import 'package:musahi/core/widgets/info_card.dart';
import 'package:musahi/core/widgets/custom_app_bar.dart';
import 'package:musahi/core/widgets/custom_elevated_button.dart';
import 'package:musahi/firebase_options.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final settings = await FirebaseMessaging.instance.requestPermission();
  print('알림 권한 상태: ${settings.authorizationStatus}');

  if (Platform.isIOS) {
    String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    int retries = 0;
    while (apnsToken == null && retries < 10) {
      await Future.delayed(const Duration(seconds: 1));
      apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      retries++;
    }
  }

  await FirebaseMessaging.instance.subscribeToTopic('region_all');
  await FirebaseMessaging.instance.subscribeToTopic('region_236_critical');
  await FirebaseMessaging.instance.subscribeToTopic('region_236_safe');
  FirebaseMessaging.onMessage.listen(_handleMessage);

  runApp(const MyApp());
}

void _handleMessage(RemoteMessage message) {
  final severity = message.data['severity'] ?? '안전안내';
  final title = message.notification?.title ?? '';
  final body = message.notification?.body ?? '';

  final context = navigatorKey.currentContext;
  if (context == null) return;

  if (severity == '위급') {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: Colors.red.shade700,
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(body, style: const TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  } else if (severity == '긴급') {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.orange.shade800,
        duration: const Duration(seconds: 8),
        content: Text(
          '$title\n$body',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.blueGrey,
        duration: const Duration(seconds: 5),
        content: Text(
          '$title\n$body',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: goRouter,
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: 'Pretendard',
        scaffoldBackgroundColor: AppColors.background,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dt = DateTime.now();
    return BaseScaffold(
      appBar: CustomAppBar(title: '안녕하세요'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(child: Text('재난 알림 대기 중...')),
          InfoCard.alert(
            title: '공주시 화재',
            severity: '안내',
            time: '${dt.month}/${dt.day} ${dt.hour}:${dt.minute}',
          ),
          const InfoCard(title: '안녕'),
          const SizedBox(height: 10),
          InfoCard.shelter(name: '대덕소마고', address: '공주시', distanceMeters: 1000),
          const Spacer(),
          Row(
            children: [Expanded(child: CustomElevatedButton(onPressed: () {}))],
          ),
        ],
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Color _severityColor(String severity) {
    switch (severity) {
      case '위급':
        return Colors.red.shade700;
      case '긴급':
        return Colors.orange.shade800;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('지난 알림')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instanceFor(
                  app: Firebase.app(),
                  databaseId: 'musahi',
                )
                .collection('messages')
                .orderBy('sn', descending: true)
                .limit(50)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('오류: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('받은 알림이 없습니다.'));
          }
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final severity = data['severity'] ?? '안전안내';
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _severityColor(severity),
                  child: Text(
                    severity.substring(0, 1),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                title: Text(data['rcptnRgnNm']?.toString().trim() ?? ''),
                subtitle: Text(
                  data['msgCn'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  (data['crtDt'] ?? '').toString().split(' ').last,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
