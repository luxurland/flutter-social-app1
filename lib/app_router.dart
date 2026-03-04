import 'package:flutter/material.dart';
import 'api/api_service.dart';
import 'screens/user_profile_screen.dart';
import 'screens/product_details_screen.dart';
import 'screens/chat_screen.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings, ApiService api) {
    final args = settings.arguments;

    switch (settings.name) {
      case "/user_profile":
        return MaterialPageRoute(
          builder: (_) => UserProfileScreen(
            api: api,
            userId: args as String,
          ),
        );
      case "/product_details":
        return MaterialPageRoute(
          builder: (_) => ProductDetailsScreen(
            api: api,
            productId: args as int,
          ),
        );
      case "/chat":
        final map = args as Map;
        return MaterialPageRoute(
          builder: (_) => ChatScreen(
            api: api,
            threadId: map["threadId"],
            otherUserName: map["otherUserName"],
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("Unknown route")),
          ),
        );
    }
  }
}
