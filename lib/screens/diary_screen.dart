import 'package:flutter/material.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  // Раскрытые/закрытые состояния
  bool _isBreakfastExpanded = true;
  bool _isLunchExpanded = true;
  bool _isDinnerExpanded = false;
  bool _isSnackExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2F2F2F),
      child: Column(
        children: [
          // Заголовок с датой
          _buildHeader(),
          
          // Цели (БЖУК)
          _buildGoalsSection(),
          
          // Список приемов пищи
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildMealSection(
                  title: 'Завтрак',
                  icon: Icons.free_breakfast,
                  totalCalories: 3000,
                  isExpanded: _isBreakfastExpanded,
                  onExpansionChanged: (value) {
                    setState(() => _isBreakfastExpanded = value);
                  },
                  items: [
                    MealItem(
                      name: 'Очень длинное название блюда ...',
                      weight: '100 г',
                      calories: 351,
                    ),
                    MealItem(
                      name: 'Очень длинное название блюда ...',
                      weight: '100 г',
                      calories: 351,
                    ),
                  ],
                ),
                _buildMealSection(
                  title: 'Обед',
                  icon: Icons.lunch_dining,
                  totalCalories: 3000,
                  isExpanded: _isLunchExpanded,
                  onExpansionChanged: (value) {
                    setState(() => _isLunchExpanded = value);
                  },
                  items: [
                    MealItem(
                      name: 'Очень длинное название блюда ...',
                      weight: '100 г',
                      calories: 351,
                    ),
                    MealItem(
                      name: 'Очень длинное название блюда ...',
                      weight: '100 г',
                      calories: 351,
                    ),
                    MealItem(
                      name: 'Очень длинное название блюда ...',
                      weight: '100 г',
                      calories: 351,
                    ),
                    MealItem(
                      name: 'Очень длинное название блюда ...',
                      weight: '100 г',
                      calories: 351,
                    ),
                  ],
                ),
                _buildMealSection(
                  title: 'Ужин',
                  icon: Icons.dinner_dining,
                  totalCalories: 3000,
                  isExpanded: _isDinnerExpanded,
                  onExpansionChanged: (value) {
                    setState(() => _isDinnerExpanded = value);
                  },
                  items: [
                    MealItem(
                      name: 'Очень длинное название блюда ...',
                      weight: '100 г',
                      calories: 351,
                    ),
                  ],
                ),
                _buildMealSection(
                  title: 'Перекус',
                  icon: Icons.local_cafe,
                  totalCalories: 0,
                  isExpanded: _isSnackExpanded,
                  onExpansionChanged: (value) {
                    setState(() => _isSnackExpanded = value);
                  },
                  items: [],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'День',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const Text(
            '31 января 2026 г',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3F3F3F),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.calendar_today,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Цель',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildGoalIndicator(
                  label: 'Белки',
                  current: 100,
                  total: 100,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildGoalIndicator(
                  label: 'Жиры',
                  current: 65,
                  total: 65,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildGoalIndicator(
                  label: 'Углеводы',
                  current: 60,
                  total: 285,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildGoalIndicator(
                  label: 'Калории',
                  current: 1956,
                  total: 2500,
                  color: Colors.yellow,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalIndicator({
    required String label,
    required int current,
    required int total,
    required Color color,
  }) {
    final progress = current / total;
    
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$current / $total',
          style: TextStyle(
            color: current > total ? Colors.red : color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: const Color(0xFF3F3F3F),
            valueColor: AlwaysStoppedAnimation<Color>(
              current > total ? Colors.red : color,
            ),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildMealSection({
    required String title,
    required IconData icon,
    required int totalCalories,
    required bool isExpanded,
    required ValueChanged<bool> onExpansionChanged,
    required List<MealItem> items,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF3F3F3F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Заголовок приема пищи
          InkWell(
            onTap: () => onExpansionChanged(!isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Иконка
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0x69BDA0B3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: const Color(0xFF69BDA0),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Название
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  // Калории
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x69BDA0B3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$totalCalories ккал',
                      style: const TextStyle(
                        color: Color(0xFF69BDA0),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Кнопки действий
                  if (isExpanded) ...[
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3F3F3F),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline,
                        color: Color(0xFF69BDA0),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF69BDA0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                  const SizedBox(width: 4),
                  // Стрелка
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.white70,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          // Раскрывающийся контент
          if (isExpanded) ...[
            const Divider(height: 1, color: Color(0xFF3F3F3F)),
            ...items.map((item) => _buildMealItem(item)),
          ],
        ],
      ),
    );
  }

  Widget _buildMealItem(MealItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF3F3F3F), width: 1),
        ),
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
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.weight,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${item.calories} ккал',
            style: const TextStyle(
              color: Color(0xFF69BDA0),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class MealItem {
  final String name;
  final String weight;
  final int calories;

  MealItem({
    required this.name,
    required this.weight,
    required this.calories,
  });
}