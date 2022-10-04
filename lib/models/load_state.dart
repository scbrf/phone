import 'package:meta/meta.dart';

@immutable
class LoadState {
  final bool isLoading;
  final String progress;
  final String error;
  const LoadState(
      {this.isLoading = false, this.error = '', this.progress = ''});
  @override
  String toString() {
    return 'LoadState{ isLoading:$isLoading progress:$progress error:$error }';
  }
}
