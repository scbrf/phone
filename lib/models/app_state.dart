import 'package:meta/meta.dart';
import 'package:scbrf/models/models.dart';

@immutable
class AppState {
  final bool isLoading;
  final String error;
  final List<String> stations;
  final String currentStation;
  final List<FollowingPlanet> following;
  final List<Planet> planets;
  final String focusPlanet;
  final int ipfsPeers;
  final Article draft;
  final Article focus;
  final String address;
  const AppState({
    this.isLoading = false,
    this.error = '',
    this.ipfsPeers = 0,
    this.focusPlanet = 'unread',
    this.following = const [],
    this.planets = const [],
    this.stations = const [],
    this.address = '',
    this.currentStation = '',
    this.draft = const Article(),
    this.focus = const Article(),
  });
  factory AppState.loading() => const AppState(isLoading: true);
  AppState copyWith({
    bool? isLoading,
    String? error,
    List<String>? stations,
    String? currentStation,
    List<FollowingPlanet>? following,
    List<Planet>? planets,
    Map<String, int>? numbers,
    String? focusPlanet,
    int? ipfsPeers,
    List<Article>? articles,
    String? articlesTitle,
    Article? draft,
    Article? focus,
    String? address,
  }) {
    return AppState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      stations: stations ?? this.stations,
      currentStation: currentStation ?? this.currentStation,
      following: following ?? this.following,
      planets: planets ?? this.planets,
      focusPlanet: focusPlanet ?? this.focusPlanet,
      ipfsPeers: ipfsPeers ?? this.ipfsPeers,
      draft: draft ?? this.draft,
      focus: focus ?? this.focus,
      address: address ?? this.address,
    );
  }
}
