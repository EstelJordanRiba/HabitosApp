import 'package:flutter/material.dart';
import '../models/habito.dart';

/// Widget visual para mostrar un hábito individual en la lista.
/// Permite marcarlo/desmarcarlo como completado hoy, así como editarlo o borrarlo.
class HabitoCard extends StatelessWidget {
  final Habito habito;
  final ValueChanged<bool?> onToggleCompletado;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final double tamanoLetra;

  const HabitoCard({
    super.key,
    required this.habito,
    required this.onToggleCompletado,
    required this.onEdit,
    required this.onDelete,
    this.tamanoLetra = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final isCompletado = habito.isCompletadoHoy;
    final racha = habito.calcularRachaActual();
    final colorHabito = Color(habito.colorValue);

    return Card(
      elevation: isCompletado ? 1 : 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCompletado
              ? Colors.green.withValues(alpha: 0.5)
              : colorHabito.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: colorHabito,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colorHabito.withValues(alpha: 0.4),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        title: Text(
          habito.nombre,
          style: TextStyle(
            fontSize: tamanoLetra,
            fontWeight: FontWeight.bold,
            decoration: isCompletado ? TextDecoration.lineThrough : TextDecoration.none,
            color: isCompletado
                ? Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6)
                : null,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              Icon(
                Icons.local_fire_department,
                size: tamanoLetra * 0.9,
                color: racha > 0 ? Colors.orange : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                'Racha: $racha ${racha == 1 ? 'día' : 'días'}',
                style: TextStyle(
                  fontSize: tamanoLetra * 0.8,
                  fontWeight: FontWeight.w500,
                  color: racha > 0 ? Colors.orange.shade800 : Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Total: ${habito.totalDiasCompletados}',
                style: TextStyle(
                  fontSize: tamanoLetra * 0.8,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Checkbox para marcar/desmarcar como hecho hoy
            Transform.scale(
              scale: 1.2,
              child: Checkbox(
                value: isCompletado,
                activeColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                onChanged: onToggleCompletado,
              ),
            ),
            // Menú desplegable para editar y borrar
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Borrar'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
