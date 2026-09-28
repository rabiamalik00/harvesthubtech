import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app_config/theme.dart';
import '../../core/services/firebase_service.dart';
import '../../core/utils/validators.dart';
import '../../models/support_query_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_toast.dart';
import '../../widgets/pressable_scale.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Profile controllers
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _farmNameCtrl = TextEditingController();
  final _marketCtrl = TextEditingController();
  final _profileFormKey = GlobalKey<FormState>();

  // Password controllers
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _passwordFormKey = GlobalKey<FormState>();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // Profile photo local state – prevents image rebuild blinking
  String? _localPhotoData; // base64 data URL picked this session
  Uint8List? _cachedPhotoBytes; // in-memory bytes for gapless rendering
  bool _photoChanged = false;

  // App Review state
  double _appRating = 5.0;
  final _reviewCtrl = TextEditingController();
  bool _submittingReview = false;
  bool _reviewSubmitted = false;
  String _selectedTag = 'Smooth Experience';

  static const List<String> _feedbackTags = [
    'Smooth Experience',
    'Fair Mandi Rates',
    'Fast Delivery',
    'Fresh Produce',
    'Easy to Use',
    'Great Support',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _populateFields();
  }

  void _populateFields() {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user == null) return;
    _nameCtrl.text = user.name;
    _phoneCtrl.text = user.phone;
    _addressCtrl.text = user.address;
    _farmNameCtrl.text = user.farmName ?? '';
    _marketCtrl.text = user.marketName ?? '';
    final pPhoto = user.profilePhoto;
    if (pPhoto != null && pPhoto.startsWith('data:image')) {
      try {
        final commaIdx = pPhoto.indexOf(',');
        final b64 = commaIdx != -1 ? pPhoto.substring(commaIdx + 1) : pPhoto;
        _cachedPhotoBytes = base64Decode(b64);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _farmNameCtrl.dispose();
    _marketCtrl.dispose();
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    _reviewCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final XFile? file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 80,
      );
      if (file != null && mounted) {
        final bytes = await file.readAsBytes();
        final b64 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        setState(() {
          _cachedPhotoBytes = bytes;
          _localPhotoData = b64;
          _photoChanged = true;
        });
      }
    } catch (_) {}
  }

  void _showPhotoSheet() {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    final hasPhoto = _localPhotoData != null || (user?.profilePhoto ?? '').isNotEmpty;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 18),
              const Text(
                'Update Photo',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 20),
              // Icon-only buttons (no text labels as requested)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _sheetIconButton(
                    icon: Icons.camera_alt_rounded,
                    color: AppColors.primary,
                    tooltip: 'Take Photo',
                    onTap: () {
                      Navigator.pop(context);
                      _pickPhoto(ImageSource.camera);
                    },
                  ),
                  const SizedBox(width: 24),
                  _sheetIconButton(
                    icon: Icons.photo_library_rounded,
                    color: AppColors.accent,
                    tooltip: 'Choose from Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickPhoto(ImageSource.gallery);
                    },
                  ),
                  if (hasPhoto) ...[
                    const SizedBox(width: 24),
                    _sheetIconButton(
                      icon: Icons.delete_outline_rounded,
                      color: AppColors.danger,
                      tooltip: 'Remove Photo',
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _cachedPhotoBytes = null;
                          _localPhotoData = null;
                          _photoChanged = true;
                        });
                      },
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetIconButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Icon(icon, color: color, size: 26),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_profileFormKey.currentState!.validate()) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final isFarmer = auth.currentUser?.isFarmer ?? false;

    final success = await auth.updateProfile(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      farmName: isFarmer ? _farmNameCtrl.text.trim() : null,
      marketName: isFarmer ? _marketCtrl.text.trim() : null,
      profilePhotoData: _photoChanged ? _localPhotoData : null,
    );

    if (!mounted) return;
    if (success) setState(() => _photoChanged = false);
    showHarvestSnackBar(
      context,
      message: success ? 'Profile updated successfully!' : 'Failed to update profile.',
      icon: success ? Icons.check_circle_rounded : Icons.error_outline_rounded,
      backgroundColor: success ? AppColors.success : AppColors.danger,
    );
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;
    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      showHarvestSnackBar(context,
          message: 'New passwords do not match.',
          icon: Icons.error_outline_rounded,
          backgroundColor: AppColors.danger);
      return;
    }
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.changePassword(
        currentPassword: _currentPassCtrl.text, newPassword: _newPassCtrl.text);
    if (!mounted) return;
    if (success) {
      _currentPassCtrl.clear();
      _newPassCtrl.clear();
      _confirmPassCtrl.clear();
      showHarvestSnackBar(context,
          message: 'Password changed successfully!',
          icon: Icons.check_circle_rounded,
          backgroundColor: AppColors.success);
    } else {
      showHarvestSnackBar(context,
          message: auth.errorMessage ?? 'Failed to change password.',
          icon: Icons.error_outline_rounded,
          backgroundColor: AppColors.danger);
    }
  }

  Future<void> _submitAppReview() async {
    final comment = _reviewCtrl.text.trim();
    if (comment.isEmpty) {
      showHarvestSnackBar(context,
          message: 'Please write a brief comment or suggestion.',
          icon: Icons.info_outline_rounded,
          backgroundColor: AppColors.warning);
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;
    if (user == null) return;

    setState(() => _submittingReview = true);

    final fullComment = '[$_selectedTag] $comment';
    final review = CustomerReviewModel(
      id: 'app_rev_${DateTime.now().millisecondsSinceEpoch}',
      customerName: '${user.name} (${user.role})',
      customerEmail: user.email,
      targetFarmerOrMandi: 'HarvestHub App',
      rating: _appRating,
      comment: fullComment,
      createdAt: DateTime.now(),
      verifiedPurchase: true,
    );

    await FirebaseService.saveCustomerReview(review);

    if (!mounted) return;
    setState(() {
      _submittingReview = false;
      _reviewSubmitted = true;
    });

    showHarvestSnackBar(
      context,
      message: 'Thank you for your review! 🌾',
      icon: Icons.star_rounded,
      backgroundColor: AppColors.primary,
    );
  }

  Widget _buildAvatar(UserModel user, Color roleColor) {
    final photoSrc = _localPhotoData ?? (user.profilePhoto?.isNotEmpty == true ? user.profilePhoto : null);
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U';

    return Stack(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: _cachedPhotoBytes != null
                ? Image.memory(
                    _cachedPhotoBytes!,
                    key: const ValueKey('profile_avatar_bytes'),
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                    width: 82,
                    height: 82,
                  )
                : (photoSrc != null && photoSrc.isNotEmpty
                    ? Image.network(
                        photoSrc,
                        key: ValueKey(photoSrc),
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                        width: 82,
                        height: 82,
                        errorBuilder: (_, _, _) => _initials(initial, roleColor),
                      )
                    : _initials(initial, roleColor)),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _showPhotoSheet,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(Icons.camera_alt_rounded, size: 16, color: roleColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _initials(String letter, Color roleColor) => Container(
        color: roleColor.withValues(alpha: 0.15),
        alignment: Alignment.center,
        child: Text(
          letter,
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: roleColor),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isFarmer = user.isFarmer;
    final roleColor = isFarmer ? AppColors.primary : AppColors.accent;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 210,
            backgroundColor: roleColor,
            foregroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isFarmer
                        ? [const Color(0xFF1B4332), AppColors.primary]
                        : [const Color(0xFF9A3412), AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -30,
                      right: -30,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 44, 20, 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildAvatar(user, roleColor),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: -0.3),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user.email,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withValues(alpha: 0.8)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.22),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      user.role,
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(44),
              child: Container(
                color: Colors.black.withValues(alpha: 0.12),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelStyle:
                      const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  tabs: const [
                    Tab(
                        icon: Icon(Icons.person_outline_rounded, size: 16),
                        text: 'Profile'),
                    Tab(
                        icon: Icon(Icons.star_rate_rounded, size: 16),
                        text: 'App Review'),
                    Tab(
                        icon: Icon(Icons.lock_outline_rounded, size: 16),
                        text: 'Security'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildEditProfileTab(auth, isFarmer, roleColor),
            _buildAppReviewTab(auth, isFarmer, roleColor),
            _buildChangePasswordTab(auth, isFarmer, roleColor),
          ],
        ),
      ),
    );
  }

  // ────── TAB 1: EDIT PROFILE ─────────────────────────────────────

  Widget _buildEditProfileTab(AuthProvider auth, bool isFarmer, Color roleColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Form(
            key: _profileFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _card(
                  roleColor: roleColor,
                  child: Column(
                    children: [
                      _field(
                          controller: _nameCtrl,
                          label: 'Full Name',
                          icon: Icons.person_outline_rounded,
                          validator: (v) =>
                              Validators.validateRequired(v, 'Full Name')),
                      const SizedBox(height: 14),
                      _field(
                          controller: _phoneCtrl,
                          label: 'Phone Number',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: Validators.validatePhone),
                      const SizedBox(height: 14),
                      _field(
                          controller: _addressCtrl,
                          label: isFarmer ? 'Farm / Business Address' : 'Delivery Address',
                          icon: Icons.location_on_outlined,
                          validator: (v) =>
                              Validators.validateRequired(v, 'Address')),
                      if (isFarmer) ...[
                        const SizedBox(height: 14),
                        _field(
                            controller: _farmNameCtrl,
                            label: 'Farm / Business Name',
                            icon: Icons.agriculture_rounded,
                            validator: (v) => Validators.validateRequired(
                                v, 'Farm Name')),
                        const SizedBox(height: 14),
                        _field(
                            controller: _marketCtrl,
                            label: 'Mandi / Area Market',
                            icon: Icons.store_rounded),
                      ],
                    ],
                  ),
                ).animate().fadeIn(duration: 280.ms).slideY(begin: 0.04, end: 0),
                const SizedBox(height: 20),
                PressableScale(
                  onPressed: auth.isLoading ? null : _saveProfile,
                  child: _saveButton(auth.isLoading, roleColor,
                      Icons.check_rounded, 'Save Profile Changes'),
                ).animate().fadeIn(duration: 280.ms, delay: 80.ms),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ────── TAB 2: APP REVIEW & FEEDBACK ────────────────────────────

  Widget _buildAppReviewTab(AuthProvider auth, bool isFarmer, Color roleColor) {
    if (_reviewSubmitted) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                'Review Submitted!',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Thank you for helping us make HarvestHub better for Pakistani farmers & buyers! 🌾',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textLight, height: 1.4),
              ),
              const SizedBox(height: 24),
              PressableScale(
                onPressed: () => setState(() {
                  _reviewSubmitted = false;
                  _reviewCtrl.clear();
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: roleColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Submit Another Review',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final ratingLabels = ['Poor', 'Fair', 'Good', 'Very Good', 'Excellent!'];
    final ratingLabel = ratingLabels[(_appRating.round() - 1).clamp(0, 4)];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _card(
                roleColor: roleColor,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: roleColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.rate_review_rounded,
                              color: roleColor, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Rate HarvestHub',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary),
                              ),
                              Text(
                                isFarmer
                                    ? 'Share your experience as a Farmer'
                                    : 'Share your shopping & mandi experience',
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.textLight),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Star rating interactive row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starValue = index + 1.0;
                        final filled = _appRating >= starValue;
                        return GestureDetector(
                          onTap: () => setState(() => _appRating = starValue),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(
                              filled
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 40,
                              color: filled
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFFD1D5DB),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ratingLabel,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFD97706)),
                    ),
                    const SizedBox(height: 20),
                    // Quick topic chips
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('What stood out most?',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _feedbackTags.map((tag) {
                        final isSel = _selectedTag == tag;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedTag = tag),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? roleColor
                                  : roleColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSel
                                    ? roleColor
                                    : roleColor.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight:
                                    isSel ? FontWeight.w800 : FontWeight.w600,
                                color: isSel ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    // Review text field
                    TextFormField(
                      controller: _reviewCtrl,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: isFarmer
                            ? 'Tell us how HarvestHub helped sell your crops...'
                            : 'Tell us how your produce quality & experience was...',
                        hintStyle: const TextStyle(
                            fontSize: 13, color: AppColors.textLight),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(color: AppColors.cardBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              BorderSide(color: roleColor, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 280.ms).slideY(begin: 0.04, end: 0),
              const SizedBox(height: 20),
              PressableScale(
                onPressed: _submittingReview ? null : _submitAppReview,
                child: _saveButton(
                  _submittingReview,
                  roleColor,
                  Icons.send_rounded,
                  'Submit Review',
                ),
              ).animate().fadeIn(duration: 280.ms, delay: 80.ms),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ────── TAB 3: CHANGE PASSWORD ──────────────────────────────────

  Widget _buildChangePasswordTab(
      AuthProvider auth, bool isFarmer, Color roleColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Form(
            key: _passwordFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _card(
                  roleColor: roleColor,
                  child: Column(
                    children: [
                      _passField(
                          _currentPassCtrl,
                          'Current Password',
                          Icons.lock_outline_rounded,
                          _obscureCurrent,
                          () => setState(
                              () => _obscureCurrent = !_obscureCurrent),
                          validator: (v) => Validators.validateRequired(
                              v, 'Current Password')),
                      const SizedBox(height: 14),
                      _passField(
                          _newPassCtrl,
                          'New Password',
                          Icons.lock_open_outlined,
                          _obscureNew,
                          () =>
                              setState(() => _obscureNew = !_obscureNew),
                          validator: Validators.validatePassword),
                      const SizedBox(height: 14),
                      _passField(
                          _confirmPassCtrl,
                          'Confirm New Password',
                          Icons.lock_rounded,
                          _obscureConfirm,
                          () => setState(
                              () => _obscureConfirm = !_obscureConfirm),
                          validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please confirm your new password';
                        }
                        if (v != _newPassCtrl.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      }),
                    ],
                  ),
                ).animate().fadeIn(duration: 280.ms, delay: 100.ms).slideY(begin: 0.04, end: 0),
                const SizedBox(height: 20),
                PressableScale(
                  onPressed: auth.isLoading ? null : _changePassword,
                  child: _saveButton(auth.isLoading, roleColor,
                      Icons.lock_reset_rounded, 'Change Password'),
                ).animate().fadeIn(duration: 280.ms, delay: 160.ms),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ────── HELPER WIDGETS ──────────────────────────────────────────

  Widget _card({required Color roleColor, required Widget child}) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
                color: roleColor.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 3))
          ],
        ),
        child: child,
      );

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
        ),
        validator: validator,
      );

  Widget _passField(TextEditingController ctrl, String label, IconData icon,
          bool obscure, VoidCallback toggle,
          {String? Function(String?)? validator}) =>
      TextFormField(
        controller: ctrl,
        obscureText: obscure,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          suffixIcon: IconButton(
            icon: Icon(
                obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textLight),
            onPressed: toggle,
          ),
        ),
        validator: validator,
      );

  Widget _saveButton(
          bool isLoading, Color color, IconData icon, String label) =>
      Container(
        height: 52,
        decoration: BoxDecoration(
          color: isLoading ? color.withValues(alpha: 0.6) : color,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(label,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ],
              ),
      );
}
