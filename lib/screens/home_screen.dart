import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF3F3F3F),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Заголовок с настройками
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/icons/nutrilink.png',
                      width: 32,
                      height: 32,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'NutriLink',
                      style: TextStyle(
                        color: Color(0xFFC3F7CE),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Форма профиля
            _buildTextField(label: 'Имя', hint: 'Введите имя'),
            const SizedBox(height: 16),
            _buildTextField(label: 'Фамилия', hint: 'Введите фамилию'),
            const SizedBox(height: 16),
            _buildDatePickerField(label: 'Дата рождения'),
            const SizedBox(height: 16),
            _buildDropdownField(label: 'Рост', items: ['150 см', '155 см', '160 см', '165 см', '170 см', '175 см', '180 см', '185 см', '190 см']),
            const SizedBox(height: 16),
            _buildDropdownField(label: 'Пол', items: ['Мужской', 'Женский']),
            const SizedBox(height: 16),
            _buildTextField(label: 'Вес', hint: 'кг', keyboardType: TextInputType.number),
            const SizedBox(height: 24),
            
            // Цель
            const Text(
              'Цель',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            _buildRadioOption('Похудение', 'weight_loss'),
            _buildRadioOption('Поддержание', 'balance'),
            _buildRadioOption('Массонабор', 'fitness_center'),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required String hint, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF4A4A4A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white54),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerField({required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF4A4A4A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            readOnly: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Выберите дату',
              hintStyle: const TextStyle(color: Colors.white54),
              suffixIcon: const Icon(Icons.calendar_today, color: Colors.white54),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onTap: () async {
              // TODO: Реализовать выбор даты
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({required String label, required List<String> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF4A4A4A),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              dropdownColor: const Color(0xFF4A4A4A),
              style: const TextStyle(color: Colors.white),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
              items: items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {},
              hint: const Text('Выберите', style: TextStyle(color: Colors.white54)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOption(String label, String icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF4A4A4A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: RadioListTile<String>(
        title: Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
        value: label,
        groupValue: null, // TODO: Добавить переменную для хранения выбранного значения
        onChanged: (String? value) {},
        activeColor: const Color(0xFFC3F7CE),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}