import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/health_profile.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();

  final _nicknameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();

  String? _selectedGender;
  String? _selectedDietType;

  final List<String> _selectedDiseases = [];
  final List<String> _selectedAllergies = [];

  final List<String> _genderOptions = ['male', 'female', 'other'];
  final List<String> _dietOptions = [
    'regular',
    'vegetarian',
    'vegan',
    'keto',
    'paleo',
    'halal',
  ];
  final List<String> _diseaseOptions = [
    'Tiểu đường',
    'Cao huyết áp',
    'Tim mạch',
    'Gout',
    'Dạ dày',
    'Thận',
    'Gan',
  ];
  final List<String> _allergyOptions = [
    'Đậu phộng',
    'Sữa',
    'Trứng',
    'Hải sản',
    'Gluten',
    'Đậu nành',
    'Hạt',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(_initializeForm);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _initializeForm() async {
    final userId = context.read<AuthProvider>().user?.uid;
    if (userId != null) {
      final provider = context.read<ProfileProvider>();
      if (provider.profile == null) {
        await provider.loadProfile(userId);
      }
    }

    if (!mounted) return;

    _prefillFromProvider();
    setState(() {});
  }

  void _prefillFromProvider() {
    final profile = context.read<ProfileProvider>().profile;
    if (profile == null) return;

    _nicknameController.text = profile.nickname ?? '';
    _ageController.text = profile.age?.toString() ?? '';
    _weightController.text = profile.weight?.toString() ?? '';
    _heightController.text = profile.height?.toString() ?? '';
    _phoneController.text = profile.phone ?? '';
    _locationController.text = profile.location ?? '';
    _selectedGender = profile.gender;
    _selectedDietType = profile.dietType;

    _selectedDiseases
      ..clear()
      ..addAll(profile.diseases ?? <String>[]);
    _selectedAllergies
      ..clear()
      ..addAll(profile.allergies ?? <String>[]);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final userId = context.read<AuthProvider>().user?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _nicknameController,
                label: 'Biệt danh',
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _phoneController,
                label: 'Số điện thoại',
                icon: Icons.phone,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _locationController,
                label: 'Địa chỉ',
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _ageController,
                      label: 'Tuổi',
                      icon: Icons.cake_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildDropdown(
                      label: 'Giới tính',
                      icon: Icons.wc,
                      value: _selectedGender,
                      items: _genderOptions,
                      onChanged: (v) => setState(() => _selectedGender = v),
                      displayName: _genderText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _weightController,
                      label: 'Cân nặng (kg)',
                      icon: Icons.monitor_weight_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      controller: _heightController,
                      label: 'Chiều cao (cm)',
                      icon: Icons.height,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                label: 'Chế độ ăn',
                icon: Icons.restaurant_menu,
                value: _selectedDietType,
                items: _dietOptions,
                onChanged: (v) => setState(() => _selectedDietType = v),
                displayName: _dietText,
              ),
              const SizedBox(height: 14),
              _buildChipSelection(
                label: 'Bệnh lý',
                options: _diseaseOptions,
                selectedOptions: _selectedDiseases,
              ),
              const SizedBox(height: 14),
              _buildChipSelection(
                label: 'Dị ứng',
                options: _allergyOptions,
                selectedOptions: _selectedAllergies,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: provider.isLoading ? null : () => _saveProfile(userId),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  minimumSize: const Size.fromHeight(52),
                ),
                child: provider.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Lưu thay đổi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2ECC71)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String Function(String) displayName,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2ECC71)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(displayName(item)),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildChipSelection({
    required String label,
    required List<String> options,
    required List<String> selectedOptions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options
              .map(
                (option) => FilterChip(
                  label: Text(option),
                  selected: selectedOptions.contains(option),
                  selectedColor: const Color(0x332ECC71),
                  checkmarkColor: const Color(0xFF2ECC71),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedOptions.add(option);
                      } else {
                        selectedOptions.remove(option);
                      }
                    });
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  String _genderText(String value) {
    switch (value) {
      case 'male':
        return 'Nam';
      case 'female':
        return 'Nữ';
      case 'other':
        return 'Khác';
      default:
        return value;
    }
  }

  String _dietText(String value) {
    switch (value) {
      case 'regular':
        return 'Bình thường';
      case 'vegetarian':
        return 'Ăn chay';
      case 'vegan':
        return 'Thuần chay';
      case 'keto':
        return 'Keto';
      case 'paleo':
        return 'Paleo';
      case 'halal':
        return 'Halal';
      default:
        return value;
    }
  }

  Future<void> _saveProfile(String? userId) async {
    if (userId == null) {
      _showSnackbar('Không tìm thấy thông tin người dùng', isError: true);
      return;
    }

    final profile = HealthProfile(
      userId: userId,
      nickname: _nicknameController.text.trim().isEmpty
          ? null
          : _nicknameController.text.trim(),
      age: int.tryParse(_ageController.text),
      gender: _selectedGender,
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      weight: double.tryParse(_weightController.text),
      height: double.tryParse(_heightController.text),
      diseases: _selectedDiseases.isEmpty ? null : _selectedDiseases,
      allergies: _selectedAllergies.isEmpty ? null : _selectedAllergies,
      dietType: _selectedDietType,
    );

    final success = await context.read<ProfileProvider>().saveProfile(profile);
    if (!mounted) return;

    if (success) {
      _showSnackbar('Cập nhật hồ sơ thành công');
      Navigator.of(context).pop();
    } else {
      _showSnackbar('Không thể lưu hồ sơ. Vui lòng thử lại.', isError: true);
    }
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
}
