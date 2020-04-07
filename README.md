# On Device ML with Flutter x TFLite
Demo app which shows on device image classification using TFLite and Flutter

## App Structure

- '<app_root>/pubspec.yaml': Used to add packages to the app from pub.dev
- '<app_root>/lib/main.dart': Used for all the logic of the app
- '<app_root>/assets/': used for storing and using TFLite model and label for the app
- '<app_root>/android/app/src/main/AndroidManifest.xml': used for modifying app name and details
- '<app_root>/android/app/build.gradle': used for specifying TFLite model not to be compressed

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

Learn more about TensorFlow Lite and semantic segmentation using it from the links below:
- [Official TensorFlow Lite Website](https://tensorflow.org/lite)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.