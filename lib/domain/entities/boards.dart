class Board {
  final String table;
  final String name;

  const Board({required this.table, required this.name});
}

const boards = <Board>[
  Board(table: 'pds', name: '웃긴자료'),
];

const defaultBoard = Board(table: 'pds', name: '웃긴자료');
