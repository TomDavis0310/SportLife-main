class NumberUtils {
  NumberUtils._();

  static String formatNumber(int? number) {
    if (number == null) return '0';

    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  static String formatPoints(int? points) {
    if (points == null) return '0 điểm';
    return '$points điểm';
  }

  static String formatPercentage(double? value) {
    if (value == null) return '0%';
    return '${value.toStringAsFixed(1)}%';
  }

  static String formatOrdinal(int number) {
    if (number == 1) return '1st';
    if (number == 2) return '2nd';
    if (number == 3) return '3rd';
    return '${number}th';
  }

  static String formatRank(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '#$rank';
    }
  }

  static String formatScore(int home, int away) {
    return '$home - $away';
  }

  static String formatCurrency(double amount, {String symbol = '₫'}) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M $symbol';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K $symbol';
    }
    return '${amount.toStringAsFixed(0)} $symbol';
  }
}


