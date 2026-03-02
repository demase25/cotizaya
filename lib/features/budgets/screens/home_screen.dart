import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../data/budget_local_repository.dart';
import '../models/budget_model.dart';
import '../widgets/budget_card.dart';
import '../models/budget_item_model.dart';
import 'preview_pdf_screen.dart';
import 'create_budget_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/presuya_logo.dart';
import '../../../routes/app_routes.dart';
import '../../../core/utils/formatters.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final repo = BudgetLocalRepository();
  final Box _box = Hive.box('budgetsBox');
  static const String _filterKey = 'last_filter_status';
  
  late TabController _tabController;
  int _currentTabIndex = 0; // 0 = todos, 1 = pendientes, 2 = cobrados
  
  String? get _filterStatus {
    if (_currentTabIndex == 0) return null;
    if (_currentTabIndex == 1) return 'pending';
    return 'paid';
  }

  @override
  void initState() {
    super.initState();
    // Cargar último tab seleccionado
    final savedTabIndex = _box.get(_filterKey);
    if (savedTabIndex != null && savedTabIndex is int && savedTabIndex >= 0 && savedTabIndex < 3) {
      _currentTabIndex = savedTabIndex;
    }
    
    _tabController = TabController(
      length: 3,
      initialIndex: _currentTabIndex,
      vsync: this,
    );
    
    // Listener para guardar el tab cuando cambia (por tap o swipe)
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        // Solo guardar cuando la animación termina
        if (_tabController.index != _currentTabIndex) {
          setState(() {
            _currentTabIndex = _tabController.index;
            _saveFilterStatus();
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _saveFilterStatus() {
    // Guardar el índice del tab directamente para mejor persistencia
    _box.put(_filterKey, _currentTabIndex);
  }

  void _openBudgetPdf(BuildContext context, BudgetModel budget) {
    // Como hoy no guardamos los ítems, armamos un resumen simple
    final items = <BudgetItemModel>[
      BudgetItemModel(
        description: 'Presupuesto guardado',
        price: budget.total,
      ),
    ];

    Navigator.push(
      context,
      AppRoutes.fadeRoute(
        PreviewPdfScreen(
          clientName: budget.clientName,
          items: items,
          total: budget.total,
          budgetId: budget.id,
        ),
      ),
    );
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  void _confirmDelete(BuildContext context, BudgetModel budget) {
    final budgetId = budget.id;
    if (budgetId.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono destacado
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.pending.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: AppColors.pending,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              
              // Título
              const Text(
                'Eliminar presupuesto',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Contenido
              Text(
                '¿Estás seguro de eliminar el presupuesto de',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  budget.clientName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Esta acción no se puede deshacer.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // Cerrar el diálogo primero
                        Navigator.pop(context);
                        
                        // Eliminar solo el presupuesto seleccionado
                        repo.delete(budgetId);
                        
                        // Esperar un momento para asegurar que la eliminación se complete
                        await Future.delayed(const Duration(milliseconds: 100));
                        
                        // Refrescar la UI
                        if (mounted) {
                          _refresh();
                          
                          // Mostrar confirmación
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.delete_outline, color: Colors.white),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text('Presupuesto eliminado'),
                                  ),
                                ],
                              ),
                              backgroundColor: AppColors.pending,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              margin: const EdgeInsets.all(16),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pending,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Eliminar',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allBudgets = repo.getAll();
    final pendingCount = allBudgets.where((b) => b.status == BudgetStatus.pending).length;
    final paidCount = allBudgets.where((b) => b.status == BudgetStatus.paid).length;
    
    final pendingTotal = allBudgets
        .where((b) => b.status == BudgetStatus.pending)
        .fold<double>(0, (sum, b) => sum + b.total);
    
    final paidTotal = allBudgets
        .where((b) => b.status == BudgetStatus.paid)
        .fold<double>(0, (sum, b) => sum + b.total);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 52,
        titleSpacing: 16,
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: PresuYaLogo(
            size: 28,
            showText: true,
            textSize: 18,
            lightBackground: false,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  await Navigator.push(
                    context,
                    AppRoutes.fadeRoute(
                      const SettingsScreen(),
                    ),
                  );
                  if (mounted) _refresh();
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.settings_outlined,
                    color: AppColors.secondary,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          allBudgets.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    _SummaryHeader(
                      pendingTotal: pendingTotal,
                      paidTotal: paidTotal,
                    ),
                    TabBar(
                      controller: _tabController,
                      isScrollable: false,
                      tabAlignment: TabAlignment.fill,
                      tabs: [
                        Tab(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text('Todos'),
                              if (allBudgets.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    allBudgets.length.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Tab(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text('Pendientes'),
                              if (pendingCount > 0) ...[
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.pending,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    pendingCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Tab(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text('Cobrados'),
                              if (paidCount > 0) ...[
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.paid,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    paidCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _AllBudgets(
                            budgets: allBudgets,
                            onRefresh: _refresh,
                            onStatusChange: (budget) {
                              // Solo permitir cambiar de pendiente a cobrado, no al revés
                              if (budget.status == BudgetStatus.paid) {
                                // Si ya está cobrado, mostrar mensaje informativo
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.info_outline,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Los presupuestos cobrados no se pueden cambiar',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: Colors.grey.shade700,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    margin: const EdgeInsets.all(16),
                                    duration: const Duration(seconds: 2),
                                    elevation: 4,
                                  ),
                                );
                                return;
                              }
                              
                              // Cambiar de pendiente a cobrado
                              repo.updateStatus(budget.id, BudgetStatus.paid);
                              _refresh();
                              
                              // Mostrar feedback mejorado
                              Future.delayed(const Duration(milliseconds: 100), () {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.check_circle,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text(
                                                  'Presupuesto marcado como cobrado',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  '${budget.clientName} - \$${budget.total.toStringAsFixed(0)}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white.withOpacity(0.9),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: AppColors.paid,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      margin: const EdgeInsets.all(16),
                                      duration: const Duration(seconds: 3),
                                      elevation: 4,
                                    ),
                                  );
                                }
                              });
                            },
                            onDelete: (budget) => _confirmDelete(context, budget),
                            onView: (budget) => _openBudgetPdf(context, budget),
                          ),
                          _PendingBudgets(
                            budgets: allBudgets.where((b) => b.status == BudgetStatus.pending).toList(),
                            onRefresh: _refresh,
                            onStatusChange: (budget) {
                              repo.updateStatus(budget.id, BudgetStatus.paid);
                              _refresh();
                              
                              // Cambiar al tab de Cobrados para ver el resultado
                              _tabController.animateTo(2);
                              
                              // Mostrar feedback mejorado
                              Future.delayed(const Duration(milliseconds: 100), () {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.check_circle,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text(
                                                  'Presupuesto marcado como cobrado',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  '${budget.clientName} - \$${budget.total.toStringAsFixed(0)}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white.withOpacity(0.9),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: AppColors.paid,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      margin: const EdgeInsets.all(16),
                                      duration: const Duration(seconds: 3),
                                      elevation: 4,
                                    ),
                                  );
                                }
                              });
                            },
                            onDelete: (budget) => _confirmDelete(context, budget),
                            onView: (budget) => _openBudgetPdf(context, budget),
                          ),
                          _PaidBudgets(
                            budgets: allBudgets.where((b) => b.status == BudgetStatus.paid).toList(),
                            onRefresh: _refresh,
                            onStatusChange: (budget) {
                              // Los presupuestos cobrados no se pueden cambiar
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.info_outline,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Los presupuestos cobrados no se pueden cambiar',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.grey.shade700,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin: const EdgeInsets.all(16),
                                  duration: const Duration(seconds: 2),
                                  elevation: 4,
                                ),
                              );
                            },
                            onDelete: (budget) => _confirmDelete(context, budget),
                            onView: (budget) => _openBudgetPdf(context, budget),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

          // CTA principal - Botón flotante (solo cuando hay presupuestos)
          if (allBudgets.isNotEmpty)
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Nuevo Presupuesto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      elevation: 2,
                      shadowColor: AppColors.secondary.withOpacity(0.3),
                    ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        AppRoutes.fadeRoute(
                          const CreateBudgetScreen(),
                        ),
                      );
                      _refresh();
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }


  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono de PresuYa - Solo el checkmark verde (como icono de app)
            Container(
              width: 180,
              height: 180,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40), // Rounded square (squircle)
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 25,
                    offset: const Offset(0, 6),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: PresuYaLogo.iconOnly(
                  size: 132,
                  lightBackground: true,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Todavía no creaste presupuestos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Comenzá creando tu primer presupuesto\ny organizá tus cotizaciones',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  AppRoutes.fadeRoute(
                    const CreateBudgetScreen(),
                  ),
                );
                _refresh();
              },
              icon: const Icon(Icons.add),
              label: const Text('Crear mi primer presupuesto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget para el resumen de presupuestos
class _SummaryHeader extends StatelessWidget {
  final double pendingTotal;
  final double paidTotal;

  const _SummaryHeader({
    required this.pendingTotal,
    required this.paidTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          // Pendiente
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pendiente',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.formatCurrency(pendingTotal),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.pending,
                  ),
                ),
              ],
            ),
          ),
          // Cobrado
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Cobrado',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.formatCurrency(paidTotal),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.paid,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget para la lista de todos los presupuestos
class _AllBudgets extends StatelessWidget {
  final List<BudgetModel> budgets;
  final VoidCallback onRefresh;
  final Function(BudgetModel) onStatusChange;
  final Function(BudgetModel) onDelete;
  final Function(BudgetModel) onView;

  const _AllBudgets({
    required this.budgets,
    required this.onRefresh,
    required this.onStatusChange,
    required this.onDelete,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return _buildBudgetList(budgets, onRefresh, onStatusChange, onDelete, onView);
  }
}

// Widget para la lista de presupuestos pendientes
class _PendingBudgets extends StatelessWidget {
  final List<BudgetModel> budgets;
  final VoidCallback onRefresh;
  final Function(BudgetModel) onStatusChange;
  final Function(BudgetModel) onDelete;
  final Function(BudgetModel) onView;

  const _PendingBudgets({
    required this.budgets,
    required this.onRefresh,
    required this.onStatusChange,
    required this.onDelete,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return _buildBudgetList(budgets, onRefresh, onStatusChange, onDelete, onView);
  }
}

// Widget para la lista de presupuestos cobrados
class _PaidBudgets extends StatelessWidget {
  final List<BudgetModel> budgets;
  final VoidCallback onRefresh;
  final Function(BudgetModel) onStatusChange;
  final Function(BudgetModel) onDelete;
  final Function(BudgetModel) onView;

  const _PaidBudgets({
    required this.budgets,
    required this.onRefresh,
    required this.onStatusChange,
    required this.onDelete,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return _buildBudgetList(budgets, onRefresh, onStatusChange, onDelete, onView);
  }
}

// Método helper para construir la lista de presupuestos
Widget _buildBudgetList(
  List<BudgetModel> budgetsToShow,
  VoidCallback onRefresh,
  Function(BudgetModel) onStatusChange,
  Function(BudgetModel) onDelete,
  Function(BudgetModel) onView,
) {
  return RefreshIndicator(
    onRefresh: () async {
      onRefresh();
      await Future.delayed(const Duration(milliseconds: 500));
    },
    child: ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // Padding inferior para el botón
      itemCount: budgetsToShow.length,
      itemBuilder: (context, index) {
        final budget = budgetsToShow[index];
        return TweenAnimationBuilder<double>(
          key: ValueKey(budget.id),
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 50)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: BudgetCard(
            budget: budget,
            onTap: () => onStatusChange(budget),
            onDelete: () => onDelete(budget),
            onView: () => onView(budget),
          ),
        );
      },
    ),
  );
}

class _FilterButton extends StatelessWidget {
  final String label;
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? AppColors.secondary.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? AppColors.secondary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? AppColors.secondary : Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.secondary : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
