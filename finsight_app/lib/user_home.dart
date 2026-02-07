import 'package:finsight_app/requestexpert.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ChatPage.dart';
import 'ComplaintPage.dart';
import 'PortfolioPage.dart';
import 'TipsPage.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  int _selectedIndex = 0;
  String _username = "User";

  // FINSIGHT Colors
  final Color _primaryColor = const Color(0xFFEB1616);
  final Color _secondaryColor = const Color(0xFF191C24);
  final Color _darkColor = const Color(0xFF000000);
  final Color _lightColor = const Color(0xFF6C7293);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    setState(() {
      _username = sh.getString('username') ?? "User";
    });
  }

  // Navigation functions
  void _viewPortfolio() {
    print("Navigate to Portfolio");
    Navigator.push(context, MaterialPageRoute(builder: (context) => PortfolioPage()));
  }

  void _viewTips() {
    print("Navigate to Tips");
    Navigator.push(context, MaterialPageRoute(builder: (context) => TipsPage()));
  }

  void _fileComplaint() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ComplaintPage()));
    print("Navigate to Complaint");
  }

  void _chatWithExpert() {
    print("Navigate to Chat");
    Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage()));
  }

  void _requestExpert() {
    print("Navigate to Request Expert");
    Navigator.push(context, MaterialPageRoute(builder: (context) => RequestExpertPage()));
  }

  void _logout() {
    print("Logout");
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _secondaryColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _lightColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: _lightColor,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _secondaryColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _lightColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: _primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: _lightColor),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkColor,
      appBar: AppBar(
        backgroundColor: _secondaryColor,
        elevation: 0,
        title: const Text(
          'FINSIGHT',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              print("Notifications");
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: _secondaryColor,
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: _darkColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _primaryColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(Icons.person, color: Colors.white, size: 30),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Investor Account',
                      style: TextStyle(
                        color: _lightColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.dashboard, color: _lightColor),
                title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
                selected: _selectedIndex == 0,
                onTap: () {
                  setState(() => _selectedIndex = 0);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.account_balance_wallet, color: _lightColor),
                title: const Text('Portfolio', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _viewPortfolio();
                },
              ),
              ListTile(
                leading: Icon(Icons.tips_and_updates, color: _lightColor),
                title: const Text('Investment Tips', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _viewTips();
                },
              ),
              ListTile(
                leading: Icon(Icons.chat_bubble_outline, color: _lightColor),
                title: const Text('Chat with Expert', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _chatWithExpert();
                },
              ),
              ListTile(
                leading: Icon(Icons.contact_support, color: _lightColor),
                title: const Text('Request Expert', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _requestExpert();
                },
              ),
              ListTile(
                leading: Icon(Icons.report_problem, color: _lightColor),
                title: const Text('File Complaint', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _fileComplaint();
                },
              ),
              const Divider(color: Color(0xFF6C7293)),
              ListTile(
                leading: Icon(Icons.logout, color: _primaryColor),
                title: Text('Logout', style: TextStyle(color: _primaryColor)),
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 400;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Welcome Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_primaryColor.withOpacity(0.1), _primaryColor.withOpacity(0.05)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: TextStyle(
                                  color: _lightColor,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _username,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 20 : 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Track your investments and get expert insights',
                                style: TextStyle(
                                  color: _lightColor,
                                  fontSize: isSmallScreen ? 12 : 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _primaryColor,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: const Icon(Icons.trending_up, color: Colors.white, size: 24),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Quick Stats
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _secondaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Portfolio',
                                style: TextStyle(
                                  color: _lightColor,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '₹1,25,000',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.arrow_upward, color: Colors.green, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '+12.5%',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _secondaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Active Investments',
                                style: TextStyle(
                                  color: _lightColor,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '8',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.trending_up, color: Colors.green, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'This month',
                                    style: TextStyle(
                                      color: _lightColor,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Dashboard Grid
                  const Text(
                    'Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildDashboardCard(
                        icon: Icons.account_balance_wallet,
                        title: 'Portfolio',
                        subtitle: 'View your investments',
                        color: Colors.blue,
                        onTap: _viewPortfolio,
                      ),
                      _buildDashboardCard(
                        icon: Icons.tips_and_updates,
                        title: 'Investment Tips',
                        subtitle: 'Daily recommendations',
                        color: Colors.orange,
                        onTap: _viewTips,
                      ),
                      _buildDashboardCard(
                        icon: Icons.contact_support,
                        title: 'Request Expert',
                        subtitle: 'Get personal guidance',
                        color: Colors.teal,
                        onTap: _requestExpert,
                      ),
                      _buildDashboardCard(
                        icon: Icons.chat_bubble_outline,
                        title: 'Chat Expert',
                        subtitle: 'Instant messaging',
                        color: Colors.pink,
                        onTap: _chatWithExpert,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Quick Actions
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Column(
                    children: [
                      _buildQuickActionButton(
                        icon: Icons.contact_support,
                        label: 'Request Expert Assistance',
                        onTap: _requestExpert,
                      ),
                      const SizedBox(height: 10),
                      _buildQuickActionButton(
                        icon: Icons.chat_bubble_outline,
                        label: 'Chat with Expert',
                        onTap: _chatWithExpert,
                      ),
                      const SizedBox(height: 10),
                      _buildQuickActionButton(
                        icon: Icons.report_problem,
                        label: 'File Complaint',
                        onTap: _fileComplaint,
                      ),
                      const SizedBox(height: 10),
                      _buildQuickActionButton(
                        icon: Icons.tips_and_updates,
                        label: 'View Investment Tips',
                        onTap: _viewTips,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Expert Request Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _secondaryColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _primaryColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.contact_support, color: _primaryColor, size: 24),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Need Expert Guidance?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Connect with financial experts for personalized investment advice and portfolio management.',
                          style: TextStyle(
                            color: Color(0xFF6C7293),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _requestExpert,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.send, size: 18),
                            label: const Text(
                              'REQUEST EXPERT NOW',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Recent Activity
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _secondaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recent Activity',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildActivityItem(
                          icon: Icons.tips_and_updates,
                          title: 'New Investment Tip',
                          subtitle: 'Expert recommendation received',
                          time: '2 hours ago',
                          color: Colors.green,
                        ),
                        _buildActivityItem(
                          icon: Icons.account_balance_wallet,
                          title: 'Portfolio Update',
                          subtitle: 'Investment value increased',
                          time: '1 day ago',
                          color: Colors.blue,
                        ),
                        _buildActivityItem(
                          icon: Icons.chat_bubble_outline,
                          title: 'Expert Chat',
                          subtitle: 'Message from your assigned expert',
                          time: '3 days ago',
                          color: Colors.teal,
                        ),
                        _buildActivityItem(
                          icon: Icons.contact_support,
                          title: 'Expert Requested',
                          subtitle: 'Financial Planning - Pending',
                          time: '5 days ago',
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _requestExpert,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: _secondaryColor,
        selectedItemColor: _primaryColor,
        unselectedItemColor: _lightColor,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          // Handle bottom nav actions
          switch (index) {
            case 0:
            // Already on home
              break;
            case 1:
              _viewPortfolio();
              break;
            case 2:
              _chatWithExpert();
              break;
            case 3:
              _requestExpert();
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Portfolio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_support),
            label: 'Request',
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: _lightColor,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: _lightColor,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}