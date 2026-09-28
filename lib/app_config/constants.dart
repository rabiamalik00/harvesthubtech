class AppConstants {
  // EmailJS API Credentials
  static const String emailJsServiceId = 'service_pjq7w9w';
  static const String emailJsTemplateId = 'template_w9p3f0n';
  static const String emailJsUserId = 'h21hbo3QI2ceMX7Jq';
  static const String emailJsPrivateKey = ''; // Add your EmailJS Private Key here if Strict Mode is enabled
  static const String emailJsApiUrl = 'https://api.emailjs.com/api/v1.0/email/send';

  // Firestore Collection Names (SRS Specification)
  static const String collectionUsers = 'users';
  static const String collectionFarmers = 'farmers';
  static const String collectionProducts = 'products';
  static const String collectionOrders = 'orders';
  static const String collectionMarkets = 'farmers_market';

  // Roles
  static const String roleCustomer = 'Customer';
  static const String roleFarmer = 'Farmer';
  static const String roleAdmin = 'Admin';

  // Admin credentials (hard‑coded for platform admin; not stored in DB)
  static const String adminEmail = 'admin@harvesthub.com';
  static const String adminPassword = 'admin123';

  // Product Categories
  static const List<String> categories = [
    'Fruits',
    'Vegetables',
    'Grains',
    'Dairy',
    'Herbs',
    'Organic',
  ];

  // Order Statuses
  static const String statusPending = 'Pending';
  static const String statusConfirmed = 'Confirmed';
  static const String statusReadyForPickup = 'Ready for Pickup';
  static const String statusCompleted = 'Completed';
  static const String statusCancelled = 'Cancelled';

  /// SRS Scope & Implementation Note on Push Notifications / Restock Alerts:
  /// Section 1.4 defines Restock / Status Notifications, while Section 1.5 places external
  /// third-party cloud paid push servers outside the baseline offline-first scope.
  /// To satisfy SRS requirements completely, HarvestHub features an In-App Notification Engine
  /// with live Restock Alert subscriptions, out-of-stock badge triggers, and order status updates.
  static const bool enablePushNotifications = true;
}
