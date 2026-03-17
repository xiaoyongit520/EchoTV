import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final String currentPath;

  const MainLayout({super.key, required this.child, required this.currentPath});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;
  bool _isExpanded = true;

  static const double expandedWidth = 200;
  static const double collapsedWidth = 100;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _widthAnimation = Tween<double>(
      begin: expandedWidth,
      end: collapsedWidth,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isPC = constraints.maxWidth > 800;

        final coreNavItems = [
          {'path': '/', 'label': '首页', 'icon': LucideIcons.home},
          {'path': '/movies', 'label': '电影', 'icon': LucideIcons.film},
          {'path': '/series', 'label': '剧集', 'icon': LucideIcons.clapperboard},
          {'path': '/anime', 'label': '动漫', 'icon': LucideIcons.ghost},
          {'path': '/variety', 'label': '综艺', 'icon': LucideIcons.sparkles},
          {'path': '/live', 'label': '直播', 'icon': LucideIcons.tv},
        ];

        final pcNavItems = [
          {'path': '/', 'label': '首页', 'icon': LucideIcons.home},
          {'path': '/search', 'label': '搜索', 'icon': LucideIcons.search},
          {'path': '/movies', 'label': '电影', 'icon': LucideIcons.film},
          {'path': '/series', 'label': '剧集', 'icon': LucideIcons.clapperboard},
          {'path': '/anime', 'label': '动漫', 'icon': LucideIcons.ghost},
          {'path': '/variety', 'label': '综艺', 'icon': LucideIcons.sparkles},
          {'path': '/live', 'label': '直播', 'icon': LucideIcons.tv},
        ];

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Row(
            children: [
              if (isPC)
                AnimatedBuilder(
                  animation: _widthAnimation,
                  builder: (context, _) {
                    return Container(
                      width: _widthAnimation.value,
                      key: const ValueKey('pc_sidebar'),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        border: Border(right: BorderSide(color: theme.dividerColor, width: 0.5)),
                      ),
                      child: SafeArea(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Logo 区域 - 根据状态调整
                            Padding(
                              padding: const EdgeInsets.fromLTRB(25, 40, 25, 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        height: 45,
                                        child: Image.asset('assets/icon/app_icon.png', fit: BoxFit.contain),
                                      ),
                                      const SizedBox(height: 2, width: double.infinity),
                                      Text(
                                        'ECHOTV',
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          fontSize: 8,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 2.0,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 2, width: double.infinity),
                                      Divider(height: 0.5, thickness: 0.5, color: Colors.black),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // 收缩状态下的占位符
                            const SizedBox(height: 2, width: double.infinity),
                            // 展开/收缩按钮 - 在两种状态下都显示
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 35),
                              child:
                              _SidebarItem(
                                icon:  _isExpanded ? LucideIcons.chevronLeft : LucideIcons.menu,
                                label: _isExpanded ? '收起' : '',
                                isActive: false,
                                isExpanded: _isExpanded,
                                onTap: _toggleSidebar,
                              )
                            ),

                            Expanded(
                              child: ScrollConfiguration(
                                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                                child: ListView.builder(
                                  itemCount: pcNavItems.length,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  physics: const BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final item = pcNavItems[index];
                                    final isActive = widget.currentPath == item['path'];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: _SidebarItem(
                                        icon: item['icon'] as IconData,
                                        label: item['label'] as String,
                                        isActive: isActive,
                                        isExpanded: _isExpanded,
                                        onTap: () => context.go(item['path'] as String),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            // 底部设置区域
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: _SidebarItem(
                                icon: LucideIcons.settings,
                                label: '系统设置',
                                isActive: widget.currentPath == '/settings',
                                isExpanded: _isExpanded,
                                onTap: () => context.go('/settings'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              Expanded(key: const ValueKey('main_content_area'), child: widget.child),
            ],
          ),

          bottomNavigationBar: isPC
              ? null
              : Container(
                  key: const ValueKey('mobile_bottom_nav'),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border(top: BorderSide(color: theme.dividerColor, width: 0.5)),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: coreNavItems.map((item) {
                          final isActive = widget.currentPath == item['path'];
                          return GestureDetector(
                            onTap: () => context.go(item['path'] as String),
                            behavior: HitTestBehavior.opaque,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  item['icon'] as IconData,
                                  size: 22,
                                  color: isActive ? theme.colorScheme.primary : theme.colorScheme.secondary.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['label'] as String,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                    color: isActive ? theme.colorScheme.primary : theme.colorScheme.secondary.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isExpanded;
  final VoidCallback onTap;

  const _SidebarItem({required this.icon, required this.label, required this.isActive, this.isExpanded = true, required this.onTap});

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: widget.isExpanded
              ? const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
              : const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isActive
                ? theme.colorScheme.primary
                : (_isHovered ? theme.colorScheme.onSurface.withValues(alpha: 0.05) : Colors.transparent),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: widget.isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: 16,
                color: widget.isActive ? (isDark ? Colors.black : Colors.white) : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              if (widget.isExpanded) ...[
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: widget.isActive ? FontWeight.w900 : FontWeight.w500,
                      color: widget.isActive ? (isDark ? Colors.black : Colors.white) : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
