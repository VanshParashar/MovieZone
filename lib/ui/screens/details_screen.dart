// lib/ui/screens/details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants.dart';
import '../../providers.dart';
import '../../viewmodels/bookmark_vm.dart';
import '../../viewmodels/details_vm.dart';
import '../../ui/widgets/poster.dart';
import '../../data/models/movie_detail.dart';
import '../../data/models/movie_model.dart';
import '../../services/deep_link_service.dart';
import '../../viewmodels/home_vm.dart';

class DetailsScreen extends ConsumerStatefulWidget {
  final int movieId;
  const DetailsScreen({required this.movieId, Key? key}) : super(key: key);

  @override
  ConsumerState<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends ConsumerState<DetailsScreen>
    with SingleTickerProviderStateMixin {
  bool expandedOverview = false;
  late final AnimationController _bookmarkController;
  bool _isBookmarked = false;
  static const int _overviewReadMoreThreshold = 180;

  @override
  void initState() {
    super.initState();
    _bookmarkController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    WidgetsBinding.instance.addPostFrameCallback((_) => _initBookmark());
  }

  @override
  void dispose() {
    _bookmarkController.dispose();
    super.dispose();
  }

  Future<void> _initBookmark() async {
    try {
      final repo = ref.read(movieRepoProvider);
      final cached = repo.getBookmarks().firstWhere(
              (m) => m.id == widget.movieId,
          orElse: () => null as MovieModel);
      final isBm = cached?.isBookmarked ?? false;
      setState(() {
        _isBookmarked = isBm;
      });
      if (_isBookmarked) {
        _bookmarkController.forward();
      } else {
        _bookmarkController.reverse();
      }
    } catch (_) {}
  }

  Future<void> _toggleBookmark(MovieDetail movie) async {
    final repo = ref.read(movieRepoProvider);
    final newVal = !_isBookmarked;

    await repo.setBookmark(movie.id, newVal);

    setState(() {
      _isBookmarked = newVal;
    });

    if (_isBookmarked) {
      _bookmarkController.forward();
    } else {
      _bookmarkController.reverse();
    }

    final snack = newVal ? 'Added to Saved' : 'Removed from Saved';
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(snack)));
    }
  }

  Future<void> _shareMovie(MovieDetail movie) async {
    final deepLink = 'movie_app://movie/${movie.id}';
    final overview = movie.overview ?? '';
    final shortOverview =
    overview.length > 100 ? overview.substring(0, 100) + '...' : overview;
    final shareText =
        '🎬 Check out "${movie.title}" - $shortOverview\n\nOpen in Movies App: $deepLink';

    await Share.share(shareText);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Shared — tap SIMULATE to demo opening this deep link in-app'),
          action: SnackBarAction(
            label: 'SIMULATE',
            onPressed: () {
              DeepLinkService.simulateDeepLink(ref, movie.id);
            },
          ),
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }

  Future<void> _onRefresh() async {
    final vm = ref.read(detailsVMProvider(widget.movieId).notifier);
    await vm.load(widget.movieId, forceRefresh: true);
  }

  Widget _buildShimmerPlaceholder(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade800,
          highlightColor: Colors.grey.shade700,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 200.h, width: double.infinity, color: Colors.grey.shade800),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Container(width: 120.w, height: 180.h, color: Colors.grey.shade800),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        6,
                            (_) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 6.h),
                          child: Container(
                            height: 12.h,
                            width: double.infinity,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 12.h),
              Container(height: 12.h, width: 200.w, color: Colors.grey.shade800),
              SizedBox(height: 6.h),
              Container(height: 12.h, width: 120.w, color: Colors.grey.shade800),
            ],
          ),
        ),
      ),
    );
  }

  bool _isSocketLikeError(String? err) {
    if (err == null) return false;
    final lower = err.toLowerCase();
    return lower.contains('socket') ||
        lower.contains('connection') ||
        lower.contains('network') ||
        lower.contains('failed host lookup') ||
        lower.contains('connection reset') ||
        lower.contains('no internet') ||
        lower.contains('handshake') ||
        lower.contains('timed out');
  }

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFF0F1115);
    final card = Color(0xFF2D2D48);
    final muted = Colors.white70;
    final chipBg = const Color(0xFF262730);
    final accent = Colors.indigoAccent.shade200;

    final detailsState = ref.watch(detailsVMProvider(widget.movieId));
    final detailsVM = ref.read(detailsVMProvider(widget.movieId).notifier);
    final MovieDetail? movie = detailsState.movie;

    final ds = ref.watch(detailsVMProvider(widget.movieId));
    final isBm = ds.isBookmarked;

    return Scaffold(
      backgroundColor: bg,
      body: RefreshIndicator(
        color: accent,
        onRefresh: _onRefresh,
        child: Builder(builder: (ctx) {
          if (detailsState.loading && detailsState.movie == null) {
            return _buildShimmerPlaceholder(context);
          }

          if (detailsState.movie != null) {
            final m = detailsState.movie!;
            return SafeArea(
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    backgroundColor: bg,
                    expandedHeight: 260.h,
                    pinned: true,
                    elevation: 0,
                    leading: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white, size: 22.sp),
                        onPressed: () => Navigator.pop(context)),
                    actions: [
                      if (detailsState.loading)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: const Center(
                              child: SizedBox(
                                  width: 14, height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2))),
                        ),
                      SizedBox(width: 8.w),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: EdgeInsets.only(left: 72.w, bottom: 12.h),
                      title: Text(m.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white, fontSize: 16.sp)),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (m.backdropPath != null)
                            CachedNetworkImage(
                              imageUrl: '$IMAGE_BASE_URL${m.backdropPath}',
                              fit: BoxFit.cover,
                              placeholder: (_, __) =>
                                  Container(color: Colors.grey[900]),
                              errorWidget: (_, __, ___) =>
                                  Container(color: Colors.grey[900]),
                            )
                          else
                            Container(color: Colors.grey[900]),
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black54,
                                  Colors.black87
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          /// Poster + title + bookmark
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Poster(
                                heroTag: 'poster_${m.id}',
                                path: m.posterPath,
                                width: 120.w,
                                height: 180.h,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 6.h),
                                    Text(m.originalTitle.isNotEmpty ? m.originalTitle : m.title,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.w700)),
                                    SizedBox(height: 8.h),
                                    if (m.tagline != null && m.tagline!.isNotEmpty)
                                      Text('"${m.tagline}"',
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              color: muted,
                                              fontSize: 13.sp)),
                                    SizedBox(height: 10.h),
                                    Row(children: [
                                      if (m.voteAverage != null)
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                          decoration: BoxDecoration(
                                              color: Colors.green[700],
                                              borderRadius: BorderRadius.circular(8.r)),
                                          child: Row(children: [
                                            Icon(Icons.star, size: 14.sp, color: Colors.white),
                                            SizedBox(width: 6.w),
                                            Text((m.voteAverage ?? 0).toStringAsFixed(1),
                                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13.sp)),
                                          ]),
                                        ),
                                      SizedBox(width: 8.w),
                                      if (m.releaseDate != null)
                                        Chip(label: Text(m.releaseDate!, style: TextStyle(fontSize: 12.sp)), backgroundColor: chipBg, labelStyle: TextStyle(color: Colors.white)),
                                    ]),
                                    SizedBox(height: 10.h),
                                    Text('${m.originalLanguage.toUpperCase()} • ${m.voteCount ?? 0} votes',
                                        style: TextStyle(color: muted, fontSize: 13.sp)),
                                  ],
                                ),
                              ),
                              Column(children: [
                                ScaleTransition(
                                  scale: Tween(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: _bookmarkController, curve: Curves.easeOutBack)),
                                  child: IconButton(
                                    iconSize: 28.sp,
                                    color: isBm ? accent : Colors.white,
                                    icon: Icon(isBm ? Icons.bookmark : Icons.bookmark_border),
                                    onPressed: () async {
                                      await ref.read(detailsVMProvider(widget.movieId).notifier).toggleBookmark(widget.movieId, !isBm);
                                      await ref.read(homeVMProvider.notifier).toggleBookmark(widget.movieId, !isBm);
                                      await ref.read(bookmarkVMProvider.notifier).load();
                                    },
                                  ),
                                ),
                                IconButton(icon: Icon(Icons.share, color: Colors.white, size: 22.sp), onPressed: () => _shareMovie(m)),
                              ])
                            ],
                          ),

                          SizedBox(height: 18.h),

                          /// Overview
                          Text('Overview', style: TextStyle(color: Colors.white70, fontSize: 16.sp, fontWeight: FontWeight.w600)),
                          SizedBox(height: 8.h),
                          AnimatedCrossFade(
                            duration: const Duration(milliseconds: 250),
                            firstChild: Text(m.overview ?? 'No overview available.', maxLines: 4, overflow: TextOverflow.ellipsis, style: TextStyle(color: muted, fontSize: 13.sp)),
                            secondChild: Text(m.overview ?? 'No overview available.', style: TextStyle(color: muted, fontSize: 13.sp)),
                            crossFadeState: expandedOverview ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                          ),
                          if ((m.overview ?? '').length > _overviewReadMoreThreshold)
                            Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => setState(() => expandedOverview = !expandedOverview), child: Text(expandedOverview ? 'Show less' : 'Read more', style: TextStyle(color: accent, fontSize: 13.sp)))),

                          SizedBox(height: 8.h),

                          /// Buttons
                          Row(children: [
                            Expanded(child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.play_arrow), label: const Text('Watch Trailer'), style: ElevatedButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.black, minimumSize: Size.fromHeight(44.h)))),
                            SizedBox(width: 12.w),
                            OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.white24), foregroundColor: Colors.white), child: const Text('Homepage')),
                            SizedBox(width: 8.w),
                          ]),

                          SizedBox(height: 16.h),

                          if (m.genres.isNotEmpty) Text('Genres', style: TextStyle(color: Colors.white70, fontSize: 16.sp, fontWeight: FontWeight.w600)),
                          SizedBox(height: 6.h),
                          Wrap(spacing: 8.w, children: m.genres.map((g) => Chip(label: Text(g.name, style: TextStyle(color: Colors.white, fontSize: 12.sp)), backgroundColor: chipBg)).toList()),

                          SizedBox(height: 12.h),

                          if (m.productionCompanies.isNotEmpty) Text('Production', style: TextStyle(color: Colors.white70, fontSize: 16.sp, fontWeight: FontWeight.w600)),
                          SizedBox(height: 6.h),
                          Column(mainAxisSize: MainAxisSize.min, children: m.productionCompanies.map((pc) {
                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 6.h),
                              decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(12.r)),
                              child: ListTile(
                                leading: pc.logo_path != null ? CachedNetworkImage(imageUrl: '$IMAGE_BASE_URL${pc.logo_path}', width: 40.w, errorWidget: (_, __, ___) => Icon(Icons.movie, color: Colors.white, size: 20.sp)) : Icon(Icons.business, color: Colors.white, size: 20.sp),
                                title: Text(pc.name, style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                                subtitle: pc.origin_country != null ? Text(pc.origin_country!, style: TextStyle(color: Colors.white60, fontSize: 12.sp)) : null,
                              ),
                            );
                          }).toList()),

                          SizedBox(height: 12.h),

                          Row(children: [
                            if (m.budget != 0) Text('Budget: ${_formatCurrency(m.budget)}', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 13.sp)),
                            SizedBox(width: 12.w),
                            if (m.revenue != 0) Text('Revenue: ${_formatCurrency(m.revenue)}', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 13.sp)),
                          ]),

                          SizedBox(height: 16.h),

                          if (m.spokenLanguages.isNotEmpty) Text('Languages', style: TextStyle(color: Colors.white70, fontSize: 16.sp, fontWeight: FontWeight.w600)),
                          SizedBox(height: 6.h),
                          Wrap(spacing: 8.w, children: m.spokenLanguages.map((l) => Chip(label: Text(l.englishName, style: TextStyle(color: Colors.white, fontSize: 12.sp)), backgroundColor: chipBg)).toList()),

                          SizedBox(height: 28.h),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 48.h)),
                ],
              ),
            );
          }

          /// Error state
          final rawError = detailsState.error;
          final errIsSocket = _isSocketLikeError(rawError);
          final errMsg = (rawError != null && rawError.isNotEmpty) ? rawError : 'Movie not found';

          if (errIsSocket) {
            return SafeArea(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.wifi_off, size: 72.sp, color: Colors.redAccent),
                    SizedBox(height: 12.h),
                    Text('Connection lost', style: TextStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.w700)),
                    SizedBox(height: 8.h),
                    Text('Network connection was interrupted. Please tap Retry.', style: TextStyle(fontSize: 14.sp, color: muted), textAlign: TextAlign.center),
                    SizedBox(height: 16.h),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      ElevatedButton.icon(onPressed: () => detailsVM.load(widget.movieId, forceRefresh: true), icon: const Icon(Icons.refresh), label: const Text('Retry')),
                      SizedBox(width: 12.w),
                      OutlinedButton.icon(onPressed: _onRefresh, icon: const Icon(Icons.refresh_outlined), label: const Text('Force Refresh')),
                    ]),
                  ]),
                ),
              ),
            );
          }

          return SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(errMsg, style: TextStyle(fontSize: 16.sp, color: muted), textAlign: TextAlign.center),
                  SizedBox(height: 12.h),
                  ElevatedButton.icon(onPressed: () => detailsVM.load(widget.movieId, forceRefresh: true), icon: const Icon(Icons.refresh), label: const Text('Retry')),
                ]),
              ),
            ),
          );
        }),
      ),
    );
  }

  String _formatCurrency(int value) {
    if (value == 0) return '0';
    final s = value.toString();
    final buffer = StringBuffer();
    var count = 0;
    for (var i = s.length - 1; i >= 0; i--) {
      buffer.write(s[i]);
      count++;
      if (count == 3 && i != 0) {
        buffer.write(',');
        count = 0;
      }
    }
    return buffer.toString().split('').reversed.join('');
  }
}
