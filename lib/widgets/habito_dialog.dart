import 'package:flutter/material.dart';
import '../models/habito.dart';

/// Diálogo modal para la creación o edición de un hábito.
class HabitoDialog extends StatefulWidget {
  final Habito? habito; // Si es nulo, estamos creando; si no, estamos editando.

  const HabitoDialog({super.key, this.habito});

  @override
  State<HabitoDialog> createState() => _HabitoDialogState();
}

class _HabitoDialogState extends State<HabitoDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late int _selectedColorValue;

  // Lista de colores predefinidos para seleccionar
  final List<Color> _coloresDisponibles = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
    Colors.indigo,
    Colors.deepOrange,
  ];

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.habito?.nombre ?? '');
    _selectedColorValue = widget.habito?.colorValue ?? Colors.blue.toARGB32();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      final nombre = _nombreController.text.trim();
      if (widget.habito == null) {
        // Crear un nuevo hábito con un ID único basado en el timestamp
        final nuevoHabito = Habito(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          nombre: nombre,
          colorValue: _selectedColorValue,
        );
        Navigator.of(context).pop(nuevoHabito);
      } else {
        // Editar hábito existente
        final habitoEditado = widget.habito!.copyWith(
          nombre: nombre,
          colorValue: _selectedColorValue,
        );
        Navigator.of(context).pop(habitoEditado);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.habito != null;

    return AlertDialog(
      title: Text(esEdicion ? 'Editar Hábito' : 'Crear Nuevo Hábito'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del hábito',
                  hintText: 'Ej. Beber agua, Correr, Leer...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.fitness_center),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, escribe un nombre para el hábito';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Selecciona un color:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _coloresDisponibles.map((color) {
                  final isSelected = color.toARGB32() == _selectedColorValue;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColorValue = color.toARGB32();
                      });
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.black, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                                const BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 22)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _guardar,
          child: Text(esEdicion ? 'Guardar Cambios' : 'Crear'),
        ),
      ],
    );
  }
}
