// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'individual_blog_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(IndividualBlog)
const individualBlogProvider = IndividualBlogFamily._();

final class IndividualBlogProvider
    extends $AsyncNotifierProvider<IndividualBlog, models.BlogPost?> {
  const IndividualBlogProvider._({
    required IndividualBlogFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'individualBlogProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$individualBlogHash();

  @override
  String toString() {
    return r'individualBlogProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  IndividualBlog create() => IndividualBlog();

  @override
  bool operator ==(Object other) {
    return other is IndividualBlogProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$individualBlogHash() => r'e52bfd90933962d17cf0f5d64fd13de5265996d0';

final class IndividualBlogFamily extends $Family
    with
        $ClassFamilyOverride<
          IndividualBlog,
          AsyncValue<models.BlogPost?>,
          models.BlogPost?,
          FutureOr<models.BlogPost?>,
          String
        > {
  const IndividualBlogFamily._()
    : super(
        retry: null,
        name: r'individualBlogProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  IndividualBlogProvider call(String id) =>
      IndividualBlogProvider._(argument: id, from: this);

  @override
  String toString() => r'individualBlogProvider';
}

abstract class _$IndividualBlog extends $AsyncNotifier<models.BlogPost?> {
  late final _$args = ref.$arg as String;
  String get id => _$args;

  FutureOr<models.BlogPost?> build(String id);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref as $Ref<AsyncValue<models.BlogPost?>, models.BlogPost?>;
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
