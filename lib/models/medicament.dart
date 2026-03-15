class Medicament {
  final int id;
  final String numEnr;
  final String code;
  final String catNum;
  final String catName;
  final String dci;
  final String nomMarque;
  final String forme;
  final String dosage;
  final String conditionnement;
  final String liste;
  final String type;
  final String statut;
  final String laboratoire;
  final String pays;
  final String dateInitial;
  final String dateFinal;
  final String stabilite;
  final String obs;
  bool isFavori;

  Medicament({
    required this.id,
    required this.numEnr,
    required this.code,
    required this.catNum,
    required this.catName,
    required this.dci,
    required this.nomMarque,
    required this.forme,
    required this.dosage,
    required this.conditionnement,
    required this.liste,
    required this.type,
    required this.statut,
    required this.laboratoire,
    required this.pays,
    required this.dateInitial,
    required this.dateFinal,
    required this.stabilite,
    required this.obs,
    this.isFavori = false,
  });

  factory Medicament.fromJson(Map<String, dynamic> json) {
    return Medicament(
      id: json['id'] ?? 0,
      numEnr: json['num_enr'] ?? '',
      code: json['code'] ?? '',
      catNum: json['cat_num'] ?? '',
      catName: json['cat_name'] ?? '',
      dci: json['dci'] ?? '',
      nomMarque: json['nom_marque'] ?? '',
      forme: json['forme'] ?? '',
      dosage: json['dosage'] ?? '',
      conditionnement: json['conditionnement'] ?? '',
      liste: json['liste'] ?? '',
      type: json['type'] ?? '',
      statut: json['statut'] ?? '',
      laboratoire: json['laboratoire'] ?? '',
      pays: json['pays'] ?? '',
      dateInitial: json['date_initial'] ?? '',
      dateFinal: json['date_final'] ?? '',
      stabilite: json['stabilite'] ?? '',
      obs: json['obs'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'num_enr': numEnr,
      'code': code,
      'cat_num': catNum,
      'cat_name': catName,
      'dci': dci,
      'nom_marque': nomMarque,
      'forme': forme,
      'dosage': dosage,
      'conditionnement': conditionnement,
      'liste': liste,
      'type': type,
      'statut': statut,
      'laboratoire': laboratoire,
      'pays': pays,
      'date_initial': dateInitial,
      'date_final': dateFinal,
      'stabilite': stabilite,
      'obs': obs,
      'is_favori': isFavori ? 1 : 0,
    };
  }

  factory Medicament.fromMap(Map<String, dynamic> map) {
    return Medicament(
      id: map['id'] ?? 0,
      numEnr: map['num_enr'] ?? '',
      code: map['code'] ?? '',
      catNum: map['cat_num'] ?? '',
      catName: map['cat_name'] ?? '',
      dci: map['dci'] ?? '',
      nomMarque: map['nom_marque'] ?? '',
      forme: map['forme'] ?? '',
      dosage: map['dosage'] ?? '',
      conditionnement: map['conditionnement'] ?? '',
      liste: map['liste'] ?? '',
      type: map['type'] ?? '',
      statut: map['statut'] ?? '',
      laboratoire: map['laboratoire'] ?? '',
      pays: map['pays'] ?? '',
      dateInitial: map['date_initial'] ?? '',
      dateFinal: map['date_final'] ?? '',
      stabilite: map['stabilite'] ?? '',
      obs: map['obs'] ?? '',
      isFavori: (map['is_favori'] ?? 0) == 1,
    );
  }
}
