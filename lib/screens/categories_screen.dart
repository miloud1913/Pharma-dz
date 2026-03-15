import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/medicament.dart';
import '../widgets/medicament_card.dart';
import 'detail_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await DatabaseService.instance.getCategories();
    setState(() {
      _categories = cats;
      _isLoading = false;
    });
  }

  static const List<Color> _catColors = [
    Color(0xFF006633), Color(0xFF1565C0), Color(0xFFE53935),
    Color(0xFFFF8F00), Color(0xFF6A1B9A), Color(0xFF00838F),
    Color(0xFF2E7D32), Color(0xFFC62828), Color(0xFF283593),
    Color(0xFF558B2F), Color(0xFF4527A0), Color(0xFF00695C),
    Color(0xFF37474F), Color(0xFF6D4C41), Color(0xFF1565C0),
    Color(0xFF880E4F), Color(0xFF004D40), Color(0xFF1A237E),
    Color(0xFF33691E), Color(0xFF827717), Color(0xFF01579B),
    Color(0xFF3E2723), Color(0xFF212121), Color(0xFF006064),
    Color(0xFF4A148C), Color(0xFF1B5E20), Color(0xFFBF360C),
    Color(0xFF263238),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catégories Thérapeutiques'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final catNum = cat['cat_num'] as String;
                final catName = cat['cat_name'] as String;
                final count = cat['count'] as int;
                final color = _catColors[index % _catColors.length];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          catNum,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      catName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    subtitle: Text(
                      '$count médicament${count > 1 ? 's' : ''}',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    trailing:
                        Icon(Icons.chevron_right, color: Colors.grey.shade400),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoryDetailScreen(
                          catNum: catNum,
                          catName: catName,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class CategoryDetailScreen extends StatefulWidget {
  final String catNum;
  final String catName;
  final Color color;

  const CategoryDetailScreen({
    super.key,
    required this.catNum,
    required this.catName,
    required this.color,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  List<Medicament> _medicaments = [];
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();
  bool _hasMore = true;
  int _offset = 0;
  static const int _limit = 30;

  @override
  void initState() {
    super.initState();
    _load();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
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

  Future<void> _load() async {
    final results = await DatabaseService.instance.searchMedicaments(
      catNum: widget.catNum,
      limit: _limit,
      offset: 0,
    );
    setState(() {
      _medicaments = results;
      _offset = results.length;
      _hasMore = results.length == _limit;
      _isLoading = false;
    });
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    final results = await DatabaseService.instance.searchMedicaments(
      catNum: widget.catNum,
      limit: _limit,
      offset: _offset,
    );
    setState(() {
      _medicaments.addAll(results);
      _offset += results.length;
      _hasMore = results.length == _limit;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.catName, overflow: TextOverflow.ellipsis),
        backgroundColor: widget.color,
      ),
      body: _isLoading && _medicaments.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _medicaments.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _medicaments.length) {
                  return const Center(
                      child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ));
                }
                final med = _medicaments[index];
                return MedicamentCard(
                  medicament: med,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => DetailScreen(medicament: med)),
                  ).then((_) => _load()),
                );
              },
            ),
    );
  }
}
