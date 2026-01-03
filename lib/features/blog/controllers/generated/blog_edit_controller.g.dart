// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../blog_edit_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EditBlog)
const editBlogProvider = EditBlogFamily._();

final class EditBlogProvider
    extends $AsyncNotifierProvider<EditBlog, models.BlogPost?> {
  const EditBlogProvider._({
    required EditBlogFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'editBlogProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$editBlogHash();

  @override
  String toString() {
    return r'editBlogProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EditBlog create() => EditBlog();

  @override
  bool operator ==(Object other) {
    return other is EditBlogProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$editBlogHash() => r'8ae1819016f42b097436afe47d2ec6e00cdb8440';

final class EditBlogFamily extends $Family
    with
        $ClassFamilyOverride<
          EditBlog,
          AsyncValue<models.BlogPost?>,
          models.BlogPost?,
          FutureOr<models.BlogPost?>,
          String
        > {
  const EditBlogFamily._()
    : super(
        retry: null,
        name: r'editBlogProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EditBlogProvider call(String id) =>
      EditBlogProvider._(argument: id, from: this);

  @override
  String toString() => r'editBlogProvider';
}

abstract class _$EditBlog extends $AsyncNotifier<models.BlogPost?> {
  late final _$args = ref.$arg as String;
  String get id => _$args;

  FutureOr<models.BlogPost?> build(String id);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<models.BlogPost?>, models.BlogPost?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<models.BlogPost?>, models.BlogPost?>,
              AsyncValue<models.BlogPost?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
