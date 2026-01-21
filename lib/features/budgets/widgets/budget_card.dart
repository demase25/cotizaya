import 'package:flutter/material.dart';
import '../models/budget_model.dart';
import '../../../core/constants/colors.dart';

class BudgetCard extends StatelessWidget {
  final BudgetModel budget;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const BudgetCard({
    super.key,
    required this.budget,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isPaid = budget.status == BudgetStatus.paid;
    final canChangeStatus = !isPaid; // Solo se puede cambiar si está pendiente

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPaid
                ? AppColors.paid.withOpacity(0.15)
                : AppColors.pending.withOpacity(0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila principal: Cliente y Monto
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info del cliente
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          budget.clientName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 14),
                        // Badge de estado - diseño mejorado
                        _buildStatusBadge(isPaid, canChangeStatus, onTap),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Monto destacado
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isPaid
                              ? AppColors.paid.withOpacity(0.08)
                              : AppColors.pending.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isPaid
                                ? AppColors.paid.withOpacity(0.2)
                                : AppColors.pending.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '\$${budget.total.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: isPaid
                                ? AppColors.paid
                                : AppColors.pending,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  // Botón de opciones
                  if (onDelete != null) ...[
                    const SizedBox(width: 6),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.grey.shade400,
                        size: 18,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Eliminar',
                                style: TextStyle(
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'delete' && onDelete != null) {
                          onDelete!();
                        }
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isPaid, bool canChangeStatus, VoidCallback? onTap) {
    return GestureDetector(
      onTap: canChangeStatus ? onTap : null,
      child: Opacity(
        opacity: canChangeStatus ? 1.0 : 0.7,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: isPaid
                ? AppColors.paid.withOpacity(0.1)
                : AppColors.pending.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isPaid
                  ? AppColors.paid.withOpacity(0.25)
                  : AppColors.pending.withOpacity(0.25),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPaid ? Icons.check_circle : Icons.pending_outlined,
                size: 15,
                color: isPaid ? AppColors.paid : AppColors.pending,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  isPaid ? 'Cobrado' : 'Pendiente',
                  style: TextStyle(
                    color: isPaid ? AppColors.paid : AppColors.pending,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (canChangeStatus) ...[
                const SizedBox(width: 3),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 9,
                  color: AppColors.pending.withOpacity(0.4),
                ),
              ] else ...[
                const SizedBox(width: 3),
                Icon(
                  Icons.lock_outline,
                  size: 9,
                  color: AppColors.paid.withOpacity(0.4),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
