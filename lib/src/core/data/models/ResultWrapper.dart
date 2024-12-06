class ResultWrapper {
  final int count;
  final String? next;
  final String? previous;
  final List results;

  const ResultWrapper({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  factory ResultWrapper.fromJson(Map<String, dynamic> json) {
    return ResultWrapper(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: json['results'],
    );
  }
}