import 'package:flutter/material.dart';

// Pantalla para editar el nombre y el color de un hábito
class EditarHabitoScreen extends StatefulWidget {
  final String nombreInicial;
  final String colorInicial;

  const EditarHabitoScreen({
    super.key,
    required this.nombreInicial,
    required this.colorInicial,
  });

  @override
  State<EditarHabitoScreen> createState() => _EditarHabitoScreenState();
}

class _EditarHabitoScreenState extends State<EditarHabitoScreen> {
  // Controlador del campo de texto
  late TextEditingController _nombreController;

  // Estado para guardar el color seleccionado ('Azul', 'Verde', 'Naranja')
  late String _colorSeleccionado;

  // Tres colores disponibles para seleccionar
  final List<String> _opcionesColor = ['Azul', 'Verde', 'Naranja'];

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.nombreInicial);
    _colorSeleccionado = widget.colorInicial;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  // Mapea el nombre del color al objeto Color correspondiente
  Color _obtenerColor(String nombre) {
    switch (nombre.toLowerCase()) {
      case 'verde':
        return Colors.green;
      case 'naranja':
        return Colors.orange;
      case 'azul':
      default:
        return Colors.blue;
    }
  }

  // Vuelve a la pantalla principal devolviendo los datos editados
  void _guardar() {
    final nombre = _nombreController.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, escribe un nombre para el hábito.')),
      );
      return;
    }

    Navigator.pop(context, {
      'nombre': nombre,
      'color': _colorSeleccionado,
    });
  }

  // Vuelve a la pantalla principal sin devolver ningún cambio (null)
  void _cancelar() {
    Navigator.pop(context, null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Hábito'),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Modificar información del hábito',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Campo de texto con labelText y OutlineInputBorder
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del hábito',
                hintText: 'Ej. Beber agua, Correr...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit_note),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Selecciona un color:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Botones de colores agrupados en una Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _opcionesColor.map((colorNombre) {
                final esSeleccionado = _colorSeleccionado == colorNombre;
                final colorWidget = _obtenerColor(colorNombre);

                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: colorWidget,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(colorNombre),
                    ],
                  ),
                  selected: esSeleccionado,
                  selectedColor: colorWidget.withValues(alpha: 0.25),
                  side: BorderSide(
                    color: esSeleccionado ? colorWidget : Colors.grey.shade400,
                    width: esSeleccionado ? 2 : 1,
                  ),
                  onSelected: (bool selected) {
                    if (selected) {
                      setState(() {
                        _colorSeleccionado = colorNombre;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 36),

            // Botones Cancelar y Guardar
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _cancelar,
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancelar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _guardar,
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
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
