import 'package:flutter/material.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({
    super.key,
    required this.username,
    required this.score,
  });

  final String username;
  final int score;

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String selectedCategory = 'All';
  final List<String> categories = [
    'All',
    'Bottled waters',
    'Water filters',
    'Supplements',
  ];

  String _getScoreLabel(int score) {
    if (score >= 75) return 'Good';
    if (score >= 50) return 'Fair';
    return 'Poor';
  }

  Color _getScoreColor(int score) {
    if (score >= 75) return const Color(0xFF10B981);
    if (score >= 50) return const Color(0xFFF97316);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.orange.shade200,
                          Colors.pink.shade200,
                          Colors.purple.shade300,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Username and Score
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '@${widget.username}...',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '${widget.score}',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: _getScoreColor(widget.score),
                                height: 1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getScoreLabel(widget.score),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: _getScoreColor(widget.score),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Health Bar
              LayoutBuilder(
                builder: (context, constraints) {
                  final barWidth = constraints.maxWidth;
                  final indicatorSize = 20.0;
                  final scorePosition = (widget.score / 100) * barWidth;
                  // Clamp position to keep indicator within bounds
                  final clampedPosition = (scorePosition - indicatorSize / 2)
                      .clamp(0.0, barWidth - indicatorSize);

                  return Container(
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFEF4444), // Red
                          Color(0xFFF97316), // Orange
                          Color(0xFFFBBF24), // Yellow
                          Color(0xFF84CC16), // Light green
                          Color(0xFF10B981), // Green
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Score indicator
                        Positioned(
                          left: clampedPosition,
                          top: 2,
                          child: Container(
                            width: indicatorSize,
                            height: indicatorSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: _getScoreColor(widget.score),
                                width: 2.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              // Category Filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((category) {
                    final isSelected = selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              // Content area (placeholder)
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Content for "$selectedCategory"',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
