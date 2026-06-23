/// Kelime paketi tanımlayıcıları.
enum WordPackId {
  generalCulture('general_culture', 'Genel Kültür'),
  foods('foods', 'Yemekler'),
  movies('movies', 'Filmler');

  const WordPackId(this.id, this.displayName);

  final String id;
  final String displayName;
}
