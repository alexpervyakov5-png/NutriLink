import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/entities/meal_type.dart';
import '../bloc/diary_bloc.dart';
import '../bloc/diary_event.dart';

class ManualAddScreen extends StatefulWidget {
  final MealType mealType;

  const ManualAddScreen({super.key, required this.mealType});

  @override
  State<ManualAddScreen> createState() => _ManualAddScreenState();
}

class _ManualAddScreenState extends State<ManualAddScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _weightController = TextEditingController(text: '100');
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _fatsController = TextEditingController();
  final _carbsController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _fatsController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Добавить вручную', style: TextStyle(color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputField(
                controller: _nameController,
                label: 'Название продукта',
                hint: 'Например: Торт от Бабушки',
                validator: (v) => (v?.isEmpty ?? true) ? 'Введите название' : null,
              ),
              const SizedBox(height: 16),

              _buildInputField(
                controller: _weightController,
                label: 'Сколько съели (г)',
                hint: '100',
                keyboardType: TextInputType.number,
                validator: (v) {
                  final w = int.tryParse(v ?? '');
                  if (w == null || w <= 0) return 'Введите вес больше 0';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              const Text(
                'Пищевая ценность на 100г (для сохранения в базу)',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildKBJUField(_caloriesController, 'Ккал', const Color(0xFFF44336))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildKBJUField(_proteinController, 'Белки', const Color(0xFF4CAF50))),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildKBJUField(_fatsController, 'Жиры', const Color(0xFFFF9800))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildKBJUField(_carbsController, 'Углеводы', const Color(0xFF2196F3))),
                ],
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Добавить и сохранить',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: AppColors.textHint), border: InputBorder.none),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildKBJUField(TextEditingController controller, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
            decoration: const InputDecoration(hintText: '0', hintStyle: TextStyle(color: AppColors.textHint), border: InputBorder.none, contentPadding: EdgeInsets.zero),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final weight = int.tryParse(_weightController.text) ?? 100;
    final caloriesPer100 = double.tryParse(_caloriesController.text) ?? 0;
    final proteinPer100 = double.tryParse(_proteinController.text) ?? 0;
    final fatsPer100 = double.tryParse(_fatsController.text) ?? 0;
    final carbsPer100 = double.tryParse(_carbsController.text) ?? 0;

    // 1. Считаем значения для указанного веса
    final multiplier = weight / 100;
    final totalCalories = (caloriesPer100 * multiplier).round();
    final totalProtein = (proteinPer100 * multiplier).round();
    final totalFats = (fatsPer100 * multiplier).round();
    final totalCarbs = (carbsPer100 * multiplier).round();

    // 2. Добавляем приём пищи в Дневник (BLoC)
    context.read<DiaryBloc>().add(
      AddMealItem(
        mealType: widget.mealType,
        productId: DateTime.now().millisecondsSinceEpoch.toString(),
        productName: name,
        weight: '${weight}г',
        calories: totalCalories,
        protein: totalProtein,
        fats: totalFats,
        carbs: totalCarbs,
      ),
    );

    // 3. СОХРАНЯЕМ ПРОДУКТ В БАЗУ (как личный продукт пользователя)
    final userId = SupabaseConfig.client.auth.currentUser?.id;
    if (userId != null) {
      try {
        await SupabaseConfig.client.from('products').insert({
          'name': name,
          'calories': caloriesPer100, // Сохраняем "на 100г"
          'protein': proteinPer100,
          'fat': fatsPer100,
          'carbs': carbsPer100,
          'user_id': userId, // 🔥 Привязка к текущему пользователю!
        }).maybeSingle();
      } catch (e) {
        debugPrint('⚠️ Не удалось сохранить продукт в базу (возможно, дубликат): $e');
      }
    }

    // 4. Закрываем экран
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ $name добавлен и сохранён'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}