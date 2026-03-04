import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketify_app/core/common/constants/app_constants.dart';

class ShopProfileScreen extends StatefulWidget {
  const ShopProfileScreen({Key? key}) : super(key: key);

  @override
  State<ShopProfileScreen> createState() => _ShopProfileScreenState();
}

class _ShopProfileScreenState extends State<ShopProfileScreen> {
  int _currentBannerIndex = 0;
  // use network URLs instead of asset paths
  final List<String> bannerImages = [
    'https://payhip.com/cdn-cgi/image/format=auto/https://pe56d.s3.amazonaws.com/o_1ig3agi3r1278190s1ds21tq1vakc.jpg',
    'https://marketplace.canva.com/EAGkJu6RBag/1/0/1600w/canva-pink-and-white-minimalist-e-commerce-presentation-pUrMakjsI6U.jpg',
    'https://marketplace.canva.com/EAGHC5NUD-Q/1/0/1600w/canva-black-and-white-modern-fashion-sale-banner-landscape-n7GVeIDu0Tg.jpg',
  ];

  final List<Map<String, dynamic>> products = [
    {
      'id': 1,
      'name': 'Wireless Headphones',
      'price': '\$89.99',
      'image':
          'https://www.shutterstock.com/image-photo/facial-cosmetic-products-containers-on-600nw-2566963627.jpg',
      'isFavorite': false,
    },
    {
      'id': 2,
      'name': 'Smart Watch',
      'price': '\$199.99',
      'image':
          'https://cdn.shopify.com/s/files/1/2303/2711/files/2_e822dae0-14df-4cb8-b145-ea4dc0966b34.jpg?v=1617059123',
      'isFavorite': false,
    },
    {
      'id': 3,
      'name': 'Phone Case',
      'price': '\$19.99',
      'image':
          'https://www.shutterstock.com/image-photo/facial-cosmetic-products-containers-on-600nw-2566963627.jpg',
      'isFavorite': false,
    },
    {
      'id': 4,
      'name': 'USB-C Cable',
      'price': '\$9.99',
      'image':
          'https://images.rawpixel.com/image_800/cHJpdmF0ZS9sci9pbWFnZXMvd2Vic2l0ZS8yMDIyLTExL3BmLXMxMDgtcG0tNDExMy1tb2NrdXAuanBn.jpg',
      'isFavorite': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Shop Profile',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Enhanced Shop Header Section
            _buildEnhancedShopHeader(),
            const SizedBox(height: 24),

            // Recommendation Banner Section
            _buildBannerSlider(),
            const SizedBox(height: 24),

            // Product Grid Section
            _buildProductGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedShopHeader() {
    return Stack(
      children: [
        // Background Image with Gradient Overlay
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const NetworkImage(
                'https://marketplace.canva.com/EAGvt7arfJE/1/0/1600w/canva-red-yellow-and-blue-modern-fashion-sale-medium-banner-CMxDpY2Tnrc.jpg',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),
        ),

        // Content
        Positioned(
          left: 16,
          right: 16,
          top: 20,
          bottom: 0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left Section - Shop Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Circular Shop Avatar
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        color: Colors.grey[300],
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://instagram.fbkk24-1.fna.fbcdn.net/v/t51.2885-19/135329731_220501839649929_3698531228271091242_n.jpg?efg=eyJ2ZW5jb2RlX3RhZyI6InByb2ZpbGVfcGljLmRqYW5nby45OTguYzIifQ&_nc_ht=instagram.fbkk24-1.fna.fbcdn.net&_nc_cat=109&_nc_oc=Q6cZ2QHfJpYly53EBr-mZb60yXgH-MY458utyaFpXFyf1oNilKrvoeT9X2Ol-Lns-cFuN1mf-RUx3NMQlp2arjOSWCFc&_nc_ohc=fpU6ggNqsaoQ7kNvwFvakXg&_nc_gid=1lKnaqASqAtSTUjKRwil7A&edm=ALGbJPMBAAAA&ccb=7-5&oh=00_AfwCPyNplkH-VEybjn0beOwDVQCZ41oHRhWaBlvHNTqjIg&oe=69AC4FD1&_nc_sid=7d3ac5',
                          ),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Shop Name
                    Text(
                      'TechHub Store',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Rating Row
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '4.8',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 1,
                          height: 16,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '2k Followers',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Right Section - Buttons
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Follow Button
                  SizedBox(
                    width: 110,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 4,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 18),
                          Text(
                            'Follow',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Chat Button
                  SizedBox(
                    width: 105,
                    height: 40,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.7),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.chat, color: Colors.white, size: 18),
                          Text(
                            ' Chat',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBannerSlider() {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemCount: bannerImages.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    color: Colors.grey[300],
                    // load from network
                    child: Image.network(
                      bannerImages[index],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stack) {
                        return const Center(child: Icon(Icons.broken_image));
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // Page Indicator Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            bannerImages.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentBannerIndex == index ? 12 : 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentBannerIndex == index
                    ? Colors.black54
                    : Colors.grey[300],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Featured Products',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return _buildProductCard(index);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProductCard(int index) {
    final product = products[index];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                color: Colors.grey[300],
                image: DecorationImage(
                  image: NetworkImage(product['image']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Product Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['price'],
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppConstants.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product['name'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
