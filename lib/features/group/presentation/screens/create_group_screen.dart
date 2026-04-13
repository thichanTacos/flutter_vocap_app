import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_ink_well.dart';
import '../../providers/group_provider.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() =>
      _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _inviteController = TextEditingController();
  bool _showJoin = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _inviteController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_nameController.text.trim().isEmpty) return;
    final group = await ref.read(groupNotifierProvider.notifier).createGroup(
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
    );
    if (group != null && mounted) {
      // Hiện invite code
      _showInviteCode(group.inviteCode);
    }
  }

  Future<void> _join() async {
    if (_inviteController.text.trim().isEmpty) return;
    try {
      final groupId = await ref
          .read(groupNotifierProvider.notifier)
          .joinGroup(_inviteController.text.trim());
      if (!mounted) return;
      if (groupId != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Tham gia nhóm thành công!'),
          backgroundColor: Colors.green,
        ));
        // Đóng màn hình tạo/tham gia rồi điều hướng thẳng vào group
        context.pop();
        context.push('/group/$groupId');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Mã mời không hợp lệ hoặc không tìm thấy nhóm'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Lỗi: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _showInviteCode(String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2D3E),
        title: const Text('Nhóm đã được tạo! 🎉',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Chia sẻ mã mời này để mời thành viên:',
                style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1D28),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    code,
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 6,
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.white70),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã copy mã mời!')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          AppInkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              Navigator.pop(ctx);
              context.pop();
            },
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Xong',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(groupNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1D28),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D28),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('Nhóm học',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tab Tạo / Tham gia
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2A2D3E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AppInkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => setState(() => _showJoin = false),
                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_showJoin
                              ? AppTheme.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text('Tạo nhóm',
                              style: TextStyle(
                                color: !_showJoin
                                    ? Colors.white
                                    : Colors.grey[400],
                                fontWeight: FontWeight.w600,
                              )),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: AppInkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => setState(() => _showJoin = true),
                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _showJoin
                              ? AppTheme.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text('Tham gia',
                              style: TextStyle(
                                color: _showJoin
                                    ? Colors.white
                                    : Colors.grey[400],
                                fontWeight: FontWeight.w600,
                              )),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (!_showJoin) ...[
              // Form tạo nhóm
              TextField(
                controller: _nameController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDeco('Tên nhóm *', Icons.group_outlined),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _descController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration:
                _inputDeco('Mô tả nhóm', Icons.description_outlined),
              ),
              const SizedBox(height: 24),
              AppInkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: isLoading ? null : _create,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: isLoading
                        ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                        : const Text('Tạo nhóm',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ] else ...[
              // Form tham gia nhóm
              TextField(
                controller: _inviteController,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    letterSpacing: 4,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.characters,
                maxLength: 6,
                decoration: InputDecoration(
                  hintText: 'XXXXXX',
                  hintStyle: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 20,
                      letterSpacing: 4),
                  filled: true,
                  fillColor: const Color(0xFF2A2D3E),
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppTheme.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Nhập mã gồm 6 ký tự do người tạo nhóm cung cấp',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
              const SizedBox(height: 24),
              AppInkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: isLoading ? null : _join,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: isLoading
                        ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                        : const Text('Tham gia nhóm',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[500]),
        filled: true,
        fillColor: const Color(0xFF2A2D3E),
        prefixIcon: Icon(icon, color: Colors.grey[500]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: AppTheme.primary, width: 2),
        ),
      );
}