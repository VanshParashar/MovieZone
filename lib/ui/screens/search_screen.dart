// lib/ui/screens/search_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../viewmodels/search_vm.dart';
import '../../providers.dart';
import '../../ui/screens/details_screen.dart';
import '../../ui/widgets/poster.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchVMProvider);
    final vm = ref.read(searchVMProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Search bar
            Padding(
              padding: EdgeInsets.all(16.w),
              child: TextField(
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: 'Find Movies, Tv series, and more...',
                  hintStyle: TextStyle(color: Colors.white54, fontSize: 13.sp),
                  prefixIcon: Icon(Icons.search, color: Colors.white54, size: 22.sp),
                  filled: true,
                  fillColor: const Color(0xFF1E1E2C),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12.h,
                    horizontal: 16.w,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: vm.onQueryChanged,
              ),
            ),

            /// Results
            Expanded(
              child: state.loading
                  ? Center(child: SizedBox(
                width: 30.w,
                height: 30.w,
                child: const CircularProgressIndicator(),
              ))
                  : state.results.isEmpty
                  ? Center(
                child: Text(
                  'No results',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 16.sp,
                  ),
                ),
              )
                  : GridView.builder(
                padding: EdgeInsets.all(16.w),
                gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                  childAspectRatio: 0.65,
                ),
                itemCount: state.results.length,
                itemBuilder: (ctx, i) {
                  final m = state.results[i];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            DetailsScreen(movieId: m.id),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Poster
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: Poster(
                            heroTag: 'poster_${m.id}',
                            path: m.posterPath,
                            width: double.infinity,
                            height: 200.h,
                          ),
                        ),
                        SizedBox(height: 8.h),

                        /// Title + Year
                        Text(
                          m.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          m.releaseDate != null &&
                              m.releaseDate!.isNotEmpty
                              ? '(${DateTime.tryParse(m.releaseDate!)?.year ?? ''})'
                              : '',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
