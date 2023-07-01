import 'dart:async';

import 'package:crypto_insight/Model/coinModel.dart';
import 'package:crypto_insight/View/Components/item.dart';
import 'package:crypto_insight/View/Components/item2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    getCoinMarket();
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refreshData() async {
    // Add your data refresh logic here
    // For example, fetch updated data from an API
    await Future.delayed(Duration(seconds: 2));

    const url =
        'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&sparkline=true';

    var response = await http.get(Uri.parse(url), headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
    });

    if (response.statusCode == 200) {
      var x = response.body;
      coinMarketList = coinModelFromJson(x);
      // coinMarketList.sort((a, b) => a.marketCapChangePercentage24H
      //.compareTo(b.marketCapChangePercentage24H));

      int compareByMarketCapChange(CoinModel a, CoinModel b) {
        final aPercentage = a.marketCapChangePercentage24H ?? 0.0;
        final bPercentage = b.marketCapChangePercentage24H ?? 0.0;
        return aPercentage.compareTo(bPercentage);
      }

      setState(() {
        coinMarket = coinMarketList;
        sorted = List.from(coinMarketList);
        sorted!.sort((a, b) {
          final aPercentage = a.marketCapChangePercentage24H ?? 0.0;
          final bPercentage = b.marketCapChangePercentage24H ?? 0.0;
          return aPercentage.compareTo(bPercentage);
        });
      });

      // for (int i = 0; i < sorted!.length; i++) {
      //   print(sorted![i].marketCapChangePercentage24H);
      // }
    } else {
      print(response.statusCode);
    }

    // After refreshing the data, update the UI
    // setState(() {
    //   isRefreshing = true;
    // });
  }

  @override
  Widget build(BuildContext context) {
    double myHeight = MediaQuery.of(context).size.height;
    double myWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView(
          children: [
            Container(
              height: myHeight,
              width: myWidth,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 253, 225, 112),
                    Color(0xffFBC700),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: myHeight * 0.03),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: myWidth * 0.02,
                            vertical: myHeight * 0.005,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            'Main portfolio',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        Text(
                          'Top 10 coins',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          'Experimental',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: myWidth * 0.07),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$ 7,466.20',
                          style: TextStyle(fontSize: 35),
                        ),
                        Container(
                          padding: EdgeInsets.all(myWidth * 0.02),
                          height: myHeight * 0.05,
                          width: myWidth * 0.1,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          child: Image.asset('assets/icons/5.1.png'),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: myWidth * 0.07),
                    child: Row(
                      children: [
                        Text(
                          '+162% all time',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: myHeight * 0.02),
                  Container(
                    height: myHeight * 0.7,
                    width: myWidth,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 5,
                          color: Colors.grey.shade300,
                          spreadRadius: 3,
                          offset: Offset(0, 3),
                        ),
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: myHeight * 0.03),
                        DefaultTabController(
                          length: 2,
                          child: Column(
                            children: [
                              TabBar(
                                labelColor: Colors.black,
                                tabs: [
                                  Tab(
                                    child: Text(
                                      'Top Gainers',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ), // Add this line
                                    ),
                                  ),
                                  Tab(
                                    child: Text(
                                      'Top Losers',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      // Add this line
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                height: myHeight * 0.36,
                                child: isRefreshing
                                    ? Center(
                                        child: CircularProgressIndicator(
                                          color: Color(0xffFBC700),
                                        ),
                                      )
                                    : coinMarket == null || coinMarket!.isEmpty
                                        ? Padding(
                                            padding:
                                                EdgeInsets.all(myHeight * 0.06),
                                            child: Center(
                                              child: Text(
                                                'Attention: This API is free, so you cannot send multiple requests per second. Please wait and try again later.',
                                                style: TextStyle(fontSize: 18),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          )
                                        : TabBarView(
                                            children: [
                                              ListView.builder(
                                                itemCount: sorted!.length < 4
                                                    ? sorted!.length
                                                    : 4,
                                                shrinkWrap: true,
                                                // physics:
                                                //     NeverScrollableScrollPhysics(),
                                                itemBuilder: (context, index) {
                                                  return Item(
                                                    item: sorted![sorted!.length - index - 1],
                                                  );
                                                },
                                              ),
                                              ListView.builder(
                                                itemCount: sorted!.length < 4
                                                    ? sorted!.length
                                                    : 4,
                                                //shrinkWrap: true,
                                                // physics:
                                                //     NeverScrollableScrollPhysics(),
                                                itemBuilder: (context, index) {
                                                  return Item(
                                                    item: sorted![index],
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: myWidth * 0.05),
                          child: Row(
                            children: [
                              Text(
                                'All Coins',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: myHeight * 0.01),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: myWidth * 0.03),
                            child: isRefreshing
                                ? Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xffFBC700),
                                    ),
                                  )
                                : coinMarket == null || coinMarket!.isEmpty
                                    ? Padding(
                                        padding:
                                            EdgeInsets.all(myHeight * 0.06),
                                        child: Center(
                                          child: Text(
                                            'Attention: This API is free, so you cannot send multiple requests per second. Please wait and try again later.',
                                            style: TextStyle(fontSize: 18),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      )
                                    : ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: coinMarket!.length,
                                        itemBuilder: (context, index) {
                                          return Item2(
                                            item: coinMarket![index],
                                          );
                                        },
                                      ),
                          ),
                        ),
                        SizedBox(height: myHeight * 0.01),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isRefreshing = true;

  List? coinMarket = [];
  List? sorted = [];

  var coinMarketList;
  Future<List<CoinModel>?> getCoinMarket() async {
    const url =
        'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&sparkline=true';

    setState(() {
      isRefreshing = true;
    });
    var response = await http.get(Uri.parse(url), headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
    });
    setState(() {
      isRefreshing = false;
    });
    if (response.statusCode == 200) {
      var x = response.body;
      coinMarketList = coinModelFromJson(x);

      int compareByMarketCapChange(CoinModel a, CoinModel b) {
        final aPercentage = a.marketCapChangePercentage24H ?? 0.0;
        final bPercentage = b.marketCapChangePercentage24H ?? 0.0;
        return aPercentage.compareTo(bPercentage);
      }

      setState(() {
        coinMarket = coinMarketList;
        sorted = List.from(coinMarketList);
        sorted!.sort((a, b) {
          final aPercentage = a.marketCapChangePercentage24H ?? 0.0;
          final bPercentage = b.marketCapChangePercentage24H ?? 0.0;
          return aPercentage.compareTo(bPercentage);
        });
      });
    } else {
      print(response.statusCode);
    }
    return null;
  }
}
