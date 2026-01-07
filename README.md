# Offline Blogging Application

This blogging app inspired by X.com (Twitter), allows users to create, edit, search and delete posts while managing media uploads, all without internet connectivity.

## Features
### Core Functionalities
- **User Posts**: Users can create text-based posts, adds title and optionally adds images via the camera or choose from the library.
- **Editing Posts**: Modify existing posts, allowing user to modify current title, content, remove or add new images.
- **Deleting Posts**: Remove single or multiple posts at once.
- **Image Handling**: Capture images via the camera or choose from the library.

## Prerequisites
[Flutter](https://docs.flutter.dev/get-started/quick)

## Setup
- ! Important - If this will be tested on an iOS Simluator or Published for a iOS Application in App Store, changes in **ios/Podfile** will need to be made, at the very top the **platform :ios, '15.0'**, as it is required from the dependency **cupertino_native_better**
- ! Important - The assets/ directory will need to be copied into a new application if created from scratch, this is to make sure any additional icons that not in library of Material or Cupertino
- ! Important - If the application is created from scratch / new from Android Studio, the **pubspec.yaml**, along with of course the **lib/** directory will be necessary. If the name in pubspec.yaml is changed, make sure that within the **lib/** along with **test/** dir there will be needed to change the package name. As most modules were imported with the proper package alias of the application.

```js
# Makes sure that everything is configured properly
flutter doctor

# Builds all the code generations for some controllers like, [edit_controller](https://github.com/rv-bit/flutter-blog-app/blob/main/lib/features/blog/controllers/blog_edit_controller.dart) and [individual_controller](https://github.com/rv-bit/flutter-blog-app/blob/main/lib/features/blog/controllers/individual_blog_controller.dart). Used due to need of param / arg in the build / constuctor for state provider as, these are routes with arguments.
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs

# Resolves the pubspec, adds all necessary dependencies if not already installed, and runs the applicaiton.
flutter pub get
flutter run
```

## Tech Stack
- **Flutter**
- **SQLite** (via dependency)

## Dependencies and Use cases
- **sqflite + path +path_provider** - These are all used to create a database helper / utility function, opens / creates database, usage of path to get current application dir
- **go_router** - Used for the Routing system of the application, since to push history stacks when moving to different pages, creating a better UX, and better navigation
- **flutter_riverpod + riverpod_annotation** - Usage of providers / State setters and getters, better state management, caching, and used as the middleware between the Repository and DAO, without allowing direct access to these layers to the client (Widgets). https://pub.dev/packages/flutter_riverpod
- **logging** - Logging framework, mainly used to debug in try-catch errs
- **image_picker + flutter_image_compress** - The image_picker dependecy is widely used in order for easy access to end users Camera Roll / Gallery and Capturing new image from Camera, used to build the required 'image-capture' task set by the client.
- **uuid** - Used to generate Unique ID's when inserting new blog posts, makes it easier to always make sure blogs are unique, and a great use for real-world projects
- **custom_refresh_indicator** - Used to build the Pull-Down-To-Refresh for loading more tasks / refetching
- **flutter_svg + cupertino_icons + cupertino_native_better + carousel_slider + [modal_bottom_sheet](https://github.com/jamesblasco/modal_bottom_sheet/tree/main)** - They were all used from a perspective of UI design, flutter_svg helped to render out SVG images, cupertino_icons enabled more iOS style icons for better compatability between devices, cupertino_native_better was used to build Liquid Glass Pop Up menu, if iOS 26 is avaliable, carousel_slider was used for image sliders and modal_bottom_sheet was used to build a iOS feel Sheet Container with better interface and configurability than the default Material https://api.flutter.dev/flutter/material/showModalBottomSheet.html

### Testing Libraries
- **build_runner + riverpod_generator + riverpod_lintr** - The build_runner helped with generating .g.dart or .mocks.dart files for testing and defining family providers, as used flutter_riverpod 3.x, which required for such code generations, used mainly for blog edit, as the route build needed 'id' - '/blog/:id', which in normal AsyncNotifier this cannot be done. And the lintr was added automatically as used when generating.
- **sqflite_common_ffi + mockito** - The sqflite_common_ffi was used during testing for better compability and mocking, and the mockito library allowed for test generation, and many utility functions that were used throughout all the tests, such as 'verify', 'argThat', etc.
