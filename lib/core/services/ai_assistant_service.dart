// ignore_for_file: prefer_single_quotes
/// HarvestHub AI Farm Products Assistant Service
/// Comprehensive agricultural knowledge base covering crop health, seasonal cycles,
/// mandi market dynamics, balanced fertilisation, post-harvest storage, and platform operations.
/// Designed as an offline-capable, deterministic expert advisor system.
library;

class AiChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  AiChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class AiAssistantService {
  // ---------------------------------------------------------------------------
  // Primary Knowledge Base — keyword → expert response (100% Professional English)
  // ---------------------------------------------------------------------------
  static const Map<String, String> _knowledgeBase = {
    // ── Vitamin & Nutrition ──────────────────────────────────────────────────
    'vitamin c':
        '🍊 Top Vitamin C produce: Citrus (Kinnow, Oranges), Guava, Strawberries, and Lemons. A single fresh guava supplies over 200% of your daily recommended Vitamin C value!',
    'vitamin a':
        '🥕 For Vitamin A and beta-carotene: Fresh carrots, ripe mangoes, spinach, turnips, and sweet potatoes are optimal choices to support immune health and optimal vision.',
    'iron':
        '🥬 Key iron-rich crops: Farm spinach, lentils, chickpeas, kidney beans, and dates. Pair iron-dense greens with vitamin C (such as a squeeze of lemon) to multiply bio-absorption.',
    'protein':
        '🫘 High plant-based protein sources: Black gram (Mash), red lentils (Masoor), chickpeas, and soybeans. One cup of cooked lentils delivers approximately 18g of clean dietary protein.',
    'calcium':
        '🥛 Calcium-rich selections: Pure whole buffalo milk, yogurt, paneer, sesame seeds, and dark leafy greens. Essential for bone density and muscular recovery.',

    // ── Seasonal Crop Cycles ─────────────────────────────────────────────────
    'season':
        '📅 Agricultural Seasons Overview:\n• Rabi (Winter cycle — Oct to Mar): Wheat, mustard, chickpeas, barley, potatoes.\n• Kharif (Summer cycle — Apr to Sep): Rice, maize, cotton, tomatoes, peas, watermelon.',
    'rabi':
        '❄️ Rabi Crops (October to March): Wheat, barley, mustard, chickpeas, potatoes, carrots, and turnips. These crops thrive in cool winter temperatures with controlled irrigation.',
    'kharif':
        '☀️ Kharif Crops (April to September): Basmati rice, maize, okra, tomatoes, peas, and melons. These summer crops require warm sunshine and adequate seasonal rainfall.',
    'winter vegetable':
        '🥦 Winter Vegetables: Carrots, turnips, fenugreek (methi), spinach, cauliflower, peas, potatoes, radishes, and cabbage. Available freshly harvested from November through February.',
    'summer vegetable':
        '🌽 Summer Vegetables: Vine-ripened tomatoes, cucumbers, ridge gourd (torai), okra (bhindi), bitter gourd (karela), and eggplants. Freshly stocked between April and September.',

    // ── Crop Disease & Pathology Management ──────────────────────────────────
    'wheat rust':
        '🌾 Wheat Stripe / Yellow Rust: Causes orange-yellow pustules on leaf blades. Remediation: Apply Propiconazole 25% EC at 1 ml per liter of water upon first symptom detection. Repeat after 21 days if humid conditions persist.',
    'tomato blight':
        '🍅 Tomato Blight (Early / Late): Characterised by dark concentric lesions on leaves and fruit decay. Remediation: Spray Mancozeb (2g/L) or Copper Oxychloride. Water at soil level during mornings and avoid overhead watering.',
    'tomato leaf curl':
        '🍅 Tomato Leaf Curl Virus (TLCV): Leaves curl upwards and exhibit stunted growth. Transmitted by whiteflies. Remediation: Apply Imidacloprid (0.5 ml/L), deploy yellow sticky traps, and remove severely infested host plants.',
    'powdery mildew':
        '🌿 Powdery Mildew: White fungal powder across upper leaf surfaces. Remediation: Spray micronized wettable sulfur (2g/L) or potassium bicarbonate solution. Ensure adequate spacing between crop beds to promote air circulation.',
    'aphid':
        '🐛 Aphids & Sucking Pests: Small green or black insects that deplete plant sap and secrete honeydew. Remediation: Apply cold-pressed neem oil solution (5 ml/L with mild surfactant) or Imidacloprid. Natural predators like ladybirds help control populations.',
    'fusarium':
        '🌿 Fusarium Wilt: Progressive vascular wilting and root vascular browning. Remediation: Treat nursery seeds with Trichoderma viride bio-fungicide, implement 3-year crop rotation, and amend soil with well-aged organic compost.',

    // ── Fertilizers & Soil Health ────────────────────────────────────────────
    'urea':
        '⚗️ Urea (46% Nitrogen): Stimulates vegetative shoot and foliage development. Standard dosage: 1 bag per acre (50kg) applied in split applications 2-3 weeks post-germination. Avoid over-application to prevent leaf scorch.',
    'dap':
        '⚗️ DAP (Di-Ammonium Phosphate — 18% N, 46% P): Critical for robust root establishment and early blossom set. Standard dosage: 1 bag per acre at soil preparation / sowing. Apply separately from urea for balanced uptake.',
    'potassium':
        '⚗️ Potash (SOP / MOP): Enhances fruit sizing, starch accumulation, and natural disease resistance. Dosage: 25kg per acre applied 3 weeks prior to flowering. Especially advantageous for potatoes, citrus, and carrots.',
    'fertilizer':
        '🌱 Balanced NPK Guidelines: Nitrogen (N) for vegetative foliage, Phosphorus (P) for root systems, and Potassium (K) for fruit sizing and stress resilience. Maintain balanced soil testing for optimum yields.',
    'compost':
        '♻️ Organic Compost & Humus: Enhances soil microbiological activity and water retention capacity. Apply well-decomposed farmyard manure at 1-2 tons per acre before bed preparation.',
    'organic':
        '🌱 HarvestHub Certified Organic Produce: Cultivated without synthetic insecticides or chemical boosters. Verified growers utilize biological pest control and certified compost. Check the "Organic" badge on product cards.',

    // ── Storage & Post-Harvest Preservation ──────────────────────────────────
    'storage':
        '🧺 Post-Harvest Storage Guide:\n• Potatoes & Onions: Store in well-ventilated, dark, cool areas (avoid refrigeration).\n• Leafy Greens: Wrap in moist breathable towels and refrigerate at 4°C.\n• Tomatoes: Store stem-up at room temperature away from direct sunlight.',
    'tomato':
        '🍅 Storage Tip: Never refrigerate fresh tomatoes! Cold temperatures below 10°C break down volatile flavor aromatics. Store at room temperature away from sunlight to preserve sweetness.',
    'potato':
        '🥔 Potato Storage: Keep in cool, dark, dry storage. Prolonged light exposure promotes solanine buildup (green discoloration). Never store adjacent to onions as moisture off-gassing causes premature sprouting.',
    'onion':
        '🧅 Onion Storage: Store in open mesh crates or hanging nets with continuous airflow. Keep away from humid enclosures to avoid fungal rot.',

    // ── Mandi Market Logistics & Bidding ─────────────────────────────────────
    'mandi':
        '🏪 Mandi Ecosystem: Connects local certified regional hubs—Faisalabad Model Mandi, Lahore Agriculture Bazaar, Multan Mandi—allowing farmers to supply directly without intermediary price deductions.',
    'price':
        '💰 Transparent Pricing: On HarvestHub, each grower sets their farm-gate pricing directly. Track prevailing market benchmarks via the "Crop Advisory" console. For bulk consignments, utilize the live bidding feature.',
    'pickup':
        '⏰ Convenient Mandi Pickup Windows:\n• Morning Slot: 08:00 AM – 10:00 AM\n• Midday Slot: 10:00 AM – 12:00 PM\n• Afternoon Slot: 02:00 PM – 04:00 PM\n• Evening Slot: 04:00 PM – 06:00 PM\nSelect your preferred collection time during checkout.',
    'bargain':
        '🤝 Live Price Negotiation: Tap "Bargain Price" on any product page for bulk consignments. Submit your counter-offer directly to the grower for mutual agreement before checkout.',

    // ── Platform Navigation & Support ────────────────────────────────────────
    'market':
        '🌾 HarvestHub connects you with verified farming hubs across Faisalabad, Lahore, Multan, and Rawalpindi. Use the "Verified Local Farms" tab to discover adjacent centers.',
    'farmer':
        '👨‍🌾 Follow your favourite growers! Receive automated notifications whenever their farms restock fresh seasonal produce. Tap "Follow Farmer" on their profile.',
    'order':
        '📦 Order Lifecycle: Pending → Confirmed → Ready for Pickup → Completed. Download your digital invoice from Order History or initiate an inquiry if assistance is required.',
    'wishlist':
        '❤️ Save products to your Wishlist by tapping the heart icon on any card. Review your curated items anytime under the Wishlist tab.',
    'cart':
        '🛒 Add produce to your Cart, tailor purchase quantities, and confirm multi-farmer collections in a single unified checkout checkout flow.',

    // ── Crops & Culinary Notes ───────────────────────────────────────────────
    'salad':
        '🥗 Nutritious Farm Salad: Combine crisp lettuce, cherry tomatoes, diced cucumbers, and bell peppers. Dress with cold-pressed olive oil, fresh lemon juice, and a pinch of rock salt.',
    'spinach':
        '🥬 Fresh Farm Spinach: Packed with dietary iron, calcium, and vitamins A & K. Cook gently or blend into morning smoothies. HarvestHub features certified pesticide-free greens.',
    'garlic':
        '🧄 Fresh Garlic: Rich in allicin compounds that support cardiovascular health and blood pressure balance. Fresh local cloves available across all active mandis.',
    'ginger':
        '🫚 Organic Ginger: Renowned for natural digestive benefits and anti-inflammatory properties. Ideal for herbal infusions and culinary recipes.',

    // ── Sowing / Agronomic Calendars ─────────────────────────────────────────
    'sowing':
        '📆 Sowing Calendar Reference:\n• Oct–Nov: Winter wheat, mustard, chickpeas\n• Feb–Mar: Spring tomatoes, bell peppers, eggplant nursery\n• Apr–May: Basmati rice nursery, summer okra\n• Jun–Jul: Kharif maize and melons\n• Aug–Sep: Onion seedling nursery',
    'wheat':
        '🌾 Agronomic Wheat Guide:\n• Recommended cultivars: Sehar, Faisalabad Certified\n• Sowing window: November 1st – November 30th\n• Seed rate: 50 kg per acre\n• Irrigation checkpoints: Crown root initiation, tillering, flowering, and grain filling.',

    // ── Weather & Protective Advisory ────────────────────────────────────────
    'rain':
        '🌧️ Rain Preparation: Halt fungicide and herbicide applications prior to rainfall. Ensure drainage channels are clear around crop beds to prevent root waterlogging.',
    'heat':
        '🌡️ Heat Wave Management: Irrigate early between 06:00 AM and 08:00 AM. Apply organic straw mulching to conserve root zone moisture and deploy shading cloth over vulnerable nurseries.',
    'frost':
        '❄️ Frost Protection: Apply light evening irrigation to maintain soil heat capacitance. Erect protective polythene cloches over seedlings and ensure balanced potassium fertilization.',
  };

  // ---------------------------------------------------------------------------
  // Context-aware Fallback Logic in 100% Professional English
  // ---------------------------------------------------------------------------
  static String getResponse(String userQuery) {
    final q = userQuery.toLowerCase().trim();

    // 1 — Keyword match
    for (final entry in _knowledgeBase.entries) {
      if (q.contains(entry.key)) {
        return entry.value;
      }
    }

    // 2 — Category fallbacks
    if (q.contains('fruit')) {
      return '🍎 Fresh seasonal fruits on HarvestHub: Mangoes, Kinnow oranges, strawberries, bananas, guavas, and melons. Filter by "Fruits" on the browse screen to see live availability.';
    }
    if (q.contains('vegetable') || q.contains('veg')) {
      return '🌽 Fresh vegetables harvested daily: Vine-ripe tomatoes, potatoes, onions, spinach, carrots, and okra. Use location filters to source from the nearest local farm.';
    }
    if (q.contains('farmer') || q.contains('grower')) {
      return '👨‍🌾 HarvestHub enables direct-from-grower sourcing with no middleman markup. Follow verified farms to receive automated restock notifications.';
    }
    if (q.contains('disease') || q.contains('pest') || q.contains('infection')) {
      return '🔬 Crop Diagnostics: Inquire about specific crop issues (e.g., Rust, Blight, Aphids, Wilt) for detailed dosage, cultural practices, and biological remedies.';
    }
    if (q.contains('help') || q.contains('how')) {
      return '🤖 I am Dr. Imran Siddiqui, HarvestHub Lead Agricultural Advisor. You can ask me about:\n• 🌾 Crop health, diseases & bio-remedies\n• ⚗️ Fertilizer ratios (Urea, DAP, Potash)\n• 📅 Sowing calendars & harvest windows\n• 🥗 Produce nutrition & post-harvest storage\n• 💰 Mandi market prices & bidding guidance\n• 📦 Order tracking and pickup logistics';
    }
    if (q.contains('price') || q.contains('rate')) {
      return '💰 Live mandi benchmarks are published in the Crop Advisory console. Farm product prices are set directly by individual growers with zero commission overhead.';
    }
    if (q.contains('hello') || q.contains('hi') || q.contains('salam')) {
      return '🌿 Greetings! I am Dr. Imran Siddiqui, your HarvestHub Agricultural Advisor. How can I assist you with crop management, farm produce, or platform operations today?';
    }
    if (q.contains('thank') || q.contains('thanks')) {
      return '🌾 You are very welcome! Best wishes for a bountiful harvest. Feel free to reach out anytime for agricultural guidance or assistance! 🤝';
    }

    // 3 — Default fallback
    return '🤖 Dr. Imran Siddiqui at your service! Feel free to ask about any agronomic or marketplace subject:\n\n🌾 Wheat Rust • 🍅 Tomato Blight • ⚗️ Urea & DAP Rates\n🥗 Nutritional Values • 📦 Order Pickup • 💰 Mandi Pricing\n\nTap any suggested topic above or type your question below.';
  }
}
