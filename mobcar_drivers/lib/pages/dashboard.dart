import 'package:flutter/material.dart';
import 'package:mobcar_drivers/pages/earnings_page.dart';
import 'package:mobcar_drivers/pages/home_page.dart';
import 'package:mobcar_drivers/pages/profile_page.dart';
import 'package:mobcar_drivers/pages/trips_page.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin
{
  TabController? controller;
  int indexSelected = 0;

  onBarItemClicked(int i)
  {
    setState(() {
      indexSelected = i;
      controller!.index = indexSelected;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    controller = TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller!.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: controller,
        children: const [
          HomePage(),
          EarningsPage(),
          TripsPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.credit_card),
              label: "Ganhos"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_tree),
              label: "Viagens"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Perfil"
          ),
        ],
        currentIndex: indexSelected,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.blue,
        selectedLabelStyle: const TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        onTap: onBarItemClicked,
      ),
    );

  }
}
