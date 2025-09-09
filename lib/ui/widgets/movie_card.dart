// lib/ui/widgets/movie_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/movie_model.dart';
import 'poster.dart';

class MovieCard extends StatelessWidget {
  final MovieModel movie;
  final VoidCallback? onTap;
  final VoidCallback? onBookmark;
  final double width;
  final double height;

  const MovieCard({
    Key? key,
    required this.movie,
    this.onTap,
    this.onBookmark,
    this.width = 160,
    this.height = 240,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width.w,
        height: height.h,
        child: Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Poster background
              Poster(
                heroTag: 'poster_${movie.id}',
                path: movie.posterPath,
                fit: BoxFit.fill,
                borderRadius: BorderRadius.zero,
              ),

              // Dark gradient at bottom for text readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black54,
                      Colors.black87,
                    ],
                  ),
                ),
              ),

              // Title + Rating + Bookmark
              Positioned(
                left: 8.w,
                right: 8.w,
                bottom: 8.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Movie title
                    Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),

                    Row(
                      children: [
                        // Rating chip
                        if (movie.voteAverage != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[700],
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.star, size: 12.sp, color: Colors.white),
                                SizedBox(width: 4.w),
                                Text(
                                  (movie.voteAverage ?? 0).toStringAsFixed(1),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const Spacer(),

                        // Bookmark button
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          iconSize: 22.sp,
                          color: Colors.white,
                          icon: Icon(
                            movie.isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            size: 22.sp,
                          ),
                          onPressed: onBookmark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
