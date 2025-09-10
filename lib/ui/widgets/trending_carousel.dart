// lib/ui/widgets/trending_carousel.dart
import 'package:flutter/material.dart';
import '../../data/models/movie_model.dart';
import '../screens/details_screen.dart';
import 'movie_card.dart';

class TrendingCarousel extends StatefulWidget {
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
  State<TrendingCarousel> createState() => _TrendingCarouselState();
}

class _TrendingCarouselState extends State<TrendingCarousel> {
  late final PageController _controller;
  double _page = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      viewportFraction: 0.65,
    )..addListener(() {
        setState(() {
          _page = _controller.page ?? 0.0;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _scaleFor(int index) {
    final diff = (_page - index).abs();
    return (1 - (diff * 0.15)).clamp(0.85, 1.0);
  }

  double _offsetYFor(int index) {
    final diff = (_page - index).abs();
    return diff < 1 ? (diff * 20) : 20;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) {
      return SizedBox(
        height: widget.cardHeight,
        child: Center(child: Text('No trending movies found')),
      );
    }
    return SizedBox(
      height: widget.cardHeight,
      child: PageView.builder(
        controller: _controller,
        padEnds: true,
        itemCount: widget.movies.length,
        itemBuilder: (context, index) {
          final movie = widget.movies[index];
          final scale = _scaleFor(index);
          final offsetY = _offsetYFor(index);
          return Transform.translate(
            offset: Offset(0, offsetY),
            child: Transform.scale(
              scale: scale,
              child: GestureDetector(
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
                  width: widget.cardWidth,
                  height: widget.cardHeight,
                  onBookmark: () =>
                      widget.onToggleBookmark(movie.id, !movie.isBookmarked),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
