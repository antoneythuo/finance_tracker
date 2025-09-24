import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingWidget extends StatelessWidget {
  final LoadingState state;
  const LoadingWidget({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case LoadingState.transactionList:
        return ListView.separated(
          itemCount: 6,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) => Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      case LoadingState.general:
        return const Center(child: CircularProgressIndicator());
      case LoadingState.empty:
        return Center(
          child: Text('No data available', style: Theme.of(context).textTheme.labelSmall),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

enum LoadingState { transactionList, general, empty }
