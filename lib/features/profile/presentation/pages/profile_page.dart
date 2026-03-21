import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../routes/app_routes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = context.read<AuthProvider>().user?.uid;
    if (userId == null) return;

    await context.read<ProfileProvider>().loadProfile(userId);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;
    final email = auth.user?.email ?? 'you@example.com';
    final nickname = profile?.nickname?.trim();
    final displayName = auth.user?.displayName?.trim();
    final effectiveName = (nickname != null && nickname.isNotEmpty)
      ? nickname
      : (displayName != null && displayName.isNotEmpty)
        ? displayName
        : 'Thanh Tung';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: profileProvider.isLoading && profile == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(context),
                    const SizedBox(height: 20),
                    _buildProfileHeader(effectiveName),
                    const SizedBox(height: 18),
                    _buildScanSummary(),
                    const SizedBox(height: 16),
                    _buildContactRows(
                      email: email,
                      phone: profile?.phone ?? '+84 12345678',
                      location: profile?.location ?? 'Thanh Hoa, VN',
                    ),
                    const SizedBox(height: 22),
                    _buildActionButtons(context),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: _buildFooter(context),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF8C8888)),
          tooltip: 'Quay lại',
        ),
        const Expanded(
          child: Text(
            'Hồ sơ của tôi',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ),
        IconButton(
          onPressed: () => context.navigateToProfileEdit(),
          icon: const Icon(Icons.edit, color: Color(0xFF2ECC71)),
          tooltip: 'Chỉnh sửa',
        ),
      ],
    );
  }

  Widget _buildProfileHeader(String name) {
    return Center(
      child: Column(
        children: [
          const CircleAvatar(
            radius: 72,
            backgroundColor: Color(0xFFD9D9D9),
            child: Icon(Icons.person, size: 72, color: Colors.black45),
          ),
          const SizedBox(height: 14),
          Text(
            name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          const Text(
            'Active User',
            style: TextStyle(
              color: Color(0xFF2ECC71),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tóm tắt lịch sử quét',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        Row(
          children: const [
            Expanded(
              child: _SummaryCard(
                title: 'Total scans',
                value: '125',
                valueColor: Colors.black,
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: _SummaryCard(
                title: 'Average Score',
                value: 'B+',
                valueColor: Color(0xFF2ECC71),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactRows({
    required String email,
    required String phone,
    required String location,
  }) {
    return Column(
      children: [
        _InfoRow(icon: Icons.email_outlined, label: 'Email', value: email),
        const SizedBox(height: 12),
        _InfoRow(icon: Icons.phone, label: 'Phone', value: phone),
        const SizedBox(height: 12),
        _InfoRow(icon: Icons.location_on_outlined, label: 'Location', value: location),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => context.navigateToProfileEdit(),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              side: const BorderSide(color: Color(0xFF3EBC74), width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text(
              'Edit Profile',
              style: TextStyle(
                color: Color(0xFF2ECC71),
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (!context.mounted) return;
              context.navigateToStart();
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              backgroundColor: const Color(0xFF2ECC71),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF2ECC71),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
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
            onTap: () => context.navigateToHome(),
          ),
          _FooterTab(
            icon: Icons.favorite_border,
            label: 'Favorite',
            onTap: () => _showSnackbar('Tính năng đang phát triển'),
          ),
          _FooterTab(
            icon: Icons.history,
            label: 'History',
            onTap: () => _showSnackbar('Tính năng đang phát triển'),
          ),
          _FooterTab(
            icon: Icons.person_outline,
            label: 'Profile',
            active: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.valueColor,
  });

  final String title;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0x8AF1F1F1),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, color: Colors.black87)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: valueColor),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: Colors.black87),
        const SizedBox(width: 12),
        SizedBox(
          width: 74,
          child: Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 18, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
