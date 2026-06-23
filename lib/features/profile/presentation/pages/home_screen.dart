import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/utils/constants.dart';
import '../../domain/entities/profile.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_field.dart';
import '../widgets/profile_dropdown.dart';
import '../widgets/profile_radio.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundSecondary,
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          // ✅ Индикатор загрузки
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // ✅ Обработка ошибок
          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Ошибка: ${state.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ProfileBloc>().add(LoadProfile()),
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }
          
          // ✅ Основная форма
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildForm(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, ProfileState state) {
    final profile = state.profile;
    
    // Защита от null
    if (profile == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('Загрузка данных...', style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    // 🔍 Отладочный лог
    if (kDebugMode) {
      debugPrint('🎨 Отрисовка формы: ${profile.firstName} ${profile.lastName}');
    }

    return Column(
      children: [
        // 👤 Имя
        ProfileField(
          label: 'Имя',
          hint: 'Введите имя',
          value: profile.firstName,
          onChanged: (value) => context.read<ProfileBloc>().add(
            UpdateProfileField((p) => p.copyWith(firstName: value)),
          ),
        ),
        const SizedBox(height: 16),

        // 👤 Фамилия
        ProfileField(
          label: 'Фамилия',
          hint: 'Введите фамилию',
          value: profile.lastName,
          onChanged: (value) => context.read<ProfileBloc>().add(
            UpdateProfileField((p) => p.copyWith(lastName: value)),
          ),
        ),
        const SizedBox(height: 16),

        // 📅 Дата рождения — В СТИЛЕ ОСТАЛЬНЫХ ПОЛЕЙ
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Лейбл сверху (как у всех полей)
            const Text(
              'Дата рождения',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 8),
            
            // Кликабельное поле (стиль как у ProfileField)
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: profile.birthDate ?? DateTime(2000),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.dark(
                          primary: AppColors.accentLight,
                          onPrimary: AppColors.background,
                          surface: AppColors.backgroundSecondary,
                          onSurface: AppColors.textPrimary,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                
                if (!context.mounted) return;
                
                if (picked != null) {
                  context.read<ProfileBloc>().add(
                    UpdateProfileField((p) => p.copyWith(birthDate: picked)),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        profile.birthDate != null
                            ? '${profile.birthDate!.day}.${profile.birthDate!.month}.${profile.birthDate!.year}'
                            : 'Выберите дату',
                        style: TextStyle(
                          color: profile.birthDate != null 
                              ? AppColors.textPrimary 
                              : AppColors.textHint,
                        ),
                      ),
                    ),
                    const Icon(Icons.calendar_today, color: AppColors.textHint, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 📏 Рост
        ProfileDropdown<int>(
          label: 'Рост',
          value: profile.heightCm,
          hint: 'Выберите рост',
          items: List.generate(41, (i) => 150 + i * 5).map((cm) {
            return DropdownMenuItem(value: cm, child: Text('$cm см'));
          }).toList(),
          onChanged: (value) => context.read<ProfileBloc>().add(
            UpdateProfileField((p) => p.copyWith(heightCm: value)),
          ),
        ),
        const SizedBox(height: 16),

        // ⚧ Пол
        ProfileDropdown<String>(
          label: 'Пол',
          value: profile.gender,
          hint: 'Выберите пол',
          items: const [
            DropdownMenuItem(value: 'Мужской', child: Text('Мужской')),
            DropdownMenuItem(value: 'Женский', child: Text('Женский')),
          ],
          onChanged: (value) => context.read<ProfileBloc>().add(
            UpdateProfileField((p) => p.copyWith(gender: value)),
          ),
        ),
        const SizedBox(height: 24),

        // 🎯 Цель
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Цель', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        ),
        const SizedBox(height: 8),
        
        ProfileRadio<GoalType>(
          label: 'Похудение',
          icon: Icons.trending_down,
          value: GoalType.weightLoss,
          groupValue: profile.goal,
          onChanged: (value) => context.read<ProfileBloc>().add(
            UpdateProfileField((p) => p.copyWith(goal: value)),
          ),
        ),
        ProfileRadio<GoalType>(
          label: 'Поддержание',
          icon: Icons.balance,
          value: GoalType.maintenance,
          groupValue: profile.goal,
          onChanged: (value) => context.read<ProfileBloc>().add(
            UpdateProfileField((p) => p.copyWith(goal: value)),
          ),
        ),
        ProfileRadio<GoalType>(
          label: 'Массонабор',
          icon: Icons.fitness_center,
          value: GoalType.muscleGain,
          groupValue: profile.goal,
          onChanged: (value) => context.read<ProfileBloc>().add(
            UpdateProfileField((p) => p.copyWith(goal: value)),
          ),
        ),
        const SizedBox(height: 24),

        // 💾 Кнопка сохранения
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: state.isSaving ? null : () => context.read<ProfileBloc>().add(SaveProfile()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: state.isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Сохранить', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}