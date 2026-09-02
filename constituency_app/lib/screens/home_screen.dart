// File: lib/screens/home_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/app_localizations.dart';
import 'admin_login_screen.dart';
import 'analytics_screen.dart';
import 'chat_screen.dart';
import 'dashboard_screen.dart';
import 'grievance_form.dart';
import 'language_selection_screen.dart';
import 'projects_management_screen.dart';
import 'reports_screen.dart';
import 'resource_planner.dart';
import 'track_complaint.dart';

class HomeScreen extends StatefulWidget {
  final String localeCode;

  const HomeScreen({
    super.key,
    this.localeCode = 'hi',
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _sidebarCollapsed = false;

  AppLocalizations get loc => AppLocalizations(widget.localeCode);

  static const Color _primary = Color(0xFF2563EB);
  static const Color _bg = Color(0xFFF6F8FB);
  static const Color _border = Color(0xFFE5EAF1);
  static const Color _textDark = Color(0xFF0F1F3D);
  static const Color _textGrey = Color(0xFF5B6B84);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 900;

        if (isDesktop) {
          // ═════ DESKTOP VIEW ═════
          return Scaffold(
            backgroundColor: _bg,
            body: Row(
              children: [
                _buildSidebar(),
                Expanded(child: _buildContentArea(isDesktop: true)),
              ],
            ),
          );
        }

        // ═════ MOBILE / TABLET VIEW ═════
        return Scaffold(
          backgroundColor: _bg,
          appBar: AppBar(
            backgroundColor: const Color(0xFF0A1F44),
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text(
              loc.t('app_title'),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.translate),
                onPressed: _goToLanguageSelection,
              ),
              IconButton(
                icon: const Icon(Icons.lock_outline_rounded),
                onPressed: _goToAdminLogin,
              ),
              const SizedBox(width: 4),
            ],
          ),
          
          // MOBILE DRAWER (Hamburger Menu)
          drawer: _buildMobileDrawer(context),
          
          body: _buildContentArea(isDesktop: false),
          
          bottomNavigationBar: NavigationBar(
            backgroundColor: Colors.white,
            elevation: 8,
            indicatorColor: _primary.withOpacity(0.12),
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home_rounded, color: _primary),
                label: loc.t('nav_home'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.assignment_outlined),
                selectedIcon:
                    const Icon(Icons.assignment_rounded, color: _primary),
                label: loc.t('nav_complaints'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.insights_outlined),
                selectedIcon:
                    const Icon(Icons.insights_rounded, color: _primary),
                label: loc.t('nav_dashboard'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.forum_outlined),
                selectedIcon: const Icon(Icons.forum_rounded, color: _primary),
                label: loc.t('nav_chat'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _goToLanguageSelection() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()),
    );
  }

  void _goToAdminLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
    );
  }

  // ═════════════════════════════════════════════════════════
  // MOBILE DRAWER (Hamburger Menu for small screens)
  // ═════════════════════════════════════════════════════════
  Widget _buildMobileDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A1F44), Color(0xFF122C5A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.t('app_title'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            loc.t('welcome_sub'),
                            style: const TextStyle(
                              color: Color(0xFF8FA6CC),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(color: Color(0xFF223A66), height: 1),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  children: [
                    _sectionLabel('MAIN'),
                    _drawerNavItem(0, Icons.home_outlined, Icons.home_rounded, loc.t('nav_home')),
                    _drawerNavItem(1, Icons.assignment_outlined, Icons.assignment_rounded, loc.t('nav_complaints')),
                    _drawerNavItem(2, Icons.insights_outlined, Icons.insights_rounded, loc.t('nav_dashboard')),
                    
                    const SizedBox(height: 16),
                    _sectionLabel('AI & PLANNING'),
                    _drawerNavItem(3, Icons.forum_outlined, Icons.forum_rounded, loc.t('nav_chat')),
                    _drawerToolItem(Icons.account_balance_wallet_outlined, loc.t('btn_budget'), () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ResourcePlanner()));
                    }),
                    _drawerToolItem(Icons.engineering_outlined, loc.t('nav_projects'), () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectsManagementScreen(localeCode: widget.localeCode)));
                    }),
                    
                    const SizedBox(height: 16),
                    _sectionLabel('MONITORING'),
                    _drawerToolItem(Icons.track_changes_rounded, loc.t('btn_track'), () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => TrackComplaintScreen()));
                    }),
                    _drawerToolItem(Icons.description_outlined, loc.t('nav_reports'), () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ReportsScreen(localeCode: widget.localeCode)));
                    }),
                    _drawerToolItem(Icons.bar_chart_rounded, loc.t('nav_analytics'), () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => AnalyticsScreen(localeCode: widget.localeCode)));
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerNavItem(int index, IconData icon, IconData selectedIcon, String label) {
    final bool selected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          setState(() => _selectedIndex = index);
          Navigator.pop(context); // Close drawer
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.white.withOpacity(0.14) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: selected ? Border.all(color: Colors.white.withOpacity(0.18)) : null,
          ),
          child: Row(
            children: [
              Icon(selected ? selectedIcon : icon, size: 20, color: selected ? Colors.white : const Color(0xFF8FA6CC)),
              const SizedBox(width: 12),
              Text(label, style: TextStyle(color: selected ? Colors.white : const Color(0xFF8FA6CC), fontSize: 14, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerToolItem(IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF8FA6CC)),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: const TextStyle(color: Color(0xFF8FA6CC), fontSize: 14, fontWeight: FontWeight.w500))),
              const Icon(Icons.north_east_rounded, size: 14, color: Color(0xFF6E86AD)),
            ],
          ),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════
  // DESKTOP SIDEBAR
  // ═════════════════════════════════════════════════════════
  Widget _buildSidebar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: _sidebarCollapsed ? 78 : 264,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A1F44), Color(0xFF122C5A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo + collapse button
            Padding(
              padding: EdgeInsets.fromLTRB(
                _sidebarCollapsed ? 14 : 20,
                20,
                _sidebarCollapsed ? 14 : 12,
                16,
              ),
              child: Row(
                mainAxisAlignment: _sidebarCollapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.spaceBetween,
                children: [
                  if (!_sidebarCollapsed)
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.account_balance_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.t('app_title'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                Text(
                                  loc.t('welcome_sub'),
                                  style: const TextStyle(
                                    color: Color(0xFF8FA6CC),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  if (!_sidebarCollapsed)
                    _collapseButton(true)
                  else
                    const SizedBox.shrink(),
                ],
              ),
            ),

            if (_sidebarCollapsed)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Center(child: _collapseButton(false)),
              ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(color: Color(0xFF223A66), height: 1),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // MAIN SECTION
                    _sectionLabel('MAIN'),
                    _sideNavItem(
                      index: 0,
                      icon: Icons.home_outlined,
                      selectedIcon: Icons.home_rounded,
                      label: loc.t('nav_home'),
                    ),
                    _sideNavItem(
                      index: 1,
                      icon: Icons.assignment_outlined,
                      selectedIcon: Icons.assignment_rounded,
                      label: loc.t('nav_complaints'),
                    ),
                    _sideNavItem(
                      index: 2,
                      icon: Icons.insights_outlined,
                      selectedIcon: Icons.insights_rounded,
                      label: loc.t('nav_dashboard'),
                    ),

                    const SizedBox(height: 16),

                    // AI & PLANNING SECTION
                    _sectionLabel('AI & PLANNING'),
                    _sideNavItem(
                      index: 3,
                      icon: Icons.forum_outlined,
                      selectedIcon: Icons.forum_rounded,
                      label: loc.t('nav_chat'),
                    ),
                    _sideToolItem(
                      icon: Icons.account_balance_wallet_outlined,
                      label: loc.t('btn_budget'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ResourcePlanner()),
                        );
                      },
                    ),
                    _sideToolItem(
                      icon: Icons.engineering_outlined,
                      label: loc.t('nav_projects'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProjectsManagementScreen(
                              localeCode: widget.localeCode,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // MONITORING SECTION
                    _sectionLabel('MONITORING'),
                    _sideToolItem(
                      icon: Icons.track_changes_rounded,
                      label: loc.t('btn_track'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => TrackComplaintScreen()),
                        );
                      },
                    ),
                    _sideToolItem(
                      icon: Icons.description_outlined,
                      label: loc.t('nav_reports'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReportsScreen(
                              localeCode: widget.localeCode,
                            ),
                          ),
                        );
                      },
                    ),

                    _sideToolItem(
                      icon: Icons.bar_chart_rounded,
                      label: loc.t('nav_analytics'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AnalyticsScreen(
                              localeCode: widget.localeCode,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(color: Color(0xFF223A66), height: 1),
            ),

            const SizedBox(height: 12),

            // Bottom controls
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: _sidebarCollapsed ? 12 : 16,
                vertical: 12,
              ),
              child: _sidebarCollapsed
                  ? Column(
                      children: [
                        _bottomIconBtn(
                          icon: Icons.translate,
                          onTap: _goToLanguageSelection,
                        ),
                        const SizedBox(height: 10),
                        _bottomIconBtn(
                          icon: Icons.lock_outline_rounded,
                          onTap: _goToAdminLogin,
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _goToLanguageSelection,
                            icon: const Icon(Icons.translate, size: 16),
                            label: Text(
                              widget.localeCode.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFF2C4A7C)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _bottomIconBtn(
                          icon: Icons.lock_outline_rounded,
                          onTap: _goToAdminLogin,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _collapseButton(bool inline) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => setState(() => _sidebarCollapsed = !_sidebarCollapsed),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _sidebarCollapsed
              ? Icons.chevron_right_rounded
              : Icons.chevron_left_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _bottomIconBtn({required IconData icon, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 18),
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(),
        splashRadius: 20,
      ),
    );
  }

  Widget _sectionLabel(String label) {
    if (_sidebarCollapsed) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Center(
          child: Divider(color: Color(0xFF223A66), height: 1),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 8),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF6E86AD),
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _sideNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final bool selected = _selectedIndex == index;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _sidebarCollapsed ? 14 : 12,
        vertical: 2,
      ),
      child: Tooltip(
        message: _sidebarCollapsed ? label : '',
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => setState(() => _selectedIndex = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.symmetric(
              horizontal: _sidebarCollapsed ? 10 : 14,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? Colors.white.withOpacity(0.14)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: selected
                  ? Border.all(color: Colors.white.withOpacity(0.18))
                  : null,
            ),
            child: Row(
              mainAxisAlignment: _sidebarCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(
                  selected ? selectedIcon : icon,
                  size: 20,
                  color: selected ? Colors.white : const Color(0xFF8FA6CC),
                ),
                if (!_sidebarCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color:
                            selected ? Colors.white : const Color(0xFF8FA6CC),
                        fontSize: 13.5,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (selected)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF60A5FA),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sideToolItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _sidebarCollapsed ? 14 : 12,
        vertical: 2,
      ),
      child: Tooltip(
        message: _sidebarCollapsed ? label : '',
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: _sidebarCollapsed ? 10 : 14,
              vertical: 12,
            ),
            child: Row(
              mainAxisAlignment: _sidebarCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(icon, size: 20, color: const Color(0xFF8FA6CC)),
                if (!_sidebarCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF8FA6CC),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.north_east_rounded,
                    size: 13,
                    color: Color(0xFF6E86AD),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════
  // CONTENT AREA
  // ═════════════════════════════════════════════════════════
  Widget _buildContentArea({required bool isDesktop}) {
    return Column(
      children: [
        if (isDesktop)
          Container(
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: _border)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  loc.t('app_title'),
                  style: const TextStyle(
                    fontSize: 13,
                    color: _textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded,
                    size: 16, color: _textGrey),
                const SizedBox(width: 8),
                Text(
                  _currentPageLabel(),
                  style: const TextStyle(
                    fontSize: 13,
                    color: _textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 8, color: Color(0xFF1E8E3E)),
                      const SizedBox(width: 6),
                      Text(
                        loc.t('active') == 'active' ? 'Live' : loc.t('active'),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E8E3E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: _getBody(),
            ),
          ),
        ),
      ],
    );
  }

  String _currentPageLabel() {
    switch (_selectedIndex) {
      case 0:
        return loc.t('nav_home');
      case 1:
        return loc.t('nav_complaints');
      case 2:
        return loc.t('nav_dashboard');
      case 3:
        return loc.t('nav_chat');
      default:
        return '';
    }
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return GrievanceForm(localeCode: widget.localeCode);
      case 2:
        return DashboardScreen(localeCode: widget.localeCode);
      case 3:
        return ChatScreen(localeCode: widget.localeCode);
      default:
        return _buildHomePage();
    }
  }

  // ═════════════════════════════════════════════════════════
  // HOME PAGE
  // ═════════════════════════════════════════════════════════
  Widget _buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0A1F44), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _primary.withOpacity(0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'AI POWERED GOVERNANCE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        loc.t('welcome'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        loc.t('welcome_sub'),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.account_balance_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          Text(
            loc.t('today_priorities'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 14),

          StreamBuilder(
            stream:
                FirebaseFirestore.instance.collection('grievances').snapshots(),
            builder: (context, AsyncSnapshot snapshot) {
              int critical = 0;
              int inProgress = 0;
              int resolvedWeek = 0;

              if (snapshot.hasData) {
                final now = DateTime.now();
                for (final doc in snapshot.data.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final p = data['priority_score'] is int
                      ? data['priority_score'] as int
                      : int.tryParse(
                              data['priority_score']?.toString() ?? '5') ??
                          5;
                  final s = data['status']?.toString() ?? 'submitted';

                  if (p >= 8 && s != 'resolved' && s != 'closed') critical++;
                  if (s == 'in_progress' ||
                      s == 'assigned' ||
                      s == 'processed') {
                    inProgress++;
                  }
                  if (s == 'resolved' || s == 'closed') {
                    final ts = data['timestamp'];
                    if (ts is Timestamp) {
                      final diff = now.difference(ts.toDate());
                      if (diff.inDays <= 7) resolvedWeek++;
                    }
                  }
                }
              }

              final items = [
                {
                  'color': const Color(0xFFD93025),
                  'emoji': '🔴',
                  'count': '$critical',
                  'label': loc.t('critical_grievances'),
                },
                {
                  'color': const Color(0xFFE65100),
                  'emoji': '🟠',
                  'count': '$inProgress',
                  'label': loc.t('in_progress_status'),
                },
                {
                  'color': const Color(0xFFF29900),
                  'emoji': '🟡',
                  'count': '₹1.2Cr',
                  'label': loc.t('budget_pending'),
                },
                {
                  'color': const Color(0xFF1E8E3E),
                  'emoji': '🟢',
                  'count': '$resolvedWeek',
                  'label': loc.t('resolved_week'),
                },
              ];

              return LayoutBuilder(
                builder: (context, c) {
                  final twoCol = c.maxWidth < 620;
                  return GridView.count(
                    crossAxisCount: twoCol ? 2 : 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 110,
                    children: items.map((it) {
                      final color = it['color'] as Color;
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5EAF1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(it['emoji'] as String,
                                    style: const TextStyle(fontSize: 14)),
                                const SizedBox(width: 6),
                                Text(
                                  it['count'] as String,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: color,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              it['label'] as String,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF5B6B84),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 28),

          Text(
            loc.t('quick_actions'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 14),

          // ═════════════════════════════════════════════════════════
          // ALL 8 QUICK ACTIONS (Includes Projects, Reports, Analytics)
          // ═════════════════════════════════════════════════════════
          LayoutBuilder(
            builder: (context, c) {
              final bool twoCol = c.maxWidth > 680;
              final double w = twoCol ? (c.maxWidth - 14) / 2 : c.maxWidth;

              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  SizedBox(
                    width: w,
                    child: _actionCard(
                      loc.t('btn_complaint'),
                      loc.t('btn_complaint_sub'),
                      Icons.assignment_late_rounded,
                      const Color(0xFFD93025),
                      () => setState(() => _selectedIndex = 1),
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: _actionCard(
                      loc.t('btn_dashboard'),
                      loc.t('btn_dashboard_sub'),
                      Icons.insights_rounded,
                      _primary,
                      () => setState(() => _selectedIndex = 2),
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: _actionCard(
                      loc.t('btn_chat'),
                      loc.t('btn_chat_sub'),
                      Icons.forum_rounded,
                      const Color(0xFF9334E6),
                      () => setState(() => _selectedIndex = 3),
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: _actionCard(
                      loc.t('btn_track'),
                      loc.t('btn_track_sub'),
                      Icons.track_changes_rounded,
                      const Color(0xFF12B5CB),
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TrackComplaintScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: _actionCard(
                      loc.t('btn_budget'),
                      loc.t('btn_budget_sub'),
                      Icons.account_balance_wallet_rounded,
                      const Color(0xFF1E8E3E),
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ResourcePlanner(),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: _actionCard(
                      loc.t('nav_projects'),
                      loc.t('projects_sub'),
                      Icons.engineering_outlined,
                      Colors.indigo,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProjectsManagementScreen(
                              localeCode: widget.localeCode,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: _actionCard(
                      loc.t('nav_reports'),
                      loc.t('reports_sub'),
                      Icons.description_outlined,
                      Colors.brown,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReportsScreen(
                              localeCode: widget.localeCode,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: _actionCard(
                      loc.t('nav_analytics'),
                      loc.t('analytics_sub'),
                      Icons.bar_chart_rounded,
                      Colors.teal,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AnalyticsScreen(
                              localeCode: widget.localeCode,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 28),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E8E3E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.accessibility_new_rounded,
                    color: Color(0xFF1E8E3E),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.t('accessible_banner'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        loc.t('accessible_sub'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: _textGrey,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _actionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: _textGrey,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded,
                  size: 16, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}