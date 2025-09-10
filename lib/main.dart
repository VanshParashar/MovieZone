import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/models/movie_detail.dart';
import 'data/models/movie_model.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/search_screen.dart';
import 'ui/screens/bookmarks_screen.dart';
import 'providers.dart';
import 'ui/screens/details_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(MovieModelAdapter()); // typeId 0
  Hive.registerAdapter(GenreAdapter()); // 1
  Hive.registerAdapter(ProductionCompanyAdapter()); // 2
  Hive.registerAdapter(ProductionCountryAdapter()); // 3
  Hive.registerAdapter(SpokenLanguageAdapter()); // 4
  Hive.registerAdapter(MovieDetailAdapter()); // 5

  // Open boxes
  await Hive.openBox<MovieModel>('trendingBox');
  await Hive.openBox<MovieModel>('nowPlayingBox');
  await Hive.openBox<List>('searchBox');
  await Hive.openBox<MovieDetail>('movieDetailsBox');
  await Hive.openBox<MovieModel>('bookmarksBox');


  runApp( ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Colors.indigo;
    return ScreenUtilInit(
        designSize: const Size(480, 800), // design size (iPhone 12 like). Change if you used another design.
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'TMDB Movies',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: color),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            scaffoldBackgroundColor: Color(0xFFF6F7FB),
            cardTheme: CardTheme(
              elevation: 4,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            textTheme: TextTheme(
              titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              bodyMedium: TextStyle(fontSize: 14, color: Colors.black87),
              bodySmall: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
          initialRoute: '/',
          routes: {
            '/': (_) => HomeScreen(),
            '/search': (_) => SearchScreen(),
            '/bookmarks': (_) => BookmarkScreen(),
          },
          onGenerateRoute: (settings) {
            final uri = Uri.tryParse(settings.name ?? '');
            if (uri != null && uri.pathSegments.isNotEmpty && uri.pathSegments[0] == 'movie') {
              final id = int.tryParse(uri.pathSegments.length > 1 ? uri.pathSegments[1] : uri.pathSegments.last);
              if (id != null) return MaterialPageRoute(builder: (_) => DetailsScreen(movieId: id));
            }
            return null;
          },
        );
      }
    );
  }
}
