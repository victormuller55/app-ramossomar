class PaginacaoModel<T> {
  final List<T> itens;
  final int numItens;
  final int maxItens;
  final int numPagina;
  final int maxPaginas;

  const PaginacaoModel({
    required this.itens,
    required this.numItens,
    required this.maxItens,
    required this.numPagina,
    required this.maxPaginas,
  });

  bool get temProximaPagina => numPagina < maxPaginas;

  bool get vazia => itens.isEmpty || maxItens == 0;

  factory PaginacaoModel.fromMap(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItem,
  ) {
    final rawItens = json['itens'];
    final itens = <T>[];
    if (rawItens is List) {
      for (final item in rawItens) {
        if (item is Map) {
          itens.add(fromItem(Map<String, dynamic>.from(item)));
        }
      }
    }

    return PaginacaoModel<T>(
      itens: itens,
      numItens: _asInt(json['num_itens'], fallback: itens.length),
      maxItens: _asInt(json['max_itens'], fallback: itens.length),
      numPagina: _asInt(json['num_pagina'], fallback: 1),
      maxPaginas: _asInt(json['max_paginas'], fallback: itens.isEmpty ? 0 : 1),
    );
  }

  Map<String, dynamic> toCacheMap(Map<String, dynamic> Function(T) toItem) {
    return {
      'itens': itens.map(toItem).toList(),
      'num_itens': numItens,
      'max_itens': maxItens,
      'num_pagina': numPagina,
      'max_paginas': maxPaginas,
    };
  }

  static int _asInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    if (value == null) return fallback;
    return int.tryParse(value.toString()) ?? fallback;
  }
}
