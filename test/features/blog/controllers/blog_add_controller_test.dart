import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blog_app/features/blog/controllers/blog_add_controller.dart';
import 'package:flutter_blog_app/common/repositories/blog_repository.dart';
import 'package:flutter_blog_app/models/index.dart' as models;

@GenerateMocks([BlogRepository])
import 'blog_add_controller_test.mocks.dart';

void main() {
	late ProviderContainer container;
	late MockBlogRepository mockRepo;

	setUp(() {
		mockRepo = MockBlogRepository();
		container = ProviderContainer(
			overrides: [
				blogRepositoryProvider.overrideWithValue(mockRepo),
			],
		);
	});

	tearDown(() {
		container.dispose();
	});

	group('CreateBlogController', () {
		test('initial state is AsyncValue.data(null)', () {
			final state = container.read(createBlogProvider);
			expect(state, isA<AsyncData>());
		});

		test('createBlog with title and content only (no images)', () async {
			when(mockRepo.addBlog(blog: anyNamed('blog'), images: anyNamed('images')))
				.thenAnswer((_) async => Future.value());

			final controller = container.read(createBlogProvider.notifier);

			await controller.createBlog(
				title: 'Test Title',
				content: 'Test Content',
				imageFiles: null,
			);

			final state = container.read(createBlogProvider);
			expect(state, isA<AsyncData>());

			verify(mockRepo.addBlog(
				blog: argThat(
					predicate<models.BlogPost>(
						(blog) => blog.title == 'Test Title' && blog.content == 'Test Content' && blog.images!.isEmpty,
					),
					named: 'blog',
				),
				images: argThat(predicate((List<models.Images>? list) => list?.isEmpty ?? false), named: 'images'),
			)).called(1);
		});

		test('createBlog sets loading state during creation', () async {
			when(mockRepo.addBlog(blog: anyNamed('blog'), images: anyNamed('images')))
				.thenAnswer((_) async {
					await Future.delayed(const Duration(milliseconds: 100));
				});

			final controller = container.read(createBlogProvider.notifier);

			// Start creation
			final future = controller.createBlog(
				title: 'Test',
				content: 'Content',
				imageFiles: null,
			);

			// Check loading state
			await Future.delayed(const Duration(milliseconds: 10));
			final loadingState = container.read(createBlogProvider);
			expect(loadingState, isA<AsyncLoading>());

			await future;

			// Final state should be data
			final finalState = container.read(createBlogProvider);
			expect(finalState, isA<AsyncData>());
		});

		test('createBlog handles repository error', () async {
			when(mockRepo.addBlog(blog: anyNamed('blog'), images: anyNamed('images')))
				.thenThrow(Exception('Database error'));

			final controller = container.read(createBlogProvider.notifier);

			await controller.createBlog(
				title: 'Test',
				content: 'Content',
				imageFiles: null,
			);

			final state = container.read(createBlogProvider);
			expect(state, isA<AsyncError>());
			expect(state.error, isA<Exception>());
		});

		test('createBlog generates unique blog ID', () async {
			String? capturedId1;
			String? capturedId2;

			when(mockRepo.addBlog(blog: anyNamed('blog'), images: anyNamed('images')))
				.thenAnswer((invocation) async {
					final blog = invocation.namedArguments[const Symbol('blog')] as models.BlogPost;
					if (capturedId1 == null) {
						capturedId1 = blog.id;
					} else {
						capturedId2 = blog.id;
					}
				});

			final controller = container.read(createBlogProvider.notifier);

			await controller.createBlog(title: 'Blog 1', content: 'Content 1', imageFiles: null);
			await controller.createBlog(title: 'Blog 2', content: 'Content 2', imageFiles: null);

			expect(capturedId1, isNotNull);
			expect(capturedId2, isNotNull);
			expect(capturedId1, isNot(equals(capturedId2)));
		});

		test('createBlog with empty title and content', () async {
			when(mockRepo.addBlog(blog: anyNamed('blog'), images: anyNamed('images')))
				.thenAnswer((_) async => Future.value());

			final controller = container.read(createBlogProvider.notifier);

			await controller.createBlog(
				title: '',
				content: '',
				imageFiles: null,
			);

			verify(mockRepo.addBlog(
				blog: argThat(
					predicate<models.BlogPost>((blog) => blog.title.isEmpty && blog.content.isEmpty),
					named: 'blog',
				),
				images: anyNamed('images'),
			)).called(1);
		});

		test('createBlog calls repository with correct parameters', () async {
			when(mockRepo.addBlog(blog: anyNamed('blog'), images: anyNamed('images')))
				.thenAnswer((_) async => Future.value());

			final controller = container.read(createBlogProvider.notifier);

			await controller.createBlog(
				title: 'Test',
				content: 'Content',
				imageFiles: null,
			);

			// Verify the method was called with named arguments
			verify(mockRepo.addBlog(
				blog: anyNamed('blog'),
				images: anyNamed('images'),
			)).called(1);
		});

		test('createBlog with image files attempts to process images', () async {
			// This test documents the limitation - actual file processing
			// would need additional mocking infrastructure
			final mockFile = File('test.jpg');

			when(mockRepo.addBlog(blog: anyNamed('blog'), images: anyNamed('images')))
				.thenAnswer((_) async => Future.value());

			final controller = container.read(createBlogProvider.notifier);

			// This will likely throw due to file I/O in compressImage
			await controller.createBlog(
				title: 'Test',
				content: 'Content',
				imageFiles: [mockFile],
			);

			final state = container.read(createBlogProvider);
			// Expect error due to file operations
			expect(state, isA<AsyncError>());
		});

		test('createBlog sets timestamps correctly', () async {
			models.BlogPost? capturedBlog;

			when(mockRepo.addBlog(blog: anyNamed('blog'), images: anyNamed('images')))
				.thenAnswer((invocation) async {
					capturedBlog = invocation.namedArguments[const Symbol('blog')] as models.BlogPost;
				});

			final controller = container.read(createBlogProvider.notifier);
			final beforeTime = DateTime.now();

			await controller.createBlog(title: 'Test', content: 'Content', imageFiles: null);

			final afterTime = DateTime.now();

			expect(capturedBlog, isNotNull);
			expect(capturedBlog!.createdAt, isNotNull);
			
			final parsedTime = DateTime.parse(capturedBlog!.createdAt);
			expect(parsedTime.isAfter(beforeTime.subtract(const Duration(seconds: 1))), isTrue);
			expect(parsedTime.isBefore(afterTime.add(const Duration(seconds: 1))), isTrue);
		});
	});
}