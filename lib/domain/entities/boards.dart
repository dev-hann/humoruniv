class Board {
  const Board({required this.table, required this.name});
  final String table;
  final String name;
}

const boards = <Board>[Board(table: 'pds', name: '웃긴자료')];

const defaultBoard = Board(table: 'pds', name: '웃긴자료');
