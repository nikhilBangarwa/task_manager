import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';

enum PostLoadStatus { initial, loading, loaded, error }

class PostProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FavoritesService _favoritesService = FavoritesService();

  List<Post> _allPosts = [];
  List<Post> _filteredPosts = [];
  Set<int> _favoriteIds = {};

  PostLoadStatus _status = PostLoadStatus.initial;
  String _errorMessage = '';
  String _searchQuery = '';
  bool _showOnlyFavorites = false;

  PostLoadStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get showOnlyFavorites => _showOnlyFavorites;

  int get totalPostsCount => _allPosts.length;
  int get favoritePostsCount => _allPosts.where((p) => p.isFavorite).length;

  List<Post> get posts {
    if (_showOnlyFavorites) {
      return _filteredPosts.where((p) => p.isFavorite).toList();
    }
    return _filteredPosts;
  }

  Future<void> init() async {
    _favoriteIds = await _favoritesService.loadFavorites();
    await fetchPosts();
  }

  Future<void> fetchPosts() async {
    _status = PostLoadStatus.loading;
    notifyListeners();

    try {
      final posts = await _apiService.fetchPosts();
      for (final post in posts) {
        post.isFavorite = _favoriteIds.contains(post.id);
      }
      _allPosts = posts;
      _applySearch();
      _status = PostLoadStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = PostLoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> refreshPosts() async {
    await fetchPosts();
  }

  void search(String query) {
    _searchQuery = query;
    _applySearch();
    notifyListeners();
  }

  void _applySearch() {
    if (_searchQuery.trim().isEmpty) {
      _filteredPosts = List.from(_allPosts);
    } else {
      final q = _searchQuery.trim().toLowerCase();
      _filteredPosts =
          _allPosts.where((p) => p.title.toLowerCase().contains(q)).toList();
    }
  }

  void toggleShowOnlyFavorites() {
    _showOnlyFavorites = !_showOnlyFavorites;
    notifyListeners();
  }

  Future<void> toggleFavorite(Post post) async {
    post.isFavorite = !post.isFavorite;
    if (post.isFavorite) {
      _favoriteIds.add(post.id);
    } else {
      _favoriteIds.remove(post.id);
    }
    await _favoritesService.saveFavorites(_favoriteIds);
    notifyListeners();
  }
}
