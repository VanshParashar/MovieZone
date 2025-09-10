// lib/ui/screens/home_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/genre_map.dart';
import '../../viewmodels/bookmark_vm.dart';
import '../../viewmodels/details_vm.dart';
import '../../viewmodels/home_vm.dart';
import '../../providers.dart';
import '../../ui/widgets/movie_card.dart';
import '../../ui/screens/details_screen.dart';
import '../../core/constants.dart';
import '../widgets/trending_carousel.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  Widget _buildTrendingShimmer(double cardWidth, double cardHeight) {
    return SizedBox(
      height: cardHeight,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.65),
        itemCount: 5,
        itemBuilder: (_, __) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade900,
              highlightColor: Colors.grey.shade800,
              child: Container(
                width: cardWidth,
                height: cardHeight,
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNowPlayingShimmer() {
    return Column(
      children: List.generate(4, (i) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade900,
            highlightColor: Colors.grey.shade800,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(16.r),
              ),
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  Container(width: 80.w, height: 120.h, color: Colors.grey.shade800),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 16.h, width: 160.w, color: Colors.grey.shade800),
                        SizedBox(height: 8.h),
                        Container(height: 12.h, width: 100.w, color: Colors.grey.shade800),
                        SizedBox(height: 8.h),
                        Container(height: 12.h, width: 120.w, color: Colors.grey.shade800),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeVMProvider);
    final vm = ref.read(homeVMProvider.notifier);

    // Colors & styles
    final bg = Colors.black;
    final sectionTitleStyle = TextStyle(
      color: Colors.white,
      fontSize: 20.sp,
      fontWeight: FontWeight.bold,
    );
    final accent = Colors.orange;
    // responsive sizes for trending
    final trendingCardW = 360.w;
    final trendingCardH = 310.h;

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text(
          'Discover',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24.sp),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white, size: 22.w),
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
          IconButton(
            icon: Icon(Icons.bookmark, color: Colors.white, size: 22.w),
            onPressed: () => Navigator.pushNamed(context, '/bookmarks'),
          )
        ],
      ),
      body: RefreshIndicator(
        color: accent,
        onRefresh: () => vm.load(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: 12.h)),

            /// Trending header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  children: [
                    Text('Trending', style: sectionTitleStyle),
                    const Spacer(),
                  ],
                ),
              ),
            ),

            // Trending content or shimmer
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: state.loading && state.trending.isEmpty
                    ? _buildTrendingShimmer(trendingCardW, trendingCardH)
                    : TrendingCarousel(
                  movies: state.trending,
                  cardWidth: trendingCardW,
                  cardHeight: trendingCardH,
                  onToggleBookmark: (id, newVal) async {
                    await ref.read(homeVMProvider.notifier).toggleBookmark(id, newVal);
                    await ref.read(bookmarkVMProvider.notifier).load();
                    // update Details screen if it's open
                    await ref.read(detailsVMProvider(id).notifier).toggleBookmark(id, newVal);
                  },
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 8.h)),

            /// Now Playing header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text('Now Playing', style: sectionTitleStyle),
              ),
            ),

            // Now Playing list or shimmer
            if (state.loading && state.nowPlaying.isEmpty)
              SliverToBoxAdapter(child: _buildNowPlayingShimmer())
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (ctx, idx) {
                    final m = state.nowPlaying[idx];
                    final genres = m.genreIds
                        .map((id) => kGenreMap[id])
                        .where((g) => g != null)
                        .cast<String>()
                        .toList();

                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      child: Card(
                        color: const Color(0xFF1E1E2C),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                        elevation: 2,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16.r),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => DetailsScreen(movieId: m.id)),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Poster
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: CachedNetworkImage(
                                    width: 105.w,
                                    height: 120.h,
                                    fit: BoxFit.cover,
                                    imageUrl: m.posterPath != null ? '$IMAGE_BASE_URL${m.posterPath}' : '',
                                    errorWidget: (_, __, ___) => Container(
                                      width: 105.w,
                                      height: 120.h,
                                      color: Colors.grey[800],
                                      child: Icon(Icons.broken_image, color: Colors.white54, size: 20.w),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),

                                /// Movie details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      /// Title
                                      Text(
                                        m.title,
                                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 6.h),

                                      /// Rating
                                      Row(
                                        children: [
                                          Icon(Icons.star, size: 17.w, color: Colors.amber),
                                          SizedBox(width: 4.w),
                                          Text(
                                            '${(m.voteAverage ?? 0).toStringAsFixed(1)}/10 IMDb',
                                            style: TextStyle(color: Colors.white70, fontSize: 15.sp),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 6.h),

                                      /// Genres chips
                                      Wrap(
                                        spacing: 6.w,
                                        runSpacing: -4.h,
                                        children: genres.take(3).map((g) {
                                          return Chip(
                                            label: Text(g, style: TextStyle(fontSize: 15.sp)),
                                            backgroundColor: Colors.deepPurple.shade200,
                                            labelStyle: const TextStyle(color: Colors.black),
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            padding: EdgeInsets.zero,
                                          );
                                        }).toList(),
                                      ),
                                      SizedBox(height: 6.h),

                                      /// Release date
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_month, size: 14.w, color: Colors.white70),
                                          SizedBox(width: 4.w),
                                          Text(
                                            m.releaseDate ?? '',
                                            style: TextStyle(color: Colors.white70, fontSize: 15.sp),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // optional right-side bookmark / action can be added here
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: state.nowPlaying.length,
                ),
              ),

            SliverToBoxAdapter(child: SizedBox(height: 24.h)),
          ],
        ),
      ),
    );
  }
}
