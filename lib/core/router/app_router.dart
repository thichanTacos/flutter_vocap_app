import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/deck/presentation/screens/create_edit_deck_screen.dart';
import '../../features/deck/presentation/screens/deck_detail_screen.dart';
import '../../features/study/flashcard/flashcard_screen.dart';
import '../../features/study/learn/learn_screen.dart';
import '../../features/study/test/test_screen.dart';
import '../../features/study/match/match_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/library/presentation/screens/library_screen.dart';
import '../../features/folder/presentation/screens/create_folder_screen.dart';
import '../../features/folder/presentation/screens/folder_detail_screen.dart';
import '../../features/group/presentation/screens/create_group_screen.dart';
import '../../features/group/presentation/screens/group_detail_screen.dart';
import '../../shared/models/deck_model.dart';
import '../../features/shop/presentation/screens/shop_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      // Thêm vào routes
      GoRoute(
        path: '/shop',
        builder: (_, __) => const ShopScreen(),
      ),
      // Auth
      GoRoute(path: '/login',
          builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register',
          builder: (_, __) => const RegisterScreen()),

      // Home
      GoRoute(path: '/home',
          builder: (_, __) => const HomeScreen()),

      // Profile
      GoRoute(path: '/profile',
          builder: (_, __) => const ProfileScreen()),

      // Library
      GoRoute(path: '/library',
          builder: (_, __) => const LibraryScreen()),

      // Deck
      GoRoute(path: '/deck/create',
          builder: (_, __) => const CreateEditDeckScreen()),
      GoRoute(
        path: '/deck/:deckId',
        builder: (_, state) => DeckDetailScreen(
            deckId: state.pathParameters['deckId']!),
      ),
      GoRoute(
        path: '/deck/:deckId/edit',
        builder: (_, state) => CreateEditDeckScreen(
            deck: state.extra as DeckModel?),
      ),

      // Study modes
      GoRoute(
        path: '/deck/:deckId/flashcard',
        builder: (_, state) => FlashcardScreen(
            deckId: state.pathParameters['deckId']!),
      ),
      GoRoute(
        path: '/deck/:deckId/learn',
        builder: (_, state) => LearnScreen(
            deckId: state.pathParameters['deckId']!),
      ),
      GoRoute(
        path: '/deck/:deckId/test',
        builder: (_, state) => TestScreen(
            deckId: state.pathParameters['deckId']!),
      ),
      GoRoute(
        path: '/deck/:deckId/match',
        builder: (_, state) => MatchScreen(
            deckId: state.pathParameters['deckId']!),
      ),

      // Folder
      GoRoute(path: '/folder/create',
          builder: (_, __) => const CreateFolderScreen()),
      GoRoute(
        path: '/folder/:folderId',  // ✅ route này phải có
        builder: (_, state) => FolderDetailScreen(
            folderId: state.pathParameters['folderId']!),
      ),

      // Group
      GoRoute(path: '/group/create',
          builder: (_, __) => const CreateGroupScreen()),
      GoRoute(
        path: '/group/:groupId',
        builder: (_, state) => GroupDetailScreen(
            groupId: state.pathParameters['groupId']!),
      ),
    ],
  );
});