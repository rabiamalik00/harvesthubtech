import '../app_config/constants.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/bid_model.dart';
import '../models/dispute_model.dart';
import '../models/weather_advisory_model.dart';

class MockData {
  static List<UserModel> get initialUsers => [
    UserModel(
      uid: 'farmer_01',
      name: 'Chaudhry Bashir Ahmed',
      email: 'bashir.farmer@harvesthub.pk',
      phone: '+92 300 4567890',
      role: AppConstants.roleFarmer,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    UserModel(
      uid: 'farmer_02',
      name: 'Malik Zafar Iqbal',
      email: 'zafar.citrus@harvesthub.pk',
      phone: '+92 302 9876543',
      role: AppConstants.roleFarmer,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    UserModel(
      uid: 'buyer_01',
      name: 'Tariq Mehmood',
      email: 'tariq.buyer@gmail.com',
      phone: '+92 321 1122334',
      role: AppConstants.roleCustomer,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    UserModel(
      uid: 'admin_01',
      name: 'HarvestHub System Admin',
      email: 'admin@harvesthub.com',
      phone: '+92 333 5556677',
      role: AppConstants.roleAdmin,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
  ];

  static List<ProductModel> get initialProducts => [
    ProductModel(
      productId: 'prod_01',
      farmerId: 'farmer_01',
      itemName: 'Super Basmati Premium Rice',
      category: 'Grains',
      pricePerUnit: 280.0,
      stockQty: 450,
      imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=600&auto=format&fit=crop',
      farmerName: 'Chaudhry Bashir Ahmed',
      marketName: 'Faisalabad Model Mandi Market',
    ),
    ProductModel(
      productId: 'prod_02',
      farmerId: 'farmer_02',
      itemName: 'Sweet Juicy Kinnow (Export Grade)',
      category: 'Fruits',
      pricePerUnit: 190.0,
      stockQty: 600,
      imageUrl: 'https://images.unsplash.com/photo-1611080626919-7cf5a9dbab5b?w=600&auto=format&fit=crop',
      farmerName: 'Malik Zafar Iqbal',
      marketName: 'Sargodha Mandi Bazaar',
    ),
    ProductModel(
      productId: 'prod_03',
      farmerId: 'farmer_01',
      itemName: 'Fresh Farm Red Tomatoes',
      category: 'Vegetables',
      pricePerUnit: 120.0,
      stockQty: 250,
      imageUrl: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=600&auto=format&fit=crop',
      farmerName: 'Chaudhry Bashir Ahmed',
      marketName: 'Faisalabad Model Mandi Market',
    ),
    ProductModel(
      productId: 'prod_04',
      farmerId: 'farmer_01',
      itemName: 'Desi Whole Wheat (Kanak)',
      category: 'Grains',
      pricePerUnit: 110.0,
      stockQty: 950,
      imageUrl: 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=600&auto=format&fit=crop',
      farmerName: 'Chaudhry Bashir Ahmed',
      marketName: 'Faisalabad Model Mandi Market',
    ),
    ProductModel(
      productId: 'prod_05',
      farmerId: 'farmer_02',
      itemName: 'Red Skin Table Potatoes',
      category: 'Vegetables',
      pricePerUnit: 85.0,
      stockQty: 500,
      imageUrl: 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=600&auto=format&fit=crop',
      farmerName: 'Malik Zafar Iqbal',
      marketName: 'Sargodha Mandi Bazaar',
    ),
    ProductModel(
      productId: 'prod_06',
      farmerId: 'farmer_01',
      itemName: 'Organic Farm Spinach (Palak)',
      category: 'Organic',
      pricePerUnit: 75.0,
      stockQty: 120,
      imageUrl: 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=600&auto=format&fit=crop',
      farmerName: 'Chaudhry Bashir Ahmed',
      marketName: 'Faisalabad Model Mandi Market',
    ),
  ];

  static List<OrderModel> get initialOrders => [
    OrderModel(
      orderId: 'ORD-7021',
      customerId: 'buyer_01',
      farmerId: 'farmer_01',
      items: [
        OrderItemModel(
          productId: 'prod_01',
          itemName: 'Super Basmati Premium Rice',
          quantity: 25,
          pricePerUnit: 280.0,
        ),
        OrderItemModel(
          productId: 'prod_03',
          itemName: 'Fresh Farm Red Tomatoes',
          quantity: 10,
          pricePerUnit: 120.0,
        ),
      ],
      pickupSlotTime: '10:00 AM - 12:00 PM',
      status: AppConstants.statusConfirmed,
      totalPrice: 8200.0,
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      customerName: 'Tariq Mehmood',
      farmerBusinessName: 'Chaudhry Bashir Ahmed',
    ),
    OrderModel(
      orderId: 'ORD-6890',
      customerId: 'buyer_01',
      farmerId: 'farmer_02',
      items: [
        OrderItemModel(
          productId: 'prod_02',
          itemName: 'Sweet Juicy Kinnow (Export Grade)',
          quantity: 60,
          pricePerUnit: 190.0,
        ),
      ],
      pickupSlotTime: '02:00 PM - 04:00 PM',
      status: AppConstants.statusCompleted,
      totalPrice: 11400.0,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      customerName: 'Tariq Mehmood',
      farmerBusinessName: 'Malik Zafar Iqbal',
    ),
  ];

  static List<BidModel> get initialBids => [
    BidModel(
      id: 'BID-101',
      productId: 'prod_02',
      productName: 'Sweet Juicy Kinnow (Export Grade)',
      buyerId: 'buyer_01',
      buyerName: 'Tariq Mehmood',
      farmerId: 'farmer_02',
      farmerName: 'Malik Zafar Iqbal',
      requestedQtyKg: 100,
      originalPricePerKg: 190.0,
      offeredPricePerKg: 165.0,
      counterPricePerKg: 175.0,
      status: BidStatus.counterOffered,
      message: 'Need 100kg lot for corporate distribution. Can we settle at 165?',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
  ];

  static List<DisputeModel> get initialDisputes => [
    DisputeModel(
      id: 'DSP-501',
      orderId: 'ORD-6890',
      raisedByUserId: 'buyer_01',
      raisedByUserName: 'Tariq Mehmood',
      partyInvolvedName: 'Malik Zafar Iqbal',
      issueType: 'Packaging Issue',
      description: 'One crate suffered mild pressing during transit. Products were mostly intact but crate cracked.',
      status: DisputeStatus.resolved,
      resolutionNote: 'Farmer offered a Rs. 500 courtesy credit on next purchase. Issue amicably resolved.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  static List<MandiRate> get currentMandiRates => [
    MandiRate(cropName: 'Super Basmati Rice', unit: '40 kg (Maund)', minPrice: 10800, maxPrice: 11500, avgPrice: 11200, trend: 'up'),
    MandiRate(cropName: 'Wheat (Desi Ghandam)', unit: '40 kg (Maund)', minPrice: 4200, maxPrice: 4500, avgPrice: 4350, trend: 'stable'),
    MandiRate(cropName: 'Kinnow Mandarin', unit: '100 pieces (Box)', minPrice: 1800, maxPrice: 2400, avgPrice: 2100, trend: 'up'),
    MandiRate(cropName: 'Farm Tomato', unit: '16 kg (Peti)', minPrice: 1600, maxPrice: 1950, avgPrice: 1800, trend: 'down'),
    MandiRate(cropName: 'Red Potato', unit: '100 kg (Bori)', minPrice: 7200, maxPrice: 8000, avgPrice: 7600, trend: 'stable'),
    MandiRate(cropName: 'Cotton (Phutti)', unit: '40 kg (Maund)', minPrice: 8500, maxPrice: 9400, avgPrice: 9100, trend: 'up'),
  ];

  static List<CropAdvisoryTip> get cropAdvisories => [
    CropAdvisoryTip(
      title: 'Wheat Post-Sowing Irrigation',
      crop: 'Wheat (Ghandam)',
      advisory: 'First irrigation (Kor) is critical 21 days after sowing. Avoid waterlogging during cloudy forecast days.',
      season: 'Rabi Season',
      iconCode: 'water',
    ),
    CropAdvisoryTip(
      title: 'Citrus Fruit Drop Prevention',
      crop: 'Kinnow & Citrus',
      advisory: 'Maintain steady moisture level at root zone. Spray balanced zinc and potassium foliar spray to preserve fruit lustre.',
      season: 'Winter Harvest',
      iconCode: 'sun',
    ),
    CropAdvisoryTip(
      title: 'Vegetable Pest Alert (Aphids)',
      crop: 'Spinach & Tomatoes',
      advisory: 'Check leaf undersides for aphid colonies. Neem oil extract spray (organic) recommended before evening dew.',
      season: 'All Seasons',
      iconCode: 'pest',
    ),
  ];

  static WeatherReport get sampleWeather => WeatherReport(
    city: 'Faisalabad / Sargodha Region',
    temperature: 27.5,
    condition: 'Partly Sunny & Dry',
    humidity: 48,
    windSpeed: 12.0,
    rainChance: 10,
    irrigationWarning: 'Optimal field condition for vegetable picking and wheat weeding today.',
  );
}
