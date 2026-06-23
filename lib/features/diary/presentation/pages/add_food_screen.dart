import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/entities/meal_type.dart';
import '../bloc/diary_bloc.dart';
import '../bloc/diary_event.dart';
import 'manual_add_screen.dart';

class AddFoodScreen extends StatefulWidget {
  final MealType mealType;

  const AddFoodScreen({super.key, required this.mealType});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _searchController = TextEditingController();
  List<_SearchItem> _searchResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // ✅ Загружаем список продуктов сразу при открытии экрана
    _searchInSupabase('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Добавить продукт', style: TextStyle(color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 🔍 Поиск + кнопка "+"
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.background,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Поиск еды...',
                        hintStyle: TextStyle(color: AppColors.textHint),
                        prefixIcon: Icon(Icons.search, color: AppColors.textHint),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        // ✅ Всегда вызываем поиск, даже при пустой строке
                        _searchInSupabase(value.trim());
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // ✅ Кнопка ручного добавления
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.black),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManualAddScreen(mealType: widget.mealType),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // 📋 Список результатов
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.isEmpty
                              ? 'Список продуктов пуст'
                              : 'Ничего не найдено',
                          style: const TextStyle(color: AppColors.textHint),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final item = _searchResults[index];
                          return _buildProductItem(item);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(_SearchItem item) {
    return InkWell(
      onTap: () => _addProduct(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${item.calories} ккал / 100г',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.accentTransparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.add, color: AppColors.accent, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ ПОИСК В SUPABASE (Общие + Свои) — БЕЗ ilike, фильтрация в Dart
  Future<void> _searchInSupabase(String query) async {
    setState(() => _isLoading = true);
    
    try {
      final userId = SupabaseConfig.client.auth.currentUser?.id;
      
      // ✅ Базовый запрос: только фильтр по пользователю и лимит
      // Фильтр по имени делаем в коде Dart — надёжнее и без ошибок типов
      final response = await SupabaseConfig.client
          .from('products')
          .select()
          // Фильтр: (user_id пустой ИЛИ user_id совпадает с моим)
          .or('user_id.is.null,user_id.eq.$userId')
          .limit(100); // ✅ Увеличили лимит для лучшего покрытия

      final List<dynamic> data = response as List<dynamic>;
      
      // ✅ Фильтрация по названию в коде Dart (регистронезависимая)
      final List<_SearchItem> allProducts = data.map((json) => _SearchItem(
        id: json['id'] ?? '',
        name: json['name'] as String,
        calories: (json['calories'] ?? 0).toDouble(),
        protein: (json['protein'] ?? 0).toDouble(),
        fats: (json['fat'] ?? 0).toDouble(),
        carbs: (json['carbs'] ?? 0).toDouble(),
        weight: 100,
      )).toList();

      final filteredProducts = query.isEmpty
          ? allProducts
          : allProducts.where((p) => 
              p.name.toLowerCase().contains(query.toLowerCase())
            ).toList();

      setState(() {
        _searchResults = filteredProducts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('❌ Ошибка поиска: $e');
    }
  }

  void _addProduct(_SearchItem item) {
    context.read<DiaryBloc>().add(
      AddMealItem(
        mealType: widget.mealType,
        productId: item.id,
        productName: item.name,
        weight: '${item.weight}г',
        calories: item.calories.round(),
        protein: item.protein.round(),
        fats: item.fats.round(),
        carbs: item.carbs.round(),
      ),
    );
    
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ ${item.name} добавлен'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _SearchItem {
  final String id;
  final String name;
  final double calories;
  final double protein;
  final double fats;
  final double carbs;
  final int weight;

  _SearchItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.fats,
    required this.carbs,
    required this.weight,
  });
}