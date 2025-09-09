// lib/ui/widgets/trending_carousel.dart
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/movie_model.dart';
import '../screens/details_screen.dart';
import 'movie_card.dart';

class TrendingCarousel extends StatelessWidget {
  final List<MovieModel> movies;
  final void Function(int id, bool newVal) onToggleBookmark;
  final double cardWidth;
  final double cardHeight;

  const TrendingCarousel({
    Key? key,
    required this.movies,
    required this.onToggleBookmark,
    this.cardWidth = 260,
    this.cardHeight = 380,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return SizedBox(
        height: cardHeight,
        child: const Center(
          child: Text(
            'No trending movies found',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return SizedBox(
      height: cardHeight,
      child: CarouselSlider.builder(
        itemCount: movies.length,
        itemBuilder: (context, index, realIndex) {
          final movie = movies[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailsScreen(movieId: movie.id),
                ),
              );
            },
            child: MovieCard(
              movie: movie,
              width: cardWidth.w,
              height: cardHeight.h,
              onBookmark: () =>
                  onToggleBookmark(movie.id, !movie.isBookmarked),
            ),
          );
        },
        options: CarouselOptions(
          height: cardHeight.h,
          enlargeCenterPage: true, // center movie thoda bada dikhega
          autoPlay: false, // auto slide
          autoPlayInterval: const Duration(seconds: 4),
          viewportFraction: 0.6, // left-right peek
          enableInfiniteScroll: true, // loop
        ),
      ),
    );
  }
}
