import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../article/article_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('EcoHome Guide'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Solar Panel Hub'),
              Tab(text: 'Smart Home'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ArticleList(category: 'Solar Panel Hub'),
            _ArticleList(category: 'Smart Home Solutions'),
          ],
        ),
      ),
    );
  }
}

class _ArticleList extends StatelessWidget {
  final String category;

  const _ArticleList({required this.category});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('articles')
          .where('category', isEqualTo: category)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final articles = snapshot.data?.docs ?? [];

        if (articles.isEmpty) {
          return const Center(child: Text('No articles found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: articles.length,
          itemBuilder: (context, index) {
            final article = articles[index].data() as Map<String, dynamic>;
            return _ArticleCard(
              title: article['title'] as String,
              imageUrl: article['imageUrl'] as String,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArticleDetailScreen(
                      articleId: articles[index].id,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onTap;

  const _ArticleCard({
    required this.title,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
