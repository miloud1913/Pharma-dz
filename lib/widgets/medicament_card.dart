import 'package:flutter/material.dart';
import '../models/medicament.dart';

class MedicamentCard extends StatelessWidget {
  final Medicament medicament;
  final VoidCallback onTap;

  const MedicamentCard({
    super.key,
    required this.medicament,
    required this.onTap,
  });

  Color get _listeColor {
    switch (medicament.liste) {
      case 'LISTE I':
        return const Color(0xFFE53935);
      case 'LISTE II':
        return const Color(0xFFFF8F00);
      case 'STUPEFIANTS':
        return const Color(0xFF6A1B9A);
      default:
        return Colors.grey;
    }
  }

  Color get _typeColor {
    switch (medicament.type) {
      case 'Générique':
        return const Color(0xFF1565C0);
      case 'Référence':
        return const Color(0xFF2E7D32);
      case 'Biologique':
        return const Color(0xFF00838F);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medicament.nomMarque.isNotEmpty
                              ? medicament.nomMarque
                              : medicament.dci,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF006633),
                          ),
                        ),
                        if (medicament.nomMarque.isNotEmpty &&
                            medicament.dci.isNotEmpty)
                          Text(
                            medicament.dci,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (medicament.isFavori)
                    const Icon(Icons.favorite,
                        color: Colors.red, size: 18),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${medicament.forme} • ${medicament.dosage} • ${medicament.conditionnement}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _Badge(
                    label: medicament.liste,
                    color: _listeColor,
                  ),
                  const SizedBox(width: 6),
                  _Badge(
                    label: medicament.type,
                    color: _typeColor,
                  ),
                  const Spacer(),
                  Text(
                    medicament.pays,
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
              if (medicament.laboratoire.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  medicament.laboratoire,
                  style:
                      TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
