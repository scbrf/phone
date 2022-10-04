import 'package:flutter_test/flutter_test.dart';
import 'package:redux/redux.dart';
import 'package:scbrf/actions/actions.dart';
import 'package:scbrf/models/models.dart';
import 'package:scbrf/reducers/reducers.dart';

void main() {
  test('setloading error', () {
    final store = Store<AppState>(
      appReducer,
      initialState: AppState.loading(),
    );

    store.dispatch(NetworkError('error fetch'));

    expect(store.state.state.isLoading, false);
    expect(store.state.state.error, 'error fetch');
  });
}
