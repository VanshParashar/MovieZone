// lib/data/models/movie_detail.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'movie_detail.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class Genre {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  Genre({required this.id, required this.name});
  factory Genre.fromJson(Map<String, dynamic> json) => _$GenreFromJson(json);
  Map<String, dynamic> toJson() => _$GenreToJson(this);
}

@HiveType(typeId: 2)
@JsonSerializable()
class ProductionCompany {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String? logo_path;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final String? origin_country;

  ProductionCompany({required this.id, this.logo_path, required this.name, this.origin_country});
  factory ProductionCompany.fromJson(Map<String, dynamic> json) => _$ProductionCompanyFromJson(json);
  Map<String, dynamic> toJson() => _$ProductionCompanyToJson(this);
}

@HiveType(typeId: 3)
@JsonSerializable()
class ProductionCountry {
  @HiveField(0)
  @JsonKey(name: 'iso_3166_1')
  final String iso31661;
  @HiveField(1)
  final String name;
  ProductionCountry({required this.iso31661, required this.name});
  factory ProductionCountry.fromJson(Map<String, dynamic> json) => _$ProductionCountryFromJson(json);
  Map<String, dynamic> toJson() => _$ProductionCountryToJson(this);
}

@HiveType(typeId: 4)
@JsonSerializable()
class SpokenLanguage {
  @HiveField(0)
  @JsonKey(name: 'english_name')
  final String englishName;
  @HiveField(1)
  @JsonKey(name: 'iso_639_1')
  final String iso6391;
  @HiveField(2)
  final String? name;
  SpokenLanguage({required this.englishName, required this.iso6391, this.name});
  factory SpokenLanguage.fromJson(Map<String, dynamic> json) => _$SpokenLanguageFromJson(json);
  Map<String, dynamic> toJson() => _$SpokenLanguageToJson(this);
}

@HiveType(typeId: 5)
@JsonSerializable()
class MovieDetail {
  @HiveField(0)
  final bool adult;

  @HiveField(1)
  @JsonKey(name: 'backdrop_path')
  final String? backdropPath;

  @HiveField(2)
  @JsonKey(name: 'belongs_to_collection')
  final dynamic belongsToCollection;

  @HiveField(3)
  final int budget;

  @HiveField(4)
  final List<Genre> genres;

  @HiveField(5)
  final String? homepage;

  @HiveField(6)
  final int id;

  @HiveField(7)
  @JsonKey(name: 'imdb_id')
  final String? imdbId;

  @HiveField(8)
  @JsonKey(name: 'origin_country')
  final List<String>? originCountry;

  @HiveField(9)
  @JsonKey(name: 'original_language')
  final String originalLanguage;

  @HiveField(10)
  @JsonKey(name: 'original_title')
  final String originalTitle;

  @HiveField(11)
  final String? overview;

  @HiveField(12)
  final double? popularity;

  @HiveField(13)
  @JsonKey(name: 'poster_path')
  final String? posterPath;

  @HiveField(14)
  @JsonKey(name: 'production_companies')
  final List<ProductionCompany> productionCompanies;

  @HiveField(15)
  @JsonKey(name: 'production_countries')
  final List<ProductionCountry> productionCountries;

  @HiveField(16)
  @JsonKey(name: 'release_date')
  final String? releaseDate;

  @HiveField(17)
  final int revenue;

  @HiveField(18)
  final int? runtime;

  @HiveField(19)
  @JsonKey(name: 'spoken_languages')
  final List<SpokenLanguage> spokenLanguages;

  @HiveField(20)
  final String? status;

  @HiveField(21)
  final String? tagline;

  @HiveField(22)
  final String title;

  @HiveField(23)
  final bool video;

  @HiveField(24)
  @JsonKey(name: 'vote_average')
  final double? voteAverage;

  @HiveField(25)
  @JsonKey(name: 'vote_count')
  final int? voteCount;

  MovieDetail({
    required this.adult,
    this.backdropPath,
    this.belongsToCollection,
    required this.budget,
    required this.genres,
    this.homepage,
    required this.id,
    this.imdbId,
    this.originCountry,
    required this.originalLanguage,
    required this.originalTitle,
    this.overview,
    this.popularity,
    this.posterPath,
    required this.productionCompanies,
    required this.productionCountries,
    this.releaseDate,
    required this.revenue,
    this.runtime,
    required this.spokenLanguages,
    this.status,
    this.tagline,
    required this.title,
    required this.video,
    this.voteAverage,
    this.voteCount,
  });

  factory MovieDetail.fromJson(Map<String, dynamic> json) => _$MovieDetailFromJson(json);
  Map<String, dynamic> toJson() => _$MovieDetailToJson(this);
}
