class LoadState {
  bool isLoading;
  bool hasError;
  String? message;

  LoadState({this.isLoading = false, this.hasError = false, this.message});

  void loading() {
    isLoading = true;
    hasError = false;
    message = null;
  }

  void success([String? successMessage]) {
    isLoading = false;
    hasError = false;
    message = successMessage;
  }

  void error(String errorMessage) {
    isLoading = false;
    hasError = true;
    message = errorMessage;
  }

  void clear() {
    isLoading = false;
    hasError = false;
    message = null;
  }
}
