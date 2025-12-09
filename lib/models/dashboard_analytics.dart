class DashboardAnalytics {
  final DashboardOverview overview;
  final DashboardRevenue revenue;
  final DashboardBookings bookings;
  final DashboardInsights insights;

  DashboardAnalytics({
    required this.overview,
    required this.revenue,
    required this.bookings,
    required this.insights,
  });

  factory DashboardAnalytics.fromJson(Map<String, dynamic> json) {
    return DashboardAnalytics(
      overview: DashboardOverview.fromJson(json['overview'] ?? {}),
      revenue: DashboardRevenue.fromJson(json['revenue'] ?? {}),
      bookings: DashboardBookings.fromJson(json['bookings'] ?? {}),
      insights: DashboardInsights.fromJson(json['insights'] ?? {}),
    );
  }
}

class DashboardOverview {
  final int totalVenues;
  final int totalCourts;
  final int activeCourts;
  final int availableCourts;
  final int totalBookings;
  final int confirmedBookings;
  final int pendingBookings;
  final int completedBookings;

  DashboardOverview({
    required this.totalVenues,
    required this.totalCourts,
    required this.activeCourts,
    required this.availableCourts,
    required this.totalBookings,
    required this.confirmedBookings,
    required this.pendingBookings,
    required this.completedBookings,
  });

  factory DashboardOverview.fromJson(Map<String, dynamic> json) {
    return DashboardOverview(
      totalVenues: json['totalVenues'] ?? 0,
      totalCourts: json['totalCourts'] ?? 0,
      activeCourts: json['activeCourts'] ?? 0,
      availableCourts: json['availableCourts'] ?? 0,
      totalBookings: json['totalBookings'] ?? 0,
      confirmedBookings: json['confirmedBookings'] ?? 0,
      pendingBookings: json['pendingBookings'] ?? 0,
      completedBookings: json['completedBookings'] ?? 0,
    );
  }
}

class DashboardRevenue {
  final double total;
  final double completed;
  final double last7Days;
  final double last30Days;

  DashboardRevenue({
    required this.total,
    required this.completed,
    required this.last7Days,
    required this.last30Days,
  });

  factory DashboardRevenue.fromJson(Map<String, dynamic> json) {
    return DashboardRevenue(
      total: (json['total'] ?? 0).toDouble(),
      completed: (json['completed'] ?? 0).toDouble(),
      last7Days: (json['last7Days'] ?? 0).toDouble(),
      last30Days: (json['last30Days'] ?? 0).toDouble(),
    );
  }
}

class DashboardBookings {
  final int last7Days;
  final int last30Days;
  final Map<String, int> byStatus;

  DashboardBookings({
    required this.last7Days,
    required this.last30Days,
    required this.byStatus,
  });

  factory DashboardBookings.fromJson(Map<String, dynamic> json) {
    final statusMap = json['byStatus'] as Map<String, dynamic>? ?? {};
    return DashboardBookings(
      last7Days: json['last7Days'] ?? 0,
      last30Days: json['last30Days'] ?? 0,
      byStatus: statusMap.map((key, value) => MapEntry(key, value as int)),
    );
  }
}

class DashboardInsights {
  final List<String> peakHours;
  final List<BookingPerCourt> bookingsPerCourt;
  final double averageBookingValue;

  DashboardInsights({
    required this.peakHours,
    required this.bookingsPerCourt,
    required this.averageBookingValue,
  });

  factory DashboardInsights.fromJson(Map<String, dynamic> json) {
    return DashboardInsights(
      peakHours: (json['peakHours'] as List?)?.map((e) => e.toString()).toList() ?? [],
      bookingsPerCourt: (json['bookingsPerCourt'] as List?)
          ?.map((e) => BookingPerCourt.fromJson(e))
          .toList() ??
          [],
      averageBookingValue: (json['averageBookingValue'] ?? 0).toDouble(),
    );
  }
}

class BookingPerCourt {
  final String courtId;
  final String courtName;
  final int totalBookings;
  final double revenue;

  BookingPerCourt({
    required this.courtId,
    required this.courtName,
    required this.totalBookings,
    required this.revenue,
  });

  factory BookingPerCourt.fromJson(Map<String, dynamic> json) {
    return BookingPerCourt(
      courtId: json['courtId'] ?? '',
      courtName: json['courtName'] ?? '',
      totalBookings: json['totalBookings'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
    );
  }
}
