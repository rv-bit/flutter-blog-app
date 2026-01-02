// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../blog_checks_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(blogExists)
const blogExistsProvider = BlogExistsFamily._();

final class BlogExistsProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  const BlogExistsProvider._({
    required BlogExistsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'blogExistsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$blogExistsHash();

  @override
  String toString() {
    return r'blogExistsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as String;
    return blogExists(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BlogExistsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$blogExistsHash() => r'b2898b641309c51d089283d1fe10cd1935c8231b';

final class BlogExistsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  const BlogExistsFamily._()
    : super(
        retry: null,
        name: r'blogExistsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BlogExistsProvider call(String id) =>
      BlogExistsProvider._(argument: id, from: this);

  @override
  String toString() => r'blogExistsProvider';
}
