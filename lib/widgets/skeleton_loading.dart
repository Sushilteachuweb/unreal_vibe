import 'package:flutter/material.dart';

class SkeletonLoading extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoading({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<SkeletonLoading> createState() => _SkeletonLoadingState();
}

class _SkeletonLoadingState extends State<SkeletonLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                const Color(0xFF1A1A1A),
                Color.lerp(const Color(0xFF1A1A1A), const Color(0xFF2A2A2A), _animation.value)!,
                const Color(0xFF1A1A1A),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

class EventCardSkeleton extends StatelessWidget {
  final bool isHorizontal;

  const EventCardSkeleton({
    Key? key,
    this.isHorizontal = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isHorizontal) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonLoading(
              width: double.infinity,
              height: 160,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonLoading(width: 120, height: 16),
                  const SizedBox(height: 8),
                  const SkeletonLoading(width: 80, height: 14),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const SkeletonLoading(width: 60, height: 12),
                      const SizedBox(width: 16),
                      const SkeletonLoading(width: 40, height: 12),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const SkeletonLoading(width: 100, height: 20),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SkeletonLoading(
            width: 100,
            height: 100,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonLoading(width: double.infinity, height: 16),
                  const SizedBox(height: 8),
                  const SkeletonLoading(width: 120, height: 14),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const SkeletonLoading(width: 60, height: 12),
                      const SizedBox(width: 16),
                      const SkeletonLoading(width: 40, height: 12),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const SkeletonLoading(width: 80, height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileCardSkeleton extends StatelessWidget {
  const ProfileCardSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLoading(width: 150, height: 18),
          const SizedBox(height: 16),
          Row(
            children: [
              const SkeletonLoading(width: 32, height: 32, borderRadius: BorderRadius.all(Radius.circular(8))),
              const SizedBox(width: 12),
              const Expanded(child: SkeletonLoading(width: double.infinity, height: 14)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const SkeletonLoading(width: 32, height: 32, borderRadius: BorderRadius.all(Radius.circular(8))),
              const SizedBox(width: 12),
              const Expanded(child: SkeletonLoading(width: double.infinity, height: 14)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const SkeletonLoading(width: 32, height: 32, borderRadius: BorderRadius.all(Radius.circular(8))),
              const SizedBox(width: 12),
              const Expanded(child: SkeletonLoading(width: double.infinity, height: 14)),
            ],
          ),
          const SizedBox(height: 16),
          const SkeletonLoading(width: double.infinity, height: 48, borderRadius: BorderRadius.all(Radius.circular(12))),
        ],
      ),
    );
  }
}

class ProfileHeaderSkeleton extends StatelessWidget {
  const ProfileHeaderSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          const SkeletonLoading(
            width: 60,
            height: 60,
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoading(width: 120, height: 20),
                const SizedBox(height: 8),
                const SkeletonLoading(width: 80, height: 14),
                const SizedBox(height: 8),
                const SkeletonLoading(width: 100, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EventDetailsSkeleton extends StatelessWidget {
  const EventDetailsSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // App bar skeleton
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event header skeleton
                  const SkeletonLoading(width: 250, height: 24),
                  const SizedBox(height: 20),
                  // Hosted by skeleton
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const SkeletonLoading(
                          width: 50, 
                          height: 50, 
                          borderRadius: BorderRadius.all(Radius.circular(25))
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SkeletonLoading(width: 80, height: 12),
                              SizedBox(height: 4),
                              SkeletonLoading(width: 120, height: 16),
                            ],
                          ),
                        ),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SkeletonLoading(width: 60, height: 14),
                            SkeletonLoading(width: 40, height: 12),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Event info skeleton
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              SkeletonLoading(width: 20, height: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SkeletonLoading(width: double.infinity, height: 12),
                                    SizedBox(height: 4),
                                    SkeletonLoading(width: 80, height: 10),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              SkeletonLoading(width: 20, height: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SkeletonLoading(width: double.infinity, height: 12),
                                    SizedBox(height: 4),
                                    SkeletonLoading(width: 80, height: 10),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Action buttons skeleton
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Event details info skeleton
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2A2A2A)),
                    ),
                    child: Column(
                      children: List.generate(4, (index) => 
                        Padding(
                          padding: EdgeInsets.only(bottom: index < 3 ? 16 : 0),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SkeletonLoading(
                                width: 48, 
                                height: 48, 
                                borderRadius: BorderRadius.all(Radius.circular(12))
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 12),
                                  child: SkeletonLoading(width: double.infinity, height: 15),
                                ),
                              ),
                            ],
                          ),
                        )
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TicketBookingSkeleton extends StatelessWidget {
  const TicketBookingSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Column(
          children: [
            // Header skeleton
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1B2E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: SkeletonLoading(width: 120, height: 18),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            // Content skeleton
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event title skeleton
                    const SkeletonLoading(width: 250, height: 28),
                    const SizedBox(height: 8),
                    const SkeletonLoading(width: 150, height: 15),
                    const SizedBox(height: 24),
                    // Ticket quantity skeleton
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1625),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          SkeletonLoading(width: 44, height: 44, borderRadius: BorderRadius.all(Radius.circular(12))),
                          SizedBox(width: 16),
                          Expanded(child: SkeletonLoading(width: double.infinity, height: 16)),
                          SkeletonLoading(width: 120, height: 36, borderRadius: BorderRadius.all(Radius.circular(12))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Pricing skeleton
                    Column(
                      children: [
                        const SkeletonLoading(width: 150, height: 14),
                        const SizedBox(height: 16),
                        ...List.generate(3, (index) => 
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SkeletonLoading(width: 100, height: 15),
                                const SkeletonLoading(width: 60, height: 15),
                              ],
                            ),
                          )
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Form fields skeleton
                    const SkeletonLoading(width: 100, height: 18),
                    const SizedBox(height: 16),
                    ...List.generate(4, (index) => 
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1625),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      )
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class TicketCardSkeleton extends StatelessWidget {
  const TicketCardSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Event Info Section
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Event Image skeleton
                const SkeletonLoading(
                  width: 80,
                  height: 80,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                const SizedBox(width: 16),
                // Event Details skeleton
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoading(width: double.infinity, height: 18),
                      SizedBox(height: 6),
                      SkeletonLoading(width: 120, height: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Dashed Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              height: 1,
              color: const Color(0xFF404040),
            ),
          ),
          // Date and Venue Info skeleton
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Date and Time Row skeleton
                const Row(
                  children: [
                    SkeletonLoading(width: 18, height: 18),
                    SizedBox(width: 10),
                    SkeletonLoading(width: 150, height: 14),
                  ],
                ),
                const SizedBox(height: 14),
                // Venue Row skeleton
                const Row(
                  children: [
                    SkeletonLoading(width: 18, height: 18),
                    SizedBox(width: 10),
                    SkeletonLoading(width: 120, height: 14),
                  ],
                ),
                const SizedBox(height: 16),
                // Action Buttons skeleton
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class RefreshLoadingIndicator extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const RefreshLoadingIndicator({
    Key? key,
    required this.isLoading,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 3,
              child: const LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6958CA)),
              ),
            ),
          ),
      ],
    );
  }
}