import 'dart:async';
import 'package:flutter/material.dart';
import '../services/call_service.dart';

class CallScreen extends StatefulWidget {
  final String callId;
  final String callType; // "voice" or "video"
  final CallService callService;

  const CallScreen({
    super.key,
    required this.callId,
    required this.callType,
    required this.callService,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  int participants = 1;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsed += const Duration(seconds: 1);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _addParticipant() async {
    try {
      final result = await widget.callService.addParticipant(
        callId: widget.callId,
        newUserId: "USER_TO_ADD", // replace with selected user
      );

      setState(() {
        participants += 1;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Participant added. Extra charged: ${result['extra_charged']}")),
      );
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _extendCall(int minutes) async {
    try {
      final result = await widget.callService.extendCall(
        callId: widget.callId,
        durationMinutes: minutes,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Extended by $minutes minutes")),
      );
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _endCall() async {
    try {
      final result = await widget.callService.endCall(callId: widget.callId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Call ended. Total collected: ${result['total_collected']}")),
      );

      Navigator.pop(context);
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $msg")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = widget.callType == "video";

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            Text(
              isVideo ? "Video Call" : "Voice Call",
              style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              "Participants: $participants",
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),

            const SizedBox(height: 20),

            Text(
              _formatDuration(_elapsed),
              style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
            ),

            const Spacer(),

            if (isVideo)
              Container(
                height: 200,
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Icon(Icons.videocam, color: Colors.white54, size: 80),
                ),
              )
            else
              Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.call, color: Colors.white54, size: 80),
                ),
              ),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(Icons
