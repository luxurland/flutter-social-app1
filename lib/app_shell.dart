import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_routes.dart';
import 'features/home/ui/home_dashboard_screen.dart';
import 'theme.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  late AnimationController _controller;
  late Animation<double> _animation;

  final List<Widget> _pages = [
    HomeDashboardScreen(),
    GetRouterOutlet(initialRoute: AppRoutes.personalFeed),
    GetRouterOutlet(initialRoute: AppRoutes.store),
    GetRouterOutlet(initialRoute: AppRoutes.callLobby),
    GetRouterOutlet(initialRoute: AppRoutes.profile),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );
    _animation = Tween<double>(begin: 1.0, end: 1.15).animate(_controller);
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    _controller.forward().then((_) => _controller.reverse());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.light.primaryColor,
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(
              icon: Transform.scale(
                scale: _currentIndex == 0 ? _animation.value : 1.0,
                child: Icon(Icons.dashboard),
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Transform.scale(
                scale: _currentIndex == 1 ? _animation.value : 1.0,
                child: Icon(Icons.people),
              ),
              label: "Social",
            ),
            BottomNavigationBarItem(
              icon: Transform.scale(
                scale: _currentIndex == 2 ? _animation.value : 1.0,
                child: Icon(Icons.store),
              ),
              label: "Store",
            ),
            BottomNavigationBarItem(
              icon: Transform.scale(
                scale: _currentIndex == 3 ? _animation.value : 1.0,
