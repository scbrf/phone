import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scbrf/selectors/selectors.dart';
import 'package:scbrf/models/models.dart';

void main() {
  Article a1 = Article(
      timestamp: DateTime.now().millisecondsSinceEpoch,
      read: false,
      starred: false);
  Article a2 = Article(
      timestamp: DateTime.now().millisecondsSinceEpoch - 1000 * 3600 * 24,
      read: false,
      starred: true);
  test('articles', () {
    expect(
        articlesSelector(AppState(focusPlanet: 'today', following: [
          FollowingPlanet(articles: [a1, a2])
        ])).articles,
        [a1]);
    expect(
        articlesSelector(AppState(focusPlanet: 'unread', following: [
          FollowingPlanet(articles: [a1, a2])
        ])).articles,
        [a1, a2]);
    expect(
        articlesSelector(AppState(focusPlanet: 'starred', following: [
          FollowingPlanet(articles: [a1, a2])
        ])).articles,
        [a2]);
  });
  test('title', () {
    expect(articlesSelector(const AppState(focusPlanet: 'starred')).title,
        'Starred');
    expect(
        articlesSelector(const AppState(focusPlanet: 'today')).title, 'Today');
    expect(articlesSelector(const AppState(focusPlanet: 'unread')).title,
        'Unread');
    expect(
        articlesSelector(const AppState(
            focusPlanet: 'following:p1',
            following: [FollowingPlanet(title: 'p1title', id: "p1")])).title,
        'p1title');
    expect(
        articlesSelector(const AppState(
            focusPlanet: 'my:p1',
            planets: [Planet(title: 'p1title', id: "p1")])).title,
        'p1title');
  });

  test('number', () {
    expect(
        mapEquals(
            numberSelector(AppState(planets: [
              Planet(id: 'p2', articles: [a1, a2])
            ], following: [
              FollowingPlanet(id: "p1", articles: [a1, a2])
            ])),
            {
              "today": 1,
              "unread": 2,
              "starred": 1,
              "following:p1": 2,
              "my:p2": 2,
            }),
        true);
  });
}
