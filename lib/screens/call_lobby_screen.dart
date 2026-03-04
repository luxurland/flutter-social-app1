import 'package:flutter/material.dart';
import '../services/call_service.dart';
import 'call_screen.dart';

class CallLobbyScreen extends StatelessWidget {
  final String targetUserId;
  final CallService callService;

  const CallLobbyScreen({
    super.key,
    required this.targetUserId,
    required this.callService,
  });

  Future<void> _startCall(BuildContext context, String type) async {
    try {
      final result = await callService.startCall(callType: type);
      final callId = result['call_id'];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CallScreen(
            callId: callId,
            callType: type,
            callService: callService,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Start Call"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _callButton(
              label: "Voice Call",
              icon: Icons.call,
              color: Colors.green,
              onTap: () => _startCall(context, "voice"),
            ),
            const SizedBox(height: 40),
            _callButton(
              label: "Video Call",
              icon: Icons.videocam,
              color: Colors.blue,
              onTap: () => _startCall(context, "video"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _callButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        width: 260,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 10),
            Text(label, style: TextStyle(color: color, fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
