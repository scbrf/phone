import 'package:meta/meta.dart';
import 'package:scbrf/models/models.dart';

@immutable
class AppState {
  final String ipfsGateway;
  final LoadState state;
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
    this.ipfsGateway = '',
    this.state = const LoadState(),
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
  factory AppState.loading() =>
      const AppState(state: LoadState(isLoading: true, error: ''));
  AppState copyWith({
    String? ipfsGateway,
    LoadState? state,
    List<String>? stations,
    String? currentStation,
    List<FollowingPlanet>? following,
    List<Planet>? planets,
    String? focusPlanet,
    int? ipfsPeers,
    Article? draft,
    Article? focus,
    String? address,
  }) {
    return AppState(
      ipfsGateway: ipfsGateway ?? this.ipfsGateway,
      state: state ?? this.state,
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

  @override
  String toString() {
    return 'AppState{ state:$state }';
  }
}
