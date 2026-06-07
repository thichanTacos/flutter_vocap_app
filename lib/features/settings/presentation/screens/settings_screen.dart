import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/providers/app_settings_provider.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../auth/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;
    final settings = ref.watch(appSettingsProvider).valueOrNull ??
        const AppSettings();

    final email = user?.email ?? '';
    final displayName = user?.displayName ??
        (email.isNotEmpty ? email.split('@')[0] : 'Người dùng');
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    final isDark = settings.isDark;
    final bgColor = isDark ? AppTheme.darkBg : AppTheme.lightBg;
    final cardColor = isDark ? AppTheme.darkCard : AppTheme.cardBg;
    final titleColor = isDark ? Colors.white : AppTheme.textDark;
    final subColor =
        isDark ? Colors.white54 : AppTheme.textMedium;
    final divColor =
        isDark ? AppTheme.darkDivider : AppTheme.dividerColor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: titleColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Cài đặt',
          style: TextStyle(
            color: titleColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // ── Tài khoản ──────────────────────────────────
          _SectionHeader(label: 'Tài khoản', isDark: isDark),
          _Card(
            color: cardColor,
            dividerColor: divColor,
            children: [
              // Tên người dùng
              _AccountNameTile(
                initial: initial,
                displayName: displayName,
                titleColor: titleColor,
                subColor: subColor,
                isDark: isDark,
                onEdit: () => _showEditNameDialog(
                  context,
                  ref,
                  displayName,
                  isDark,
                  cardColor,
                  titleColor,
                  subColor,
                ),
              ),
              Divider(height: 1, color: divColor),
              // Email
              _SettingsTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.email_outlined,
                    color: AppTheme.blue,
                    size: 18,
                  ),
                ),
                title: 'Email',
                subtitle: email.isNotEmpty ? email : '—',
                titleColor: titleColor,
                subColor: subColor,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Giao diện ──────────────────────────────────
          _SectionHeader(label: 'Giao diện', isDark: isDark),
          _Card(
            color: cardColor,
            dividerColor: divColor,
            children: [
              _SettingsTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.purple.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isDark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    color: AppTheme.purple,
                    size: 18,
                  ),
                ),
                title: 'Chế độ tối',
                subtitle: isDark ? 'Đang bật' : 'Đang tắt',
                titleColor: titleColor,
                subColor: subColor,
                trailing: Switch(
                  value: isDark,
                  activeThumbColor: AppTheme.purple,
                  activeTrackColor: AppTheme.purple.withValues(alpha: 0.4),
                  onChanged: (_) =>
                      ref.read(appSettingsProvider.notifier).toggleTheme(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Học tập ────────────────────────────────────
          _SectionHeader(label: 'Học tập', isDark: isDark),
          _Card(
            color: cardColor,
            dividerColor: divColor,
            children: [
              _SettingsTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    settings.soundEnabled
                        ? Icons.volume_up_rounded
                        : Icons.volume_off_rounded,
                    color: AppTheme.secondary,
                    size: 18,
                  ),
                ),
                title: 'Hiệu ứng âm thanh',
                subtitle: settings.soundEnabled ? 'Đang bật' : 'Đang tắt',
                titleColor: titleColor,
                subColor: subColor,
                trailing: Switch(
                  value: settings.soundEnabled,
                  activeThumbColor: AppTheme.secondary,
                  activeTrackColor: AppTheme.secondary.withValues(alpha: 0.4),
                  onChanged: (_) =>
                      ref.read(appSettingsProvider.notifier).toggleSound(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showEditNameDialog(
    BuildContext context,
    WidgetRef ref,
    String currentName,
    bool isDark,
    Color cardColor,
    Color titleColor,
    Color subColor,
  ) {
    final controller = TextEditingController(text: currentName);
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : AppTheme.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Chỉnh sửa tên',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  autofocus: true,
                  maxLength: 30,
                  style: TextStyle(color: titleColor, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Nhập tên hiển thị',
                    hintStyle: TextStyle(color: subColor),
                    filled: true,
                    fillColor: isDark
                        ? AppTheme.darkSurface
                        : AppTheme.surfaceColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppTheme.primary, width: 2),
                    ),
                    counterStyle: TextStyle(color: subColor),
                    prefixIcon: const Icon(Icons.person_outline_rounded,
                        color: AppTheme.primary),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: saving
                        ? null
                        : () async {
                            final name = controller.text.trim();
                            if (name.isEmpty) return;
                            setState(() => saving = true);
                            final ok = await ref
                                .read(authNotifierProvider.notifier)
                                .updateDisplayName(name);
                            if (ctx.mounted) {
                              Navigator.of(ctx).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(ok
                                      ? 'Đã cập nhật tên thành công!'
                                      : 'Cập nhật thất bại, thử lại sau'),
                                  backgroundColor:
                                      ok ? AppTheme.green : Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Lưu',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Section Header ─────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionHeader({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: isDark ? Colors.white38 : AppTheme.textLight,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ── Card wrapper ───────────────────────────────────────────────────────────────
class _Card extends StatelessWidget {
  final Color color;
  final Color dividerColor;
  final List<Widget> children;

  const _Card({
    required this.color,
    required this.dividerColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

// ── Account name tile ──────────────────────────────────────────────────────────
class _AccountNameTile extends StatelessWidget {
  final String initial;
  final String displayName;
  final Color titleColor;
  final Color subColor;
  final bool isDark;
  final VoidCallback onEdit;

  const _AccountNameTile({
    required this.initial,
    required this.displayName,
    required this.titleColor,
    required this.subColor,
    required this.isDark,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onEdit,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.tealGradient,
              ),
              child: Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Chạm để chỉnh sửa',
                    style: TextStyle(color: subColor, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit_rounded, color: AppTheme.primary, size: 18),
          ],
        ),
      ),
    );
  }
}

// ── Generic settings tile ──────────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color titleColor;
  final Color subColor;

  const _SettingsTile({
    required this.leading,
    required this.title,
    required this.titleColor,
    required this.subColor,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(color: subColor, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
