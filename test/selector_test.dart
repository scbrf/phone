import 'package:flutter_test/flutter_test.dart';
import 'package:scbrf/selectors/selectors.dart';
import 'package:scbrf/models/models.dart';

void main() {
  test('today articles', () {
    Article a1 = Article(
        timestamp: DateTime.now().millisecondsSinceEpoch,
        read: false,
        starred: false);
    Article a2 = Article(
        timestamp: DateTime.now().millisecondsSinceEpoch - 1000 * 3600 * 24,
        read: false,
        starred: true);
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
}
