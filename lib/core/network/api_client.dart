import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import '../../data/models/movie_response.dart';
import '../../data/models/movie_model.dart';
// add import
import '../../data/models/movie_detail.dart';
part 'api_client.g.dart';

@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;



// change the method signature
  @GET('/movie/{id}')
  Future<MovieDetail> getMovieDetails(@Path('id') int id);

  // Trending (day)
  @GET('/trending/movie/day')
  Future<MovieResponse> getTrending();

  // Now Playing (supports page & region)
  @GET('/movie/now_playing')
  Future<MovieResponse> getNowPlaying(@Query('page') int page, {@Query('region') String? region});

  // Search
  @GET('/search/movie')
  Future<MovieResponse> searchMovies(@Query('query') String query, {@Query('page') int page = 1});

}
