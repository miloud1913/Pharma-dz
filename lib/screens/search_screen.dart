import 'package:flutter/material.dart';
import '../models/medicament.dart';
import '../services/database_service.dart';
import '../widgets/medicament_card.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Medicament> _results = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  static const int _limit = 30;

  String _query = '';
  String? _filterListe;
  String? _filterType;
  String? _filterStatut;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _search();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _search() async {
    setState(() {
      _isLoading = true;
      _offset = 0;
      _results = [];
      _hasMore = true;
    });

    final results = await DatabaseService.instance.searchMedicaments(
      query: _query,
      liste: _filterListe,
      type: _filterType,
      statut: _filterStatut,
      limit: _limit,
      offset: 0,
    );
    final count = await DatabaseService.instance.countMedicaments(
      query: _query,
      liste: _filterListe,
      type: _filterType,
      statut: _filterStatut,
    );

    setState(() {
      _results = results;
      _totalCount = count;
      _offset = results.length;
      _hasMore = results.length == _limit;
      _isLoading = false;
    });
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final results = await DatabaseService.instance.searchMedicaments(
      query: _query,
      liste: _filterListe,
      type: _filterType,
      statut: _filterStatut,
      limit: _limit,
      offset: _offset,
    );

    setState(() {
      _results.addAll(results);
      _offset += results.length;
      _hasMore = results.length == _limit;
      _isLoading = false;
    });
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _FiltersSheet(
        filterListe: _filterListe,
        filterType: _filterType,
        filterStatut: _filterStatut,
        onApply: (liste, type, statut) {
          setState(() {
            _filterListe = liste;
            _filterType = type;
            _filterStatut = statut;
          });
          _search();
        },
      ),
    );
  }

  int get _activeFilters => [_filterListe, _filterType, _filterStatut]
      .where((f) => f != null)
      .length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PharmaAlgérie'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.tune),
                onPressed: _showFilters,
                tooltip: 'Filtres',
              ),
              if (_activeFilters > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$_activeFilters',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF006633),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _query = value.trim();
                _search();
              },
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Nom de marque, DCI, code...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF006633)),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _query = '';
                          _search();
                        },
                      )
                    : null,
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Active filters row
          if (_activeFilters > 0)
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (_filterListe != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(_filterListe!),
                        selected: true,
                        onSelected: (_) {
                          setState(() => _filterListe = null);
                          _search();
                        },
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          setState(() => _filterListe = null);
                          _search();
                        },
                      ),
                    ),
                  if (_filterType != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(_filterType!),
                        selected: true,
                        onSelected: (_) {
                          setState(() => _filterType = null);
                          _search();
                        },
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          setState(() => _filterType = null);
                          _search();
                        },
                      ),
                    ),
                  if (_filterStatut != null)
                    FilterChip(
                      label: Text(_filterStatut!),
                      selected: true,
                      onSelected: (_) {
                        setState(() => _filterStatut = null);
                        _search();
                      },
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() => _filterStatut = null);
                        _search();
                      },
                    ),
                ],
              ),
            ),
          // Results count
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '$_totalCount médicament${_totalCount > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Results
          Expanded(
            child: _results.isEmpty && !_isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun médicament trouvé',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                    itemCount: _results.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _results.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final med = _results[index];
                      return MedicamentCard(
                        medicament: med,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(medicament: med),
                          ),
                        ).then((_) => _search()),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FiltersSheet extends StatefulWidget {
  final String? filterListe;
  final String? filterType;
  final String? filterStatut;
  final Function(String?, String?, String?) onApply;

  const _FiltersSheet({
    required this.filterListe,
    required this.filterType,
    required this.filterStatut,
    required this.onApply,
  });

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  String? _liste;
  String? _type;
  String? _statut;

  @override
  void initState() {
    super.initState();
    _liste = widget.filterListe;
    _type = widget.filterType;
    _statut = widget.filterStatut;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Filtres',
                  style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  setState(() {
                    _liste = null;
                    _type = null;
                    _statut = null;
                  });
                },
                child: const Text('Réinitialiser'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Liste',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['LISTE I', 'LISTE II', 'STUPEFIANTS'].map((l) {
              return ChoiceChip(
                label: Text(l),
                selected: _liste == l,
                onSelected: (_) =>
                    setState(() => _liste = _liste == l ? null : l),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text('Type', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Générique', 'Référence', 'Biologique'].map((t) {
              return ChoiceChip(
                label: Text(t),
                selected: _type == t,
                onSelected: (_) =>
                    setState(() => _type = _type == t ? null : t),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text('Statut',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['En vigueur', 'Importé'].map((s) {
              return ChoiceChip(
                label: Text(s),
                selected: _statut == s,
                onSelected: (_) =>
                    setState(() => _statut = _statut == s ? null : s),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onApply(_liste, _type, _statut);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006633),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Appliquer les filtres',
                  style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
