import 'package:hive/hive.dart';
import '../models/budget_model.dart';
import '../models/budget_item_model.dart';

class BudgetLocalRepository {
  final Box box = Hive.box('budgetsBox');
  static const String _recentItemsKey = 'recent_items';
  static const int _maxRecentItems = 25;

  /// Ítems (productos/servicios) usados recientemente para sugerir al añadir.
  List<BudgetItemModel> getRecentItems() {
    try {
      final raw = box.get(_recentItemsKey);
      if (raw == null || raw is! List) return [];
      final list = raw as List;
      return list
          .map((e) {
            if (e is! Map) return null;
            final m = Map<String, dynamic>.from(e as Map);
            final desc = m['description'] as String? ?? '';
            final price = (m['price'] as num?)?.toDouble() ?? 0.0;
            if (desc.isEmpty) return null;
            return BudgetItemModel(description: desc, price: price);
          })
          .whereType<BudgetItemModel>()
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Registra un ítem como usado (lo pone al inicio; si ya existe, actualiza precio y orden).
  void addRecentItem(String description, double price) {
    final desc = description.trim();
    if (desc.isEmpty) return;
    final current = getRecentItems();
    final updated = [
      BudgetItemModel(description: desc, price: price),
      ...current.where((i) => i.description.trim().toLowerCase() != desc.toLowerCase()),
    ];
    final toSave = updated.take(_maxRecentItems).map((i) => {
      'description': i.description,
      'price': i.price,
    }).toList();
    box.put(_recentItemsKey, toSave);
  }

  /// Cantidad de presupuestos creados en el mes actual (para límite FREE).
  int getBudgetCountThisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return getAll().where((b) {
      return !b.date.isBefore(startOfMonth) && !b.date.isAfter(endOfMonth);
    }).length;
  }

  /// Nombres de clientes usados en presupuestos (únicos, más recientes primero).
  List<String> getRecentClientNames() {
    final budgets = getAll();
    final seen = <String>{};
    final result = <String>[];
    for (final b in budgets) {
      final name = (b.clientName).trim();
      if (name.isEmpty) continue;
      if (seen.add(name)) result.add(name);
    }
    return result;
  }

  List<BudgetModel> getAll() {
    try {
      final budgets = <BudgetModel>[];
      
      // Iterar sobre todas las claves para asegurar que solo obtenemos presupuestos válidos
      for (var key in box.keys) {
        if (key == 'user_profile' || key == _recentItemsKey) continue;
        
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

  /// Elimina todos los presupuestos (mantiene user_profile y recent_items).
  void deleteAll() {
    final keysToDelete = <String>[];
    for (final key in box.keys) {
      final k = key.toString();
      if (k == 'user_profile' || k == _recentItemsKey) continue;
      keysToDelete.add(k);
    }
    for (final key in keysToDelete) {
      box.delete(key);
    }
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
