import 'package:hive/hive.dart';
import '../models/budget_model.dart';

class BudgetLocalRepository {
  final Box box = Hive.box('budgetsBox');

  List<BudgetModel> getAll() {
    try {
      final budgets = <BudgetModel>[];
      
      // Iterar sobre todas las claves para asegurar que solo obtenemos presupuestos válidos
      for (var key in box.keys) {
        // Ignorar la clave de user_profile si existe
        if (key == 'user_profile') continue;
        
        try {
          final data = box.get(key);
          if (data != null) {
            final budget = BudgetModel.fromMap(Map.from(data));
            // Verificar que el presupuesto tenga un ID válido
            if (budget.id.isNotEmpty) {
              budgets.add(budget);
            }
          }
        } catch (e) {
          // Si hay error al parsear, intentar eliminar la entrada corrupta
          try {
            box.delete(key);
          } catch (_) {
            // Ignorar errores
          }
        }
      }
      
      // Ordenar por fecha (más reciente primero)
      budgets.sort((a, b) => b.date.compareTo(a.date));
      
      return budgets;
    } catch (e) {
      return [];
    }
  }

  void save(BudgetModel budget) {
    box.put(budget.id, budget.toMap());
  }

  void updateStatus(String id, BudgetStatus status) {
    final data = box.get(id);
    if (data == null) return;
    
    final map = Map<String, dynamic>.from(data);
    map['status'] = status.index;
    box.put(id, map);
  }

  void delete(String id) {
    try {
      // Verificar que existe antes de eliminar
      if (box.containsKey(id)) {
        box.delete(id);
        // Verificar que se eliminó correctamente
        if (box.containsKey(id)) {
          // Si aún existe, intentar eliminar de nuevo
          box.delete(id);
        }
      }
    } catch (e) {
      // Si hay error, intentar eliminar de todas formas
      try {
        box.delete(id);
      } catch (_) {
        // Ignorar errores silenciosamente
      }
    }
  }
}
