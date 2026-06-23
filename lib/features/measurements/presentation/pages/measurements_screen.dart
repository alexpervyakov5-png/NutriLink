import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/entities/measurement.dart';
import '../bloc/measurements_bloc.dart';
import '../bloc/measurements_event.dart';
import '../bloc/measurements_state.dart';
import '../widgets/measurement_field.dart';

class MeasurementsScreen extends StatelessWidget {
  const MeasurementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundSecondary,
      child: BlocBuilder<MeasurementsBloc, MeasurementsState>(
        builder: (context, state) {
          if (state.isLoading && state.measurements.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null && state.error!.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red[300], size: 48),
                  const SizedBox(height: 16),
                  Text(
                    state.error!,
                    style: const TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<MeasurementsBloc>().add(LoadMeasurements());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: state.measurements.isEmpty
                    ? _buildEmptyState()
                    : _buildMeasurementsList(context, state),
              ),
              _buildAddButton(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.straighten,
            size: 48,
            color: AppColors.textHint.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Нет данных',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Добавьте первый замер',
            style: TextStyle(
              color: AppColors.textHint,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementsList(BuildContext context, MeasurementsState state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.measurements.length,
      itemBuilder: (context, index) {
        final measurement = state.measurements[index];
        return _buildMeasurementCard(context, measurement);
      },
    );
  }

  Widget _buildMeasurementCard(BuildContext context, Measurement measurement) {
    return Dismissible(
      key: Key(measurement.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.red,
          size: 24,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.background,
            title: const Text(
              'Удалить замер?',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: Text(
              'Дата: ${_formatDateRu(measurement.measuredAt)}',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Отмена', style: TextStyle(color: AppColors.textHint)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Удалить', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        context.read<MeasurementsBloc>().add(DeleteMeasurement(id: measurement.id));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Замер удалён'),
            backgroundColor: AppColors.background,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
            margin: EdgeInsets.all(16),
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showEditMeasurementDialog(context, measurement),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _formatDateRu(measurement.measuredAt),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.edit,
                      size: 16,
                      color: AppColors.textHint.withOpacity(0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                
                Row(
                  children: [
                    if (measurement.weightKg != null)
                      Expanded(child: _buildStat('Вес', '${measurement.weightKg} кг')),
                    if (measurement.chestCm != null)
                      Expanded(child: _buildStat('Грудь', '${measurement.chestCm}')),
                    if (measurement.waistCm != null)
                      Expanded(child: _buildStat('Талия', '${measurement.waistCm}')),
                    if (measurement.hipsCm != null)
                      Expanded(child: _buildStat('Бёдра', '${measurement.hipsCm}')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textHint,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, MeasurementsState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppColors.backgroundSecondary,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: state.isLoading 
            ? null
            : () => _showAddMeasurementDialog(context, state),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: state.isLoading ? AppColors.backgroundSecondary : AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: state.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Добавить замер',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddMeasurementDialog(BuildContext context, MeasurementsState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundSecondary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _MeasurementForm(
        measurement: null,
        selectedDate: state.selectedDate,
      ),
    );
  }

  void _showEditMeasurementDialog(BuildContext context, Measurement measurement) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundSecondary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _MeasurementForm(
        measurement: measurement,
        selectedDate: measurement.measuredAt,
      ),
    );
  }

  String _formatDateRu(DateTime date) {
    const months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year} г';
  }
}

class _MeasurementForm extends StatefulWidget {
  final Measurement? measurement;
  final DateTime selectedDate;

  const _MeasurementForm({
    this.measurement,
    required this.selectedDate,
  });

  @override
  State<_MeasurementForm> createState() => _MeasurementFormState();
}

class _MeasurementFormState extends State<_MeasurementForm> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  final _weightController = TextEditingController();
  final _chestController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    
    if (widget.measurement != null) {
      _weightController.text = widget.measurement!.weightKg?.toStringAsFixed(1) ?? '';
      _chestController.text = widget.measurement!.chestCm?.toString() ?? '';
      _waistController.text = widget.measurement!.waistCm?.toString() ?? '';
      _hipsController.text = widget.measurement!.hipsCm?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _chestController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.measurement != null;
    
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 32,
                height: 3,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.textHint.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            Text(
              isEdit ? 'Редактировать' : 'Новый замер',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            
            _buildDateSelector(),
            const SizedBox(height: 20),
            
            MeasurementField(
              controller: _weightController,
              label: 'Вес',
              hint: '0',
              icon: Icons.monitor_weight,
              suffix: 'кг',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 14),
            MeasurementField(
              controller: _chestController,
              label: 'Грудь',
              hint: '0',
              icon: Icons.check_box_outline_blank,
              suffix: 'см',
            ),
            const SizedBox(height: 14),
            MeasurementField(
              controller: _waistController,
              label: 'Талия',
              hint: '0',
              icon: Icons.line_axis,
              suffix: 'см',
            ),
            const SizedBox(height: 14),
            MeasurementField(
              controller: _hipsController,
              label: 'Бёдра',
              hint: '0',
              icon: Icons.circle,
              suffix: 'см',
            ),
            const SizedBox(height: 28),
            
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => isEdit ? _updateMeasurement() : _saveMeasurement(),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      isEdit ? 'Сохранить изменения' : 'Сохранить',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          setState(() => _selectedDate = date);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              size: 18,
              color: AppColors.textHint,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _formatDateRu(_selectedDate),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }

  void _saveMeasurement() {
    if (_formKey.currentState!.validate()) {
      context.read<MeasurementsBloc>().add(
        SaveMeasurements(
          measuredAt: _selectedDate,
          weightKg: double.tryParse(_weightController.text),
          chestCm: double.tryParse(_chestController.text),
          waistCm: double.tryParse(_waistController.text),
          hipsCm: double.tryParse(_hipsController.text),
        ),
      );
      Navigator.pop(context);
      _showSuccessMessage('Замер добавлен');
    }
  }

  void _updateMeasurement() {
    if (_formKey.currentState!.validate() && widget.measurement != null) {
      context.read<MeasurementsBloc>().add(
        UpdateMeasurements(
          id: widget.measurement!.id,
          measuredAt: _selectedDate,
          weightKg: double.tryParse(_weightController.text),
          chestCm: double.tryParse(_chestController.text),
          waistCm: double.tryParse(_waistController.text),
          hipsCm: double.tryParse(_hipsController.text),
        ),
      );
      Navigator.pop(context);
      _showSuccessMessage('Замер обновлён');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.background,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _formatDateRu(DateTime date) {
    const months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year} г';
  }
}