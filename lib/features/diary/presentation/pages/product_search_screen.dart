import 'package:flutter/material.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/entities/meal.dart';
import 'product_detail_screen.dart';
import '../../domain/entities/meal_type.dart';
import '../../domain/entities/daily_goals.dart';

class ProductSearchScreen extends StatefulWidget {
  final MealType mealType;

  const ProductSearchScreen({super.key, required this.mealType});

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final _searchController = TextEditingController();
  final List<String> _recentSearches = ['Картофель', 'Рис', 'Творог', 'Молоко', 'Яблоко'];
  List<String> _searchResults = [];
  bool _isSearching = false;

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
        title: const Text(
          'Поиск продуктов',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 🔍 Поле поиска
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
                        hintText: 'Поиск еды',
                        hintStyle: TextStyle(color: AppColors.textHint),
                        prefixIcon: Icon(Icons.search, color: AppColors.textHint),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _isSearching = value.isNotEmpty;
                          _searchResults = _searchProducts(value);
                        });
                      },
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textHint),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _isSearching = false;
                        _searchResults = [];
                      });
                    },
                  ),
              ],
            ),
          ),
          
          // 📋 Результаты или недавние поиски
          Expanded(
            child: _isSearching ? _buildSearchResults() : _buildRecentSearches(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _recentSearches.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.history, color: AppColors.textHint),
          title: Text(
            _recentSearches[index],
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          subtitle: const Text('100 г • 100 ккал', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          onTap: () {
            _searchController.text = _recentSearches[index];
            setState(() {
              _isSearching = true;
              _searchResults = _searchProducts(_recentSearches[index]);
            });
          },
        );
      },
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, color: AppColors.textHint, size: 48),
            const SizedBox(height: 16),
            Text(
              'Продукты не найдены',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final product = _searchResults[index];
        return ListTile(
          title: Text(product, style: const TextStyle(color: AppColors.textPrimary)),
          subtitle: const Text('100 г • 100 ккал', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(
                  productName: product,
                  mealType: widget.mealType,
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<String> _searchProducts(String query) {
    final allProducts = [
      'Яблоко', 'Банан', 'Куриная грудка', 'Рис', 'Гречка',
      'Творог', 'Молоко', 'Хлеб', 'Яйцо', 'Овсянка',
      'Лосось', 'Индейка', 'Говядина', 'Картофель', 'Брокколи',
      'Огурец', 'Помидор', 'Авокадо', 'Орехи', 'Мёд',
    ];
    return allProducts
        .where((p) => p.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}