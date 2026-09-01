import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AppShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const AppShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12.0,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}

/// Shimmer Loading Skeleton for DashboardScreen
class DashboardShimmerLoading extends StatelessWidget {
  const DashboardShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Next Meeting Card Shimmer
        const AppShimmer(width: double.infinity, height: 160, borderRadius: 20),
        const SizedBox(height: 20),

        // Section Title Shimmer
        const AppShimmer(width: 220, height: 22, borderRadius: 6),
        const SizedBox(height: 12),

        // KPI Grid Shimmer (6 Cards)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: 6,
          itemBuilder: (_, _) => const AppShimmer(
            width: double.infinity,
            height: 90,
            borderRadius: 16,
          ),
        ),
        const SizedBox(height: 24),

        // Recent Transactions Title Shimmer
        const AppShimmer(width: 180, height: 22, borderRadius: 6),
        const SizedBox(height: 12),

        // 3 Transaction Card Shimmers
        const AppShimmer(
          width: double.infinity,
          height: 80,
          borderRadius: 16,
          margin: EdgeInsets.only(bottom: 10),
        ),
        const AppShimmer(
          width: double.infinity,
          height: 80,
          borderRadius: 16,
          margin: EdgeInsets.only(bottom: 10),
        ),
        const AppShimmer(
          width: double.infinity,
          height: 80,
          borderRadius: 16,
          margin: EdgeInsets.only(bottom: 10),
        ),
      ],
    );
  }
}

/// Shimmer Loading Skeleton for MemberListScreen
class MemberListShimmerLoading extends StatelessWidget {
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const MemberListShimmerLoading({
    super.key,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: const EdgeInsets.all(16),
      itemCount: 20,
      itemBuilder: (_, _) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const CircleAvatar(radius: 24, backgroundColor: Colors.white),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 140, height: 16, color: Colors.white),
                      const SizedBox(height: 6),
                      Container(width: 100, height: 12, color: Colors.white),
                    ],
                  ),
                ),
                Container(
                  width: 60,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shimmer Loading Skeleton for MemberDetailScreen
class MemberDetailShimmerLoading extends StatelessWidget {
  const MemberDetailShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Member Profile Banner Shimmer
        const AppShimmer(width: double.infinity, height: 110, borderRadius: 20),
        const SizedBox(height: 20),

        // Balances Section Title Shimmer
        const AppShimmer(width: 180, height: 22, borderRadius: 6),
        const SizedBox(height: 12),

        // 6 Account Balances Grid Shimmer
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: 6,
          itemBuilder: (_, _) => const AppShimmer(
            width: double.infinity,
            height: 90,
            borderRadius: 16,
          ),
        ),
        const SizedBox(height: 24),

        // Transactions Title Shimmer
        const AppShimmer(width: 190, height: 22, borderRadius: 6),
        const SizedBox(height: 12),

        // 4 Transaction Tile Shimmers
        const AppShimmer(
          width: double.infinity,
          height: 75,
          borderRadius: 16,
          margin: EdgeInsets.only(bottom: 10),
        ),
        const AppShimmer(
          width: double.infinity,
          height: 75,
          borderRadius: 16,
          margin: EdgeInsets.only(bottom: 10),
        ),
        const AppShimmer(
          width: double.infinity,
          height: 75,
          borderRadius: 16,
          margin: EdgeInsets.only(bottom: 10),
        ),
        const AppShimmer(
          width: double.infinity,
          height: 75,
          borderRadius: 16,
          margin: EdgeInsets.only(bottom: 10),
        ),
      ],
    );
  }
}

/// Shimmer Loading Skeleton for MeetingsScreen
class MeetingsListShimmerLoading extends StatelessWidget {
  const MeetingsListShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 20,
      itemBuilder: (_, _) => const AppShimmer(
        width: double.infinity,
        height: 130,
        borderRadius: 18,
        margin: EdgeInsets.only(bottom: 14),
      ),
    );
  }
}

/// Shimmer Loading Skeleton for MeetingDetailScreen
class MeetingDetailShimmerLoading extends StatelessWidget {
  const MeetingDetailShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Meeting Banner Shimmer
        const AppShimmer(width: double.infinity, height: 140, borderRadius: 20),
        const SizedBox(height: 20),

        // Assigned Members Title Shimmer
        const AppShimmer(width: 200, height: 22, borderRadius: 6),
        const SizedBox(height: 12),

        // Member List Card Shimmers
        const AppShimmer(
          width: double.infinity,
          height: 72,
          borderRadius: 14,
          margin: EdgeInsets.only(bottom: 10),
        ),
        const AppShimmer(
          width: double.infinity,
          height: 72,
          borderRadius: 14,
          margin: EdgeInsets.only(bottom: 10),
        ),

        const AppShimmer(
          width: double.infinity,
          height: 72,
          borderRadius: 14,
          margin: EdgeInsets.only(bottom: 10),
        ),
        const AppShimmer(
          width: double.infinity,
          height: 72,
          borderRadius: 14,
          margin: EdgeInsets.only(bottom: 10),
        ),
        const AppShimmer(
          width: double.infinity,
          height: 72,
          borderRadius: 14,
          margin: EdgeInsets.only(bottom: 10),
        ),
        const AppShimmer(
          width: double.infinity,
          height: 72,
          borderRadius: 14,
          margin: EdgeInsets.only(bottom: 10),
        ),
        const AppShimmer(
          width: double.infinity,
          height: 72,
          borderRadius: 14,
          margin: EdgeInsets.only(bottom: 10),
        ),
        const AppShimmer(
          width: double.infinity,
          height: 72,
          borderRadius: 14,
          margin: EdgeInsets.only(bottom: 10),
        ),
        const AppShimmer(
          width: double.infinity,
          height: 72,
          borderRadius: 14,
          margin: EdgeInsets.only(bottom: 10),
        ),
        const AppShimmer(
          width: double.infinity,
          height: 72,
          borderRadius: 14,
          margin: EdgeInsets.only(bottom: 10),
        ),
        const AppShimmer(
          width: double.infinity,
          height: 72,
          borderRadius: 14,
          margin: EdgeInsets.only(bottom: 10),
        ),
        const AppShimmer(
          width: double.infinity,
          height: 72,
          borderRadius: 14,
          margin: EdgeInsets.only(bottom: 10),
        ),

        const AppShimmer(
          width: double.infinity,
          height: 72,
          borderRadius: 14,
          margin: EdgeInsets.only(bottom: 10),
        ),
        const AppShimmer(
          width: double.infinity,
          height: 72,
          borderRadius: 14,
          margin: EdgeInsets.only(bottom: 10),
        ),
        const AppShimmer(
          width: double.infinity,
          height: 72,
          borderRadius: 14,
          margin: EdgeInsets.only(bottom: 10),
        ),
        const AppShimmer(
          width: double.infinity,
          height: 72,
          borderRadius: 14,
          margin: EdgeInsets.only(bottom: 10),
        ),
      ],
    );
  }
}

/// Shimmer Loading Skeleton for MemberProcessingScreen
class MemberProcessingShimmerLoading extends StatelessWidget {
  const MemberProcessingShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Member Banner Shimmer
        const AppShimmer(width: double.infinity, height: 70, borderRadius: 16),
        const SizedBox(height: 16),

        // Title Shimmer
        const AppShimmer(width: 210, height: 22, borderRadius: 6),
        const SizedBox(height: 16),

        // Input Fields Shimmer (5 fields)
        ...List.generate(
          20,
          (index) => const Padding(
            padding: EdgeInsets.only(bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppShimmer(width: 140, height: 16, borderRadius: 4),
                    AppShimmer(width: 90, height: 20, borderRadius: 8),
                  ],
                ),
                SizedBox(height: 8),
                AppShimmer(
                  width: double.infinity,
                  height: 50,
                  borderRadius: 12,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Submit Button Shimmer
        const AppShimmer(width: double.infinity, height: 52, borderRadius: 14),
      ],
    );
  }
}

/// Shimmer Loading Skeleton for TransactionListScreen
class TransactionListShimmerLoading extends StatelessWidget {
  const TransactionListShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 20,
      itemBuilder: (_, _) => const AppShimmer(
        width: double.infinity,
        height: 85,
        borderRadius: 16,
        margin: EdgeInsets.only(bottom: 10),
      ),
    );
  }
}

/// Shimmer Loading Skeleton for ReportsScreen & Category Reports
class ReportsDashboardShimmerLoading extends StatelessWidget {
  const ReportsDashboardShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // KPI Banner Shimmer
        const AppShimmer(width: double.infinity, height: 110, borderRadius: 20),
        const SizedBox(height: 16),

        // Grid Metric Shimmers (2x2)
        Row(
          children: const [
            Expanded(
              child: AppShimmer(
                width: double.infinity,
                height: 85,
                borderRadius: 16,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: AppShimmer(
                width: double.infinity,
                height: 85,
                borderRadius: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: const [
            Expanded(
              child: AppShimmer(
                width: double.infinity,
                height: 85,
                borderRadius: 16,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: AppShimmer(
                width: double.infinity,
                height: 85,
                borderRadius: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Section Title Shimmer
        const AppShimmer(width: 180, height: 20, borderRadius: 6),
        const SizedBox(height: 12),

        // Item Card Shimmers
        const AppShimmer(
          width: double.infinity,
          height: 70,
          borderRadius: 14,
          margin: EdgeInsets.only(bottom: 10),
        ),
        const AppShimmer(
          width: double.infinity,
          height: 70,
          borderRadius: 14,
          margin: EdgeInsets.only(bottom: 10),
        ),
        const AppShimmer(
          width: double.infinity,
          height: 70,
          borderRadius: 14,
          margin: EdgeInsets.only(bottom: 10),
        ),
      ],
    );
  }
}

/// Shimmer Loading Skeleton for GroupLoansScreen
class GroupLoansShimmerLoading extends StatelessWidget {
  const GroupLoansShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Action Card Shimmer
        const AppShimmer(width: double.infinity, height: 70, borderRadius: 16),
        const SizedBox(height: 20),

        // Title Shimmer
        const AppShimmer(width: 170, height: 20, borderRadius: 6),
        const SizedBox(height: 12),

        // 4 Group Loan History Cards
        const AppShimmer(
          width: double.infinity,
          height: 110,
          borderRadius: 18,
          margin: EdgeInsets.only(bottom: 12),
        ),
        const AppShimmer(
          width: double.infinity,
          height: 110,
          borderRadius: 18,
          margin: EdgeInsets.only(bottom: 12),
        ),
        const AppShimmer(
          width: double.infinity,
          height: 110,
          borderRadius: 18,
          margin: EdgeInsets.only(bottom: 12),
        ),
        const AppShimmer(
          width: double.infinity,
          height: 110,
          borderRadius: 18,
          margin: EdgeInsets.only(bottom: 12),
        ),
      ],
    );
  }
}

/// Shimmer Loading Skeleton for MemberPortalScreen
class MemberPortalShimmerLoading extends StatelessWidget {
  const MemberPortalShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Member Profile Banner Shimmer
        const AppShimmer(width: double.infinity, height: 100, borderRadius: 20),
        const SizedBox(height: 20),

        // Title Shimmer
        const AppShimmer(width: 160, height: 20, borderRadius: 6),
        const SizedBox(height: 12),

        // Grid Account Cards
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: 4,
          itemBuilder: (_, _) => const AppShimmer(
            width: double.infinity,
            height: 85,
            borderRadius: 16,
          ),
        ),
        const SizedBox(height: 20),

        // Activity Title Shimmer
        const AppShimmer(width: 180, height: 20, borderRadius: 6),
        const SizedBox(height: 12),

        // Activity Tile Shimmers
        const AppShimmer(
          width: double.infinity,
          height: 75,
          borderRadius: 16,
          margin: EdgeInsets.only(bottom: 10),
        ),
        const AppShimmer(
          width: double.infinity,
          height: 75,
          borderRadius: 16,
          margin: EdgeInsets.only(bottom: 10),
        ),
        const AppShimmer(
          width: double.infinity,
          height: 75,
          borderRadius: 16,
          margin: EdgeInsets.only(bottom: 10),
        ),
      ],
    );
  }
}
