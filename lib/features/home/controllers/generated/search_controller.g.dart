// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../search_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the current search query (AppBar TextField will update this)

@ProviderFor(SearchQuery)
const searchQueryProvider = SearchQueryProvider._();

/// Holds the current search query (AppBar TextField will update this)
final class SearchQueryProvider extends $NotifierProvider<SearchQuery, String> {
  /// Holds the current search query (AppBar TextField will update this)
  const SearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchQueryHash();

  @$internal
  @override
  SearchQuery create() => SearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$searchQueryHash() => r'8fb1b07f8448e1c1f11ce831b6ea5fc011af6869';

/// Holds the current search query (AppBar TextField will update this)

abstract class _$SearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Search results provider (query-driven)

@ProviderFor(SearchResults)
const searchResultsProvider = SearchResultsFamily._();

/// Search results provider (query-driven)
final class SearchResultsProvider
    extends $AsyncNotifierProvider<SearchResults, List<models.BlogPost>> {
  /// Search results provider (query-driven)
  const SearchResultsProvider._({
    required SearchResultsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'searchResultsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchResultsHash();

  @override
  String toString() {
    return r'searchResultsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SearchResults create() => SearchResults();

  @override
  bool operator ==(Object other) {
    return other is SearchResultsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchResultsHash() => r'bda8f81a3bee81c34aa2b6fd2abb4464738cf1d2';

/// Search results provider (query-driven)

final class SearchResultsFamily extends $Family
    with
        $ClassFamilyOverride<
          SearchResults,
          AsyncValue<List<models.BlogPost>>,
          List<models.BlogPost>,
          FutureOr<List<models.BlogPost>>,
          String
        > {
  const SearchResultsFamily._()
    : super(
        retry: null,
        name: r'searchResultsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Search results provider (query-driven)

  SearchResultsProvider call(String query) =>
      SearchResultsProvider._(argument: query, from: this);

  @override
  String toString() => r'searchResultsProvider';
}

/// Search results provider (query-driven)

abstract class _$SearchResults extends $AsyncNotifier<List<models.BlogPost>> {
  late final _$args = ref.$arg as String;
  String get query => _$args;

  FutureOr<List<models.BlogPost>> build(String query);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref
            as $Ref<AsyncValue<List<models.BlogPost>>, List<models.BlogPost>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<models.BlogPost>>,
                List<models.BlogPost>
              >,
              AsyncValue<List<models.BlogPost>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
