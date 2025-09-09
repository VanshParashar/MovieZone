// lib/ui/screens/bookmark_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/constants.dart';
import '../../providers.dart';
import '../../data/models/movie_model.dart';
import '../../ui/screens/details_screen.dart';
import '../../viewmodels/bookmark_vm.dart';
import '../../viewmodels/details_vm.dart';
import '../../viewmodels/home_vm.dart';

class BookmarkScreen extends ConsumerWidget {
  const BookmarkScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookmarkVMProvider);

    final bg = const Color(0xFF0F1115);
    final card = const Color(0xFF141519);
    final muted = Colors.white70;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: Text(
          'Saved Movies',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // back arrow white
        ),
      ),
      body: state.loading
          ? Center(
        child: SizedBox(
          width: 28.w,
          height: 28.w,
          child: const CircularProgressIndicator(),
        ),
      )
          : state.bookmarks.isEmpty
          ? Center(
        child: Text(
          'No saved movies yet',
          style: TextStyle(color: muted, fontSize: 14.sp),
        ),
      )
          : ListView.separated(
        padding: EdgeInsets.symmetric(
          vertical: 12.h,
          horizontal: 16.w,
        ),
        itemBuilder: (ctx, idx) {
          final MovieModel m = state.bookmarks[idx];
          return Card(
            color: card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12.r),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailsScreen(movieId: m.id),
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: CachedNetworkImage(
                        imageUrl: m.posterPath != null
                            ? '$IMAGE_BASE_URL${m.posterPath}'
                            : '',
                        width: 72.w,
                        height: 108.h,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          width: 72.w,
                          height: 108.h,
                          color: Colors.grey[800],
                        ),
                        errorWidget: (_, __, ___) => Container(
                          width: 72.w,
                          height: 108.h,
                          color: Colors.grey[800],
                          child: const Icon(Icons.broken_image,
                              color: Colors.white54),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              Icon(Icons.star,
                                  size: 14.sp, color: Colors.amber),
                              SizedBox(width: 6.w),
                              Text(
                                '${(m.voteAverage ?? 0).toStringAsFixed(1)}/10',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            m.releaseDate ?? '',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline,
                          color: Colors.white, size: 20.sp),
                      onPressed: () async {
                        // remove from bookmarks
                        await ref.read(bookmarkVMProvider.notifier).toggleBookmark(m.id);

                        // update Home screen
                        await ref.read(homeVMProvider.notifier).toggleBookmark(m.id, false);

                        // update Details screen if it's open
                        await ref.read(detailsVMProvider(m.id).notifier).toggleBookmark(m.id, false);

                        // reload bookmarks list
                        await ref.read(bookmarkVMProvider.notifier).load();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Removed from Saved')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemCount: state.bookmarks.length,
      ),
    );
  }
}
