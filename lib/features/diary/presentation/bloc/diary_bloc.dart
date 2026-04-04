import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/meal.dart';
import '../../domain/usecases/get_daily_goals.dart';
import '../../domain/usecases/get_meals_by_type.dart';
import 'diary_event.dart';
import 'diary_state.dart';

class DiaryBloc extends Bloc<DiaryEvent, DiaryState> {
  final GetDailyGoals getDailyGoals;
  final GetMealsByType getMealsByType;

  DiaryBloc({required this.getDailyGoals, required this.getMealsByType}) 
      : super(DiaryState.initial()) {  
    on<LoadDiaryData>(_onLoadDiaryData);
    on<ToggleMealSection>(_onToggleMealSection);
  }

  Future<void> _onLoadDiaryData(LoadDiaryData event, Emitter<DiaryState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final goals = await getDailyGoals(event.date);
      

      final breakfast = await getMealsByType(GetMealsByTypeParams(type: MealType.breakfast, date: event.date));
      final lunch = await getMealsByType(GetMealsByTypeParams(type: MealType.lunch, date: event.date));
      final dinner = await getMealsByType(GetMealsByTypeParams(type: MealType.dinner, date: event.date));
      final snack = await getMealsByType(GetMealsByTypeParams(type: MealType.snack, date: event.date));
      
      goals.fold((l) => null, (g) {
        breakfast.fold((l) => null, (b) {
          lunch.fold((l) => null, (l) {
            dinner.fold((l) => null, (d) {
              snack.fold((l) => null, (s) {
                emit(state.copyWith(
                  goals: g, 
                  meals: {
                    MealType.breakfast: b, 
                    MealType.lunch: l, 
                    MealType.dinner: d, 
                    MealType.snack: s
                  }, 
                  isLoading: false
                ));
              });
            });
          });
        });
      });
    } catch (e) { 
      emit(state.copyWith(isLoading: false, error: e.toString())); 
    }
  }

  void _onToggleMealSection(ToggleMealSection event, Emitter<DiaryState> emit) {
    final current = state.expandedSections[event.mealType] ?? false;
    final updated = Map<MealType, bool>.from(state.expandedSections)..[event.mealType] = !current;
    emit(state.copyWith(expandedSections: updated));
  }
}