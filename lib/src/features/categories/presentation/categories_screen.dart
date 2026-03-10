import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_theme.dart';
import '../domain/category_model.dart';
import 'categories_providers.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCats = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // خلفية فاتحة مريحة للعين
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Categories',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: AppTheme.textDark,
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.violetPrimary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _openEditor(context, ref),
          backgroundColor: AppTheme.violetPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: const Icon(Icons.add_rounded, size: 30),
        ),
      ),
      body: Stack(
        children: [
          // اللمسات الفنية في الخلفية (Decorative Glows)
          Positioned(
            top: -100,
            right: -50,
            child: _GlowCircle(
              color: AppTheme.violetPrimary.withOpacity(0.07),
              size: 400,
            ),
          ),
          Positioned(
            bottom: 100,
            left: -100,
            child: _GlowCircle(
              color: AppTheme.tealSuccess.withOpacity(0.05),
              size: 350,
            ),
          ),

          // محتوى الصفحة
          SafeArea(
            child: asyncCats.when(
              data: (cats) {
                if (cats.isEmpty) {
                  return const _EmptyCategoriesState();
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                  itemCount: cats.length,
                  physics: const BouncingScrollPhysics(),
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, i) {
                    final c = cats[i];
                    return _CategoryCard(category: c, ref: ref);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openEditor(BuildContext context, WidgetRef ref, {ExpenseCategory? category}) async {
    final result = await showModalBottomSheet<ExpenseCategory>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (_) => _CategoryEditorSheet(initial: category),
    );

    if (result == null) return;
    await ref.read(categoriesRepositoryProvider).upsert(result);
  }
}

class _CategoryCard extends StatelessWidget {
  final ExpenseCategory category;
  final WidgetRef ref;

  const _CategoryCard({required this.category, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(category.id),
      direction: category.id == 'other' ? DismissDirection.none : DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: AppTheme.pinkAlert.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete_sweep_rounded, color: AppTheme.pinkAlert, size: 28),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            title: Text('Delete Category', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
            content: Text('Remove “${category.name}”? Transactions will be moved to “Other”.', style: GoogleFonts.plusJakartaSans(fontSize: 14)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontWeight: FontWeight.w700)),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(backgroundColor: AppTheme.pinkAlert),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) => ref.read(categoriesRepositoryProvider).delete(category.id),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => _openEditor(context, category: category),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _CategoryIcon(iconKey: category.icon),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          category.id.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            color: AppTheme.textMuted.withOpacity(0.6),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 22),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openEditor(BuildContext context, {ExpenseCategory? category}) {
    // Re-use logic from parent class if needed, or trigger callback
    (context.findAncestorWidgetOfExactType<CategoriesScreen>())
        ?._openEditor(context, ref, category: category);
  }
}

class _GlowCircle extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0)],
        ),
      ),
    );
  }
}

class _EmptyCategoriesState extends StatelessWidget {
  const _EmptyCategoriesState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.greySecondary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20),
              ],
            ),
            child: const Icon(Icons.category_outlined, size: 64, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 32),
          Text(
            'No Categories Found',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 20, color: AppTheme.textDark),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Add your first category to start tracking your expenses effectively.',
              style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 14, height: 1.6),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryEditorSheet extends StatefulWidget {
  const _CategoryEditorSheet({this.initial});
  final ExpenseCategory? initial;

  @override
  State<_CategoryEditorSheet> createState() => _CategoryEditorSheetState();
}

class _CategoryEditorSheetState extends State<_CategoryEditorSheet> {
  late final TextEditingController _name;
  late final TextEditingController _id;
  String _icon = 'other';

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initial?.name ?? '');
    _id = TextEditingController(text: widget.initial?.id ?? '');
    _icon = widget.initial?.icon ?? 'other';
  }

  @override
  void dispose() {
    _name.dispose();
    _id.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final isEdit = widget.initial != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 8, 24, bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isEdit ? 'Update Category' : 'Create Category',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 22),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildLabel('NAME'),
          const SizedBox(height: 8),
          TextField(
            controller: _name,
            textInputAction: TextInputAction.next,
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'e.g. Health & Fitness',
              fillColor: AppTheme.greySecondary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          _buildLabel('ICON'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.greySecondary.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.textDark.withOpacity(0.05)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _icon,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textMuted),
                borderRadius: BorderRadius.circular(20),
                dropdownColor: Colors.white,
                items: const [
                  DropdownMenuItem(value: 'food', child: Text('Food')),
                  DropdownMenuItem(value: 'coffee', child: Text('Coffee')),
                  DropdownMenuItem(value: 'groceries', child: Text('Groceries')),
                  DropdownMenuItem(value: 'transport', child: Text('Transport')),
                  DropdownMenuItem(value: 'shopping', child: Text('Shopping')),
                  DropdownMenuItem(value: 'bills', child: Text('Bills')),
                  DropdownMenuItem(value: 'fun', child: Text('Entertainment')),
                  DropdownMenuItem(value: 'health', child: Text('Health')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (v) => setState(() => _icon = v ?? 'other'),
              ),
            ),
          ),
          if (!isEdit) ...[
            const SizedBox(height: 24),
            _buildLabel('UNIQUE ID'),
            const SizedBox(height: 8),
            TextField(
              controller: _id,
              textInputAction: TextInputAction.done,
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'e.g. fitness',
                fillColor: AppTheme.greySecondary.withOpacity(0.5),
              ),
            ),
          ],
          const SizedBox(height: 40),
          SizedBox(
            height: 60,
            child: FilledButton(
              onPressed: () {
                final name = _name.text.trim();
                final id = isEdit ? widget.initial!.id : _id.text.trim().toLowerCase();
                if (name.isEmpty || id.isEmpty) return;

                Navigator.pop(
                  context,
                  ExpenseCategory(
                    id: id,
                    name: name,
                    icon: _icon,
                    order: widget.initial?.order ?? 50,
                  ),
                );
              },
              child: Text(isEdit ? 'Apply Changes' : 'Create Category'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: AppTheme.textMuted,
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.iconKey});
  final String iconKey;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (iconKey) {
      case 'food': icon = Icons.restaurant_rounded; break;
      case 'coffee': icon = Icons.local_cafe_rounded; break;
      case 'groceries': icon = Icons.shopping_cart_rounded; break;
      case 'transport': icon = Icons.directions_car_rounded; break;
      case 'shopping': icon = Icons.shopping_bag_rounded; break;
      case 'bills': icon = Icons.receipt_long_rounded; break;
      case 'fun': icon = Icons.celebration_rounded; break;
      case 'health': icon = Icons.favorite_rounded; break;
      default: icon = Icons.category_rounded;
    }

    return Container(
      height: 52,
      width: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.violetPrimary.withOpacity(0.12),
            AppTheme.violetPrimary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: AppTheme.violetPrimary, size: 24),
    );
  }
}
