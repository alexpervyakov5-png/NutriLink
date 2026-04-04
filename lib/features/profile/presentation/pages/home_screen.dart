import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
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
    if (profile == null) return const SizedBox.shrink();

    return Column(
      children: [
        ProfileField(
          label: 'Имя',
          hint: 'Введите имя',
          value: profile.firstName,
          onChanged: (value) => context.read<ProfileBloc>().add(
            UpdateProfileField((p) => p.copyWith(firstName: value)),
          ),
        ),
        const SizedBox(height: 16),
        ProfileField(
          label: 'Фамилия',
          hint: 'Введите фамилию',
          value: profile.lastName,
          onChanged: (value) => context.read<ProfileBloc>().add(
            UpdateProfileField((p) => p.copyWith(lastName: value)),
          ),
        ),
        const SizedBox(height: 16),
        ProfileField(
          label: 'Дата рождения',
          hint: 'Выберите дату',
          readOnly: true,
          suffixIcon: const Icon(Icons.calendar_today, color: AppColors.textHint),
          onChanged: (_) async {
            final date = await showDatePicker(
              context: context,
              initialDate: profile.birthDate ?? DateTime(2000),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              builder: (context, child) => Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.dark(
                    primary: AppColors.accentLight,
                    onPrimary: AppColors.background,
                    surface: AppColors.backgroundSecondary,
                    onSurface: AppColors.textPrimary,
                  ),
                ),
                child: child!,
              ),
            );
            if (date != null) {
              context.read<ProfileBloc>().add(
                UpdateProfileField((p) => p.copyWith(birthDate: date)),
              );
            }
          },
        ),
        const SizedBox(height: 16),
        ProfileDropdown<int>(
          label: 'Рост',
          value: profile.heightCm,
          hint: 'Выберите рост',
          items: List.generate(41, (i) => 150 + i * 5).map((cm) {
            return DropdownMenuItem(
              value: cm,
              child: Text('$cm см'),
            );
          }).toList(),
          onChanged: (value) => context.read<ProfileBloc>().add(
            UpdateProfileField((p) => p.copyWith(heightCm: value)),
          ),
        ),
        const SizedBox(height: 16),
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
        const SizedBox(height: 16),
        ProfileField(
          label: 'Вес',
          hint: 'кг',
          keyboardType: TextInputType.number,
          value: profile.weightKg?.toString(),
          onChanged: (value) {
            final weight = double.tryParse(value);
            context.read<ProfileBloc>().add(
              UpdateProfileField((p) => p.copyWith(weightKg: weight)),
            );
          },
        ),
        const SizedBox(height: 24),
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