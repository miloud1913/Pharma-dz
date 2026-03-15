import 'package:flutter/material.dart';
import '../models/medicament.dart';
import '../services/database_service.dart';

class DetailScreen extends StatefulWidget {
  final Medicament medicament;

  const DetailScreen({super.key, required this.medicament});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late bool _isFavori;

  @override
  void initState() {
    super.initState();
    _isFavori = widget.medicament.isFavori;
  }

  Future<void> _toggleFavori() async {
    await DatabaseService.instance
        .toggleFavori(widget.medicament.id, !_isFavori);
    setState(() => _isFavori = !_isFavori);
  }

  Color get _listeColor {
    switch (widget.medicament.liste) {
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

  @override
  Widget build(BuildContext context) {
    final med = widget.medicament;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          med.nomMarque.isNotEmpty ? med.nomMarque : med.dci,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(_isFavori ? Icons.favorite : Icons.favorite_outline),
            color: _isFavori ? Colors.red.shade300 : Colors.white,
            onPressed: _toggleFavori,
            tooltip: _isFavori ? 'Retirer des favoris' : 'Ajouter aux favoris',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (med.nomMarque.isNotEmpty)
                      Text(
                        med.nomMarque,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006633),
                        ),
                      ),
                    if (med.dci.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          med.dci,
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildBadge(med.liste, _listeColor),
                        _buildBadge(med.type, const Color(0xFF1565C0)),
                        _buildBadge(med.statut,
                            med.statut == 'En vigueur'
                                ? const Color(0xFF2E7D32)
                                : Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Informations pharmaceutiques
            _buildSection('Informations Pharmaceutiques', [
              _buildRow(Icons.medical_services, 'Forme', med.forme),
              _buildRow(Icons.science, 'Dosage', med.dosage),
              _buildRow(Icons.inventory_2, 'Conditionnement',
                  med.conditionnement),
              if (med.stabilite.isNotEmpty)
                _buildRow(Icons.timer, 'Durée de stabilité', med.stabilite),
            ]),

            const SizedBox(height: 12),

            // Classification
            _buildSection('Classification', [
              _buildRow(Icons.tag, 'Code', med.code),
              _buildRow(Icons.category, 'Catégorie', med.catName),
              _buildRow(Icons.numbers, 'N° Enregistrement', med.numEnr),
            ]),

            const SizedBox(height: 12),

            // Fabricant
            _buildSection('Fabricant', [
              _buildRow(Icons.business, 'Laboratoire', med.laboratoire),
              _buildRow(Icons.public, 'Pays', med.pays),
            ]),

            const SizedBox(height: 12),

            // Dates
            if (med.dateInitial.isNotEmpty || med.dateFinal.isNotEmpty)
              _buildSection('Enregistrement', [
                if (med.dateInitial.isNotEmpty)
                  _buildRow(Icons.calendar_today, 'Date initiale',
                      med.dateInitial),
                if (med.dateFinal.isNotEmpty)
                  _buildRow(Icons.event, 'Date finale', med.dateFinal),
              ]),

            // Observations
            if (med.obs.isNotEmpty) ...[
              const SizedBox(height: 12),
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline,
                          color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          med.obs,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006633),
                letterSpacing: 0.5,
              ),
            ),
            const Divider(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
