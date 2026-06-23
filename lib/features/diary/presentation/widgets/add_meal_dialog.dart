import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/diary_bloc.dart';
import '../bloc/diary_event.dart';
import '../../domain/entities/meal_type.dart';

void showAddMealDialog(BuildContext context, MealType mealType) {
  final nameCtrl = TextEditingController();
  final weightCtrl = TextEditingController(text: '100');
  final commentCtrl = TextEditingController();
  
  int calories = 0, protein = 0, fats = 0, carbs = 0;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Добавить в ${_mapMealTypeToRu(mealType)}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Продукт'),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: weightCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Вес (г)'),
            ),
            const SizedBox(height: 8),
            
            TextField(
              controller: commentCtrl,
              decoration: const InputDecoration(
                labelText: 'Комментарий (необязательно)',
                hintText: 'Например: с маслом',
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _NumField('Ккал', (v) => calories = v)),
                Expanded(child: _NumField('Белки', (v) => protein = v)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _NumField('Жиры', (v) => fats = v)),
                Expanded(child: _NumField('Углеводы', (v) => carbs = v)),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            final commentText = commentCtrl.text.trim();
            
            context.read<DiaryBloc>().add(
              AddMealItem(
                mealType: mealType,
                productId: 'unknown',
                productName: nameCtrl.text.trim(),
                weight: '${weightCtrl.text.trim()}г',
                calories: calories,
                protein: protein,
                fats: fats,
                carbs: carbs,
                comment: commentText.isEmpty ? null : commentText,
              ),
            );
            Navigator.pop(context);
          },
          child: const Text('Добавить'),
        ),
      ],
    ),
  );
}

String _mapMealTypeToRu(MealType type) {
  switch (type) {
    case MealType.breakfast: return 'Завтрак';
    case MealType.lunch: return 'Обед';
    case MealType.dinner: return 'Ужин';
    case MealType.snack: return 'Перекус';
  }
}

class _NumField extends StatelessWidget {
  final String label;
  final Function(int) onSaved;
  const _NumField(this.label, this.onSaved);
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      onChanged: (v) => onSaved(int.tryParse(v) ?? 0),
    );
  }
}