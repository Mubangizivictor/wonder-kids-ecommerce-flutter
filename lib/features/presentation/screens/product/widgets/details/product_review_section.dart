import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:ecom/features/domain/models/product_model.dart';
import 'package:ecom/features/domain/models/review_model.dart';
import 'package:ecom/features/presentation/providers/review_provider.dart';
import 'package:ecom/features/presentation/providers/auth_provider.dart';
import 'package:ecom/core/theme/app_colors.dart';

class ProductReviewSection extends StatelessWidget {
  final ProductModel product;
  final bool hasPurchased;
  final VoidCallback onWriteReview;

  const ProductReviewSection({
    super.key,
    required this.product,
    required this.hasPurchased,
    required this.onWriteReview,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reviewProvider = Provider.of<ReviewProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Customer Reviews',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (hasPurchased)
                TextButton(
                  onPressed: onWriteReview,
                  child: const Text('Write a review'),
                )
              else if (authProvider.isAuthenticated)
                Text(
                  'Purchase to review',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _buildReviewSummary(product.rating, product.reviewCount),
          const SizedBox(height: 24),
          
          if (reviewProvider.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (reviewProvider.reviews.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('No reviews yet. Be the first to review!'),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviewProvider.reviews.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final review = reviewProvider.reviews[index];
                return _buildReviewItem(context, review);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildReviewSummary(double rating, int count) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rating.toStringAsFixed(1),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  LucideIcons.star,
                  size: 16,
                  color: index < rating.floor() ? AppColors.rating : AppColors.starGrey,
                );
              }),
            ),
            const SizedBox(height: 4),
            Text('$count total ratings'),
          ],
        ),
        const SizedBox(width: 32),
        Expanded(
          child: Column(
            children: [
              _buildRatingBar(5, 0.8),
              _buildRatingBar(4, 0.15),
              _buildRatingBar(3, 0.03),
              _buildRatingBar(2, 0.01),
              _buildRatingBar(1, 0.01),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingBar(int stars, double percentage) {
    return Row(
      children: [
        Text('$stars star', style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: AppColors.starGrey,
              color: AppColors.rating,
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('${(percentage * 100).toInt()}%', style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildReviewItem(BuildContext context, ReviewModel review) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.grey.shade300,
                child: const Icon(LucideIcons.user, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Text(review.userName, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              ...List.generate(5, (index) {
                return Icon(
                  LucideIcons.star,
                  size: 14,
                  color: index < review.rating.floor() ? AppColors.rating : AppColors.starGrey,
                );
              }),
              const SizedBox(width: 8),
              Text(review.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Reviewed on ${review.date.day}/${review.date.month}/${review.date.year}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(review.comment, style: const TextStyle(height: 1.4)),
        ],
      ),
    );
  }
}
