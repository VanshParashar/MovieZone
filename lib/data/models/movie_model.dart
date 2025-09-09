// lib/data/models/movie_model.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'movie_model.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class MovieModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  @JsonKey(name: 'original_title')
  final String? originalTitle;

  @HiveField(3)
  final String? overview;

  @HiveField(4)
  @JsonKey(name: 'poster_path')
  final String? posterPath;

  @HiveField(5)
  @JsonKey(name: 'backdrop_path')
  final String? backdropPath;

  @HiveField(6)
  @JsonKey(name: 'release_date')
  final String? releaseDate;

  @HiveField(7)
  @JsonKey(name: 'vote_average')
  final double? voteAverage;

  @HiveField(8)
  @JsonKey(name: 'vote_count')
  final int? voteCount;

  @HiveField(9)
  final bool adult;

  @HiveField(10)
  @JsonKey(name: 'original_language')
  final String? originalLanguage;

  @HiveField(11)
  @JsonKey(name: 'genre_ids', defaultValue: <int>[])
  final List<int> genreIds;

  @HiveField(12)
  final double? popularity;

  @HiveField(13)
  final bool? video;

  // local-only
  @HiveField(14)
  bool isBookmarked;

  MovieModel({
    required this.id,
    required this.title,
    this.originalTitle,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    this.voteAverage,
    this.voteCount,
    required this.adult,
    this.originalLanguage,
    this.genreIds = const <int>[],
    this.popularity,
    this.video,
    this.isBookmarked = false,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) => _$MovieModelFromJson(json);
  Map<String, dynamic> toJson() => _$MovieModelToJson(this);
}
