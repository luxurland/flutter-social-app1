import 'package:get/get.dart';
import '../app_shell.dart';
import 'app_routes.dart';

// Bindings
import '../features/store/bindings/store_binding.dart';
import '../features/store/bindings/product_binding.dart';
import '../features/posts/bindings/posts_binding.dart';
import '../features/reports/bindings/reports_binding.dart';
import '../features/calls/bindings/calls_binding.dart';

// UI Screens
import '../features/store/ui/store_screen.dart';
import '../features/store/ui/products_screen.dart';
import '../features/posts/ui/personal_feed_screen.dart';
import '../features/posts/ui/product_feed_screen.dart';
import '../features/reports/ui/reports_screen.dart';
import '../features/calls/ui/call_lobby_screen.dart';
import '../features/calls/ui/call_active_screen.dart';
import '../features/calls/ui/call_history_screen.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.home,
      page: () => AppShell(api: ApiService("https://1.mod-mhsn.workers.dev/")),
    ),

    // Store
    GetPage(
      name: AppRoutes.store,
      page: () => StoreScreen(),
      binding: StoreBinding(),
    ),

    // Products
    GetPage(
      name: AppRoutes.products,
      page: () => ProductsScreen(storeId: 0),
      binding: ProductBinding(),
    ),

    // Posts
    GetPage(
      name: AppRoutes.personalFeed,
      page: () => PersonalFeedScreen(),
      binding: PostsBinding(),
    ),
    GetPage(
      name: AppRoutes.productFeed,
      page: () => ProductFeedScreen(),
      binding: PostsBinding(),
    ),

    // Reports
    GetPage(
      name: AppRoutes.reports,
      page: () => ReportsScreen(),
      binding: ReportsBinding(),
    ),

    // Calls
    GetPage(
      name: AppRoutes.callLobby,
      page: () => CallLobbyScreen(),
      binding: CallsBinding(),
    ),
    GetPage(
      name: AppRoutes.callActive,
      page: () => CallActiveScreen(),
      binding: CallsBinding(),
    ),
    GetPage(
      name: AppRoutes.callHistory,
      page: () => CallHistoryScreen(),
      binding: CallsBinding(),
    ),
  ];
}
