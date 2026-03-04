import 'package:get/get.dart';
import 'app_routes.dart';

// Dashboard
import '../features/home/ui/home_dashboard_screen.dart';

// Profile
import '../features/profile/ui/profile_screen.dart';
import '../features/profile/bindings/profile_binding.dart';

// Settings
import '../features/settings/ui/settings_screen.dart';
import '../features/settings/bindings/settings_binding.dart';

// Wallet
import '../features/wallet/ui/wallet_screen.dart';
import '../features/wallet/bindings/wallet_binding.dart';

// Notifications
import '../features/notifications/ui/notifications_screen.dart';
import '../features/notifications/bindings/notifications_binding.dart';

// Reports
import '../features/reports/ui/reports_screen.dart';
import '../features/reports/bindings/reports_binding.dart';

// Social Feed
import '../features/social/ui/personal_feed_screen.dart';
import '../features/social/bindings/social_binding.dart';

// Store
import '../features/store/ui/store_screen.dart';
import '../features/store/bindings/store_binding.dart';

// Calls
import '../features/calls/ui/call_lobby_screen.dart';
import '../features/calls/ui/call_active_screen.dart';
import '../features/calls/ui/call_history_screen.dart';
import '../features/calls/bindings/call_binding.dart';

class AppPages {
  static final pages = [
    // Dashboard
    GetPage(
      name: AppRoutes.home,
      page: () => HomeDashboardScreen(),
    ),

    // Profile
    GetPage(
      name: AppRoutes.profile,
      page: () => ProfileScreen(),
      binding: ProfileBinding(),
    ),

    // Settings
    GetPage(
      name: AppRoutes.settings,
      page: () => SettingsScreen(),
      binding: SettingsBinding(),
    ),

    // Wallet
    GetPage(
      name: AppRoutes.wallet,
      page: () => WalletScreen(),
      binding: WalletBinding(),
    ),

    // Notifications
    GetPage(
      name: AppRoutes.notifications,
      page: () => NotificationsScreen(),
      binding: NotificationsBinding(),
    ),

    // Reports
    GetPage(
      name: AppRoutes.reports,
      page: () => ReportsScreen(),
      binding: ReportsBinding(),
    ),

    // Social Feed
    GetPage(
      name: AppRoutes.personalFeed,
      page: () => PersonalFeedScreen(),
      binding: SocialBinding(),
    ),

    // Store
    GetPage(
      name: AppRoutes.store,
      page: () => StoreScreen(),
      binding: StoreBinding(),
    ),

    // Calls
    GetPage(
      name: AppRoutes.callLobby,
      page: () => CallLobbyScreen(),
      binding: CallBinding(),
    ),
    GetPage(
      name: AppRoutes.callActive,
      page: () => CallActiveScreen(),
      binding: CallBinding(),
    ),
    GetPage(
      name: AppRoutes.callHistory,
      page: () => CallHistoryScreen(),
      binding: CallBinding(),
    ),
  ];
}
