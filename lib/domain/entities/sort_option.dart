enum SortOption {
  all('전체', ''),
  day('일간', 'day'),
  week('주간', 'week'),
  month('월간', 'month'),
  year('연간', 'year'),
  recommend500('추천500', 'better');

  final String label;
  final String value;

  const SortOption(this.label, this.value);
}
