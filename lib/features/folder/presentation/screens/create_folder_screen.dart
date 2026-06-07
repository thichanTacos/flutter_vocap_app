import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_ink_well.dart';
import '../../providers/folder_provider.dart';

class CreateFolderScreen extends ConsumerStatefulWidget {
  const CreateFolderScreen({super.key});

  @override
  ConsumerState<CreateFolderScreen> createState() =>
      _CreateFolderScreenState();
}

class _CreateFolderScreenState extends ConsumerState<CreateFolderScreen> {
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_titleController.text.trim().isEmpty) return;
    final success = await ref
        .read(folderNotifierProvider.notifier)
        .createFolder(title: _titleController.text.trim());
    if (success && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(folderNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: context.colors.bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: context.colors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('Tạo thư mục',
            style: TextStyle(
                color: context.colors.textPrimary, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: isLoading
                ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: context.colors.textPrimary, strokeWidth: 2))
                : Icon(Icons.check, color: context.colors.textPrimary),
            onPressed: isLoading ? null : _create,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              style: TextStyle(color: context.colors.textPrimary, fontSize: 18),
              decoration: InputDecoration(
                hintText: 'Tên thư mục',
                hintStyle: TextStyle(color: context.colors.textSecondary),
                filled: true,
                fillColor: context.colors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                  const BorderSide(color: AppTheme.primary, width: 2),
                ),
                prefixIcon: const Icon(Icons.folder_outlined,
                    color: Color(0xFF00C9B1)),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Thư mục giúp bạn sắp xếp các học phần liên quan vào cùng một nơi.',
              style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 32),
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
                child: const Center(
                  child: Text('Tạo thư mục',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
