class Track {
  final String name;
  final String path;
  final String id;

  Track({
    required this.name,
    required this.path,
    required this.id,
  });

  @override
  String toString() => name;
}
