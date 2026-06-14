import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/cart_provider.dart';
import '../theme.dart';

class WutheringCheckoutPage extends StatefulWidget {
  final Product? product;
  final int? quantity;
  final double? totalPrice;

  const WutheringCheckoutPage({
    super.key,
    this.product,
    this.quantity,
    this.totalPrice,
  });

  @override
  State<WutheringCheckoutPage> createState() => _WutheringCheckoutPageState();
}

class _WutheringCheckoutPageState extends State<WutheringCheckoutPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _uidController = TextEditingController();
  String? _selectedServer;
  String _selectedPaymentMethod = 'Shell Credit Balance';
  bool _isSubmitting = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<String> _servers = ['SEA', 'Asia', 'Europe', 'America'];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Fetch user profile to get fresh balance
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      auth.fetchProfile();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _uidController.dispose();
    super.dispose();
  }

  bool get _isFiveStar {
    if (widget.product == null) return false;
    final name = widget.product!.name.toLowerCase();
    return name.contains('summit') ||
        name.contains('stringmaster') ||
        name.contains('genesis') ||
        name.contains('astrite');
  }

  Color get _glowColor =>
      _isFiveStar ? AppTheme.primaryColor : AppTheme.accentColor;

  double get _totalPrice => widget.totalPrice ?? (widget.product!.price * widget.quantity!);

  Future<void> _submitPurchase() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Extra validation for Shell Credit Balance
    if (_selectedPaymentMethod == 'Shell Credit Balance' &&
        auth.balance < _totalPrice) {
      _showErrorSnackBar('INSUFFICIENT BALANCE - Please check your funds or choose another payment conduit.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (widget.product != null) {
        // Single Product Purchase Flow
        final txProvider = Provider.of<TransactionProvider>(context, listen: false);
        final res = await txProvider.createTransaction(
          token: auth.token,
          productId: widget.product!.id,
          quantity: widget.quantity!,
          paymentMethod: _selectedPaymentMethod,
          uid: _uidController.text.trim(),
          server: _selectedServer!,
        );

        if (res['success'] == true) {
          if (res['newBalance'] != null) {
            auth.updateBalance(double.parse(res['newBalance'].toString()));
          }
          if (!mounted) return;
          setState(() => _isSubmitting = false);
          _showSuccessDialog(_uidController.text.trim());
        } else {
          if (!mounted) return;
          setState(() => _isSubmitting = false);
          _showErrorSnackBar(res['message'] ?? 'Purchase request failed.');
        }
      } else {
        // Cart Purchase Flow
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        final res = await cartProvider.checkoutCart(
          paymentMethod: _selectedPaymentMethod,
          uid: _uidController.text.trim(),
          server: _selectedServer!,
        );

        if (res['success'] == true) {
          if (res['newBalance'] != null) {
            auth.updateBalance(double.parse(res['newBalance'].toString()));
          }
          if (!mounted) return;
          setState(() => _isSubmitting = false);
          _showSuccessDialog(_uidController.text.trim());
        } else {
          if (!mounted) return;
          setState(() => _isSubmitting = false);
          _showErrorSnackBar(res['message'] ?? 'Cart checkout request failed.');
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showErrorSnackBar('Connection failed: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF2C0F0F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.redAccent, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        content: Text(
          '✗ $message',
          style: const TextStyle(
            color: Colors.redAccent,
            fontFamily: 'monospace',
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(String uid) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.85),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: AlertDialog(
            backgroundColor: AppTheme.darkBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: _glowColor, width: 1.5),
            ),
            title: Row(
              children: [
                Icon(Icons.gpp_good_rounded, color: _glowColor, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'PURCHASE SYNCHRONIZED TO SOL-3',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 1.0,
                      color: _glowColor,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 1.5,
                  color: _glowColor.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'Transaction successfully processed. Resource assets have been synchronized online.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _glowColor.withOpacity(0.06),
                    border: Border.all(color: _glowColor.withOpacity(0.2), width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSuccessSummaryRow('TARGET UID', uid),
                      const SizedBox(height: 6),
                      _buildSuccessSummaryRow('SERVER', _selectedServer!),
                      const SizedBox(height: 6),
                      if (widget.product != null) ...[
                        _buildSuccessSummaryRow('RESOURCE', widget.product!.name),
                        const SizedBox(height: 6),
                        _buildSuccessSummaryRow('QUANTITY', 'x${widget.quantity}'),
                      ] else
                        _buildSuccessSummaryRow('RESOURCES', 'Cart Items'),
                      const SizedBox(height: 6),
                      _buildSuccessSummaryRow('TOTAL COST', 'Rp ${_totalPrice.toStringAsFixed(0)}'),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(); // Dismiss Dialog
                  // Clear search filters or go back to main screen
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: _glowColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'ACKNOWLEDGE',
                    style: TextStyle(
                      color: AppTheme.darkBg,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSuccessSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 10,
            color: Colors.white.withOpacity(0.4),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 10,
            color: _glowColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final hasEnoughBalance =
        _selectedPaymentMethod != 'Shell Credit Balance' ||
            auth.balance >= _totalPrice;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: const Text('SECURE TERMINAL CHECKOUT'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _glowColor.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withOpacity(0.03),
              ),
            ),
          ),

          // Scroll Area Form
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Card
                  _buildOrderSummaryCard(),
                  const SizedBox(height: 24),

                  // UID and Server Block
                  _buildSectionHeader('1. PLAYER IDENTIFICATION'),
                  const SizedBox(height: 12),
                  _buildUIDField(),
                  const SizedBox(height: 14),
                  _buildServerDropdown(),
                  const SizedBox(height: 24),

                  // Payment options
                  _buildSectionHeader('2. PAYMENT CONDUIT'),
                  const SizedBox(height: 12),
                  _buildPaymentMethodSelector(auth),
                  const SizedBox(height: 120), // bottom spacing
                ],
              ),
            ),
          ),

          // Bottom CTA
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomActionBar(hasEnoughBalance),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 12,
          color: _glowColor,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.6),
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummaryCard() {
    final isSingle = widget.product != null;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ORDER SUMMARY',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _glowColor,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _glowColor.withOpacity(0.1),
                      border: Border.all(color: _glowColor.withOpacity(0.3), width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isSingle ? widget.product!.category.toUpperCase() : 'CART CONVENES',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 8,
                        color: _glowColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (isSingle)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _glowColor.withOpacity(0.06),
                        border: Border.all(color: _glowColor.withOpacity(0.2), width: 1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Image.asset(
                        'assets/images/${widget.product!.imageUrl}',
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, st) {
                          return Icon(Icons.inventory_2_outlined, color: _glowColor, size: 20);
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product!.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Unit Price: Rp ${widget.product!.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'x${widget.quantity}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
              else
                Consumer<CartProvider>(
                  builder: (context, cart, _) {
                    return Column(
                      children: cart.items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.name.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'x${item.quantity}',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              const SizedBox(height: 16),
              Container(
                height: 1,
                color: Colors.white.withOpacity(0.08),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ESTIMATED TOTAL',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  Text(
                    'Rp ${_totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontFamily: 'Orbitron',
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUIDField() {
    return TextFormField(
      controller: _uidController,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
      decoration: InputDecoration(
        labelText: 'PLAYER UID',
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.4),
          fontFamily: 'monospace',
          fontSize: 11,
          letterSpacing: 1,
        ),
        hintText: 'Enter 9+ digit UID',
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.25),
          fontFamily: 'monospace',
          fontSize: 11,
        ),
        prefixIcon: Icon(Icons.tag, color: _glowColor, size: 16),
        filled: true,
        fillColor: Colors.white.withOpacity(0.02),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.12), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _glowColor, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        errorStyle: const TextStyle(
          fontFamily: 'monospace',
          color: Colors.redAccent,
          fontSize: 11,
        ),
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return 'Player UID is required';
        }
        if (!RegExp(r'^\d+$').hasMatch(val.trim())) {
          return 'UID must be digits only';
        }
        if (val.trim().length < 9) {
          return 'UID must be at least 9 digits';
        }
        return null;
      },
    );
  }

  Widget _buildServerDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedServer,
      dropdownColor: AppTheme.cardColor,
      style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
      decoration: InputDecoration(
        labelText: 'GAME SERVER',
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.4),
          fontFamily: 'monospace',
          fontSize: 11,
          letterSpacing: 1,
        ),
        prefixIcon: Icon(Icons.public, color: _glowColor, size: 16),
        filled: true,
        fillColor: Colors.white.withOpacity(0.02),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.12), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _glowColor, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        errorStyle: const TextStyle(
          fontFamily: 'monospace',
          color: Colors.redAccent,
          fontSize: 11,
        ),
      ),
      items: _servers.map((server) {
        return DropdownMenuItem<String>(
          value: server,
          child: Text(server),
        );
      }).toList(),
      onChanged: (val) {
        setState(() => _selectedServer = val);
      },
      validator: (val) {
        if (val == null || val.isEmpty) {
          return 'Please select a game server';
        }
        return null;
      },
    );
  }

  Widget _buildPaymentMethodSelector(AuthProvider auth) {
    return Column(
      children: [
        _buildPaymentOptionTile(
          title: 'Shell Credit Balance',
          subtitle: 'Available: Rp ${auth.balance.toStringAsFixed(0)}',
          value: 'Shell Credit Balance',
          icon: Icons.monetization_on_outlined,
          warningWidget: auth.balance < _totalPrice
              ? Padding(
                  padding: const EdgeInsets.only(top: 4, left: 16),
                  child: Row(
                    children: const [
                      Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'INSUFFICIENT BALANCE FOR THIS RESOURCE',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontFamily: 'monospace',
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              : null,
        ),
        const SizedBox(height: 10),
        _buildPaymentOptionTile(
          title: 'Astrite Gate Gateway',
          subtitle: 'Premium convenes portal check',
          value: 'Astrite Gate',
          icon: Icons.vpn_key_outlined,
          warningWidget: null,
        ),
      ],
    );
  }

  Widget _buildPaymentOptionTile({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
    Widget? warningWidget,
  }) {
    final isSelected = _selectedPaymentMethod == value;

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? _glowColor.withOpacity(0.04)
            : Colors.white.withOpacity(0.01),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? _glowColor.withOpacity(0.4)
              : Colors.white.withOpacity(0.06),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RadioListTile<String>(
            value: value,
            groupValue: _selectedPaymentMethod,
            title: Row(
              children: [
                Icon(icon, color: isSelected ? _glowColor : Colors.white.withOpacity(0.4), size: 18),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.4),
                fontFamily: 'monospace',
              ),
            ),
            activeColor: _glowColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedPaymentMethod = val);
              }
            },
          ),
          if (warningWidget != null) ...[
            warningWidget,
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(bool hasEnoughBalance) {
    final isBtnEnabled = hasEnoughBalance && !_isSubmitting;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16,
          ),
          decoration: BoxDecoration(
            color: AppTheme.darkBg.withOpacity(0.85),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.06), width: 1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL PAY',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 9,
                        color: Colors.white.withOpacity(0.35),
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      'Rp ${_totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontFamily: 'Orbitron',
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ScaleTransition(
                scale: _pulseAnimation,
                child: GestureDetector(
                  onTap: isBtnEnabled ? _submitPurchase : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 52,
                    width: 200,
                    decoration: BoxDecoration(
                      gradient: !isBtnEnabled
                          ? null
                          : LinearGradient(
                              colors: widget.product != null && _isFiveStar
                                  ? [AppTheme.primaryColor, const Color(0xFFE8C26E)]
                                  : [AppTheme.accentColor, const Color(0xFF00A89C)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      color: !isBtnEnabled ? AppTheme.borderColor : null,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: !isBtnEnabled
                          ? []
                          : [
                              BoxShadow(
                                color: _glowColor.withOpacity(0.35),
                                blurRadius: 16,
                                spreadRadius: 1,
                              ),
                            ],
                    ),
                    child: Center(
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.darkBg),
                              ),
                            )
                          : Text(
                              !hasEnoughBalance
                                  ? 'LACK OF CREDITS'
                                  : 'CONFIRM PURCHASE',
                              style: const TextStyle(
                                color: AppTheme.darkBg,
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                                letterSpacing: 1.5,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
