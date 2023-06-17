import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jarvis_0/utils/utils.dart';

const nameS = 'name';
const startDateS = 'startDate';
const endDateS = 'endDate';
const typeS = 'type';
const profitYouS = 'profitYou';
const myFundingS = 'myFunding';
const yourFundingS = 'yourFunding';
const totalProfitS = 'totalProfit';
const betsS = 'bets';
const totalWithdrawS = 'totalWithdraw';
const withdrawsS = 'withdraws';
const totalYouPayedMeS = 'totalYouPayedMe';
const payementsUToMeS = 'payementsUToMe';

Map<String, String> contractTypes = {
  '1': 'Your ID + card, u don\'t use the account, cash out (50) at 200',
  '2': 'Your ID + card, u can use the accout, cash out (50) at 200'
};

// class Bet {
//   DateTime date = DateTime.now();
//   List<int> moneyIn;
//   List<int> moneyOut;
//   double profit = 0;

//   Bet({
//     required this.moneyIn,
//     required this.moneyOut,
//     DateTime? date,
//   }) {
//     this.date = date ?? this.date;
//     for (var money in moneyIn) {
//       profit -= money;
//     }
//     for (var money in moneyOut) {
//       profit += money;
//     }
//   }
// }

class Contract {
  final String name;
  String startDate = formatDate1(DateTime.now());
  String endDate = formatDate1(DateTime.now().add(const Duration(days: 365)));
  String type;
  int profitYou;
  int myFunding;
  int yourFunding;
  // int totalProfit;
  List bets = [];
  // int totalWithdraw;
  List withdraws = [];
  // int totalYouPayedMe;
  List payementsUToMe = [];

  Contract({
    required this.name,
    String? startDate,
    String? endDate,
    this.type = '1',
    this.profitYou = 25,
    this.myFunding = 0,
    this.yourFunding = 50,
    // this.totalProfit = 0,
    List? bets,
    // this.totalWithdraw = 0,
    List? withdraws,
    // this.totalYouPayedMe = 0,
    List? payementsUToMe,
  }) {
    this.startDate = startDate ?? this.startDate;
    this.endDate = endDate ?? this.endDate;
    this.bets = bets ?? this.bets;
    this.withdraws = withdraws ?? this.withdraws;
    this.payementsUToMe = payementsUToMe ?? this.payementsUToMe;
  }

  static Contract fromSnap(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return Contract(
      name: data[nameS],
      startDate: data[startDateS],
      endDate: data[endDateS],
      type: '${data[typeS]}',
      profitYou: data[profitYouS],
      myFunding: data[myFundingS],
      yourFunding: data[yourFundingS],
      bets: data[betsS],
      withdraws: data[withdrawsS],
      payementsUToMe: data[payementsUToMeS],
    );
  }

  Map<String, dynamic> toJson() => {
        nameS: name,
        startDateS: startDate,
        endDateS: endDate,
        typeS: type,
        profitYouS: profitYou,
        myFundingS: myFunding,
        yourFundingS: yourFunding,
        betsS: bets,
        withdrawsS: withdraws,
        payementsUToMeS: payementsUToMe,
      };
}
