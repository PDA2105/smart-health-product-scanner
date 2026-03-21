import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../routes/app_routes.dart';
import '../providers/auth_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final displayName = user?.displayName?.trim();
    final effectiveName =
        (displayName != null && displayName.isNotEmpty) ? displayName : 'Bạn';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF9),
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: const Color(0xFF2ECC71),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                decoration: const BoxDecoration(
                  color: Color(0xCC2ECC71),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Color(0xFFD9D9D9),
                      child: Icon(Icons.person, size: 32, color: Colors.black54),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chào buổi sáng, $effectiveName!',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          if (user?.email != null)
                            Text(
                              user!.email!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Bạn chưa có thông báo mới')),
                        );
                      },
                      icon: const Icon(Icons.notifications_none),
                      tooltip: 'Thông báo',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Thống kê hôm nay',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatCard(label: 'Sản phẩm quét', value: '12'),
                    _StatCard(label: 'Cảnh báo', value: '3'),
                    _StatCard(label: 'Điểm sức khỏe', value: '7.8'),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: SizedBox(
                  width: 220,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed(AppRoutes.scan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2ECC71),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text(
                      'Scan',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Shortcuts',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _ShortcutTile(
                        icon: Icons.person_outline,
                        title: 'Hồ sơ',
                        subtitle: 'Thông tin sức khỏe',
                        onTap: () => context.navigateToProfile(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ShortcutTile(
                        icon: Icons.favorite_border,
                        title: 'Wishlist',
                        subtitle: 'Sản phẩm yêu thích',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tính năng đang phát triển')),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Lịch sử gần đây',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Xem tất cả',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2ECC71),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9F7EF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.local_drink, color: Color(0xFF27AE60)),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bia hơi Heineken',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '5% ABV',
                            style: TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 66,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _FooterTab(
              icon: Icons.home_outlined,
              label: 'Home',
              active: true,
              onTap: () {},
            ),
            _FooterTab(
              icon: Icons.favorite_border,
              label: 'Favorite',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng đang phát triển')),
                );
              },
            ),
            _FooterTab(
              icon: Icons.history,
              label: 'History',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng đang phát triển')),
                );
              },
            ),
            _FooterTab(
              icon: Icons.person_outline,
              label: 'Profile',
              onTap: () => context.navigateToProfile(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF2ECC71), size: 28),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterTab extends StatelessWidget {
  const _FooterTab({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF2ECC71) : const Color(0xFF9CA3AF);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

