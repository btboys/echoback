class Recording {
  final int? id;
  final String filePath;
  final String fileName;
  final int durationMs;
  final DateTime createdAt;
  final bool hasAccompaniment;

  Recording({
    this.id,
    required this.filePath,
    required this.fileName,
    required this.durationMs,
    required this.createdAt,
    this.hasAccompaniment = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'filePath': filePath,
        'fileName': fileName,
        'durationMs': durationMs,
        'createdAt': createdAt.toIso8601String(),
        'hasAccompaniment': hasAccompaniment ? 1 : 0,
      };

  factory Recording.fromMap(Map<String, dynamic> map) => Recording(
        id: map['id'] as int?,
        filePath: map['filePath'] as String,
        fileName: map['fileName'] as String,
        durationMs: map['durationMs'] as int,
        createdAt: DateTime.parse(map['createdAt'] as String),
        hasAccompaniment: (map['hasAccompaniment'] as int) == 1,
      );

  Recording copyWith({
    int? id,
    String? filePath,
    String? fileName,
    int? durationMs,
    DateTime? createdAt,
    bool? hasAccompaniment,
  }) =>
      Recording(
        id: id ?? this.id,
        filePath: filePath ?? this.filePath,
        fileName: fileName ?? this.fileName,
        durationMs: durationMs ?? this.durationMs,
        createdAt: createdAt ?? this.createdAt,
        hasAccompaniment: hasAccompaniment ?? this.hasAccompaniment,
      );
}
