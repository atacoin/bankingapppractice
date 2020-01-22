// import 'package:banking_app/bloc/bloc.dart';
// import 'package:banking_app/api/iconHandler.dart';
import 'package:banking_app/api/transactions/models/transaction.dart';
import 'package:banking_app/bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:banking_app/style.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // This is obviously hardcoded, will  need a  bloc
  // The bloc would probably fetch a json from a firebase,
  // and parse it, then yielding it here.
  // bloc name like TransactionsBloc would made sense
  // events would be e.g:  GetTransactions(start period, end period)
  // states would be e.g: TransactionsLoaded, TransactionsNotLoaded etc.

  // final List<Map<String, dynamic>> _transactionsContent = [
  //   {
  //     "Name": "Pastation",
  //     "Price": "\$25.50",
  //     "Date": "15/12/2019",
  //     "Icon": Icons.local_dining
  //   },
  //   {
  //     "Name": "Starbucks",
  //     "Price": "\$12.50",
  //     "Date": "13/12/2019",
  //     "Icon": Icons.local_cafe
  //   },
  //   {
  //     "Name": "Dior",
  //     "Price": "\$2,999.99",
  //     "Date": "14/12/2019",
  //     "Icon": Icons.local_mall
  //   },
  //   {
  //     "Name": "Rome Holiday",
  //     "Price": "\$1200.00",
  //     "Date": "10/05/2019",
  //     "Icon": Icons.local_airport
  //   },
  // ];

  // Why the fuck do i need to declare them here?
  // all the more reason to actually use a bloc
  // Map myDoc = {};
  Map myDoc2 = {};
  // List<BankTransaction> myList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder(
          bloc: BlocProvider.of<AuthenticationBloc>(context),
          builder: (context, state) {
            // IMPORTANT!!! - CHOOSE THE RIGHT WAY TO HANDLE DATA
            // This here is a huge problem here.
            // This is a clusterfuck! A complete clusterfuck
            // Let's look at options for where data is set:
            //
            // OPTION 1: Use a dedicated HomePageDataBloc
            // Yeah this might actually be it, let's try it out
            // Yeah,  I'm more convinced, looks  like I'll need a stream
            // here, so that i can keep updating data etc.
            //
            // OPTION 2: Pass a HomePageData to this page when it's made
            // sounds wrong because the data needs to be able to update
            //
            // Option 3: Bloc Listener
            // Not sure how to implement this...
            FirebaseUser _user;
            if (state is Authenticated) {
              _user = state.user;
              // String _userID = _user.uid;
            }
            return Stack(
              children: <Widget>[
                Container(
                    height: MediaQuery.of(context).size.height * 0.60,
                    child: Column(
                      children: <Widget>[
                        Spacer(
                          flex: 100,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    // "Balance",
                                    "Hi ${(_user?.email ?? "LOADING")}",
                                    // "Hi ${BlocProvider.of<TransactionBloc>(context).state}",
                                    style: AppTextStyle.paragraph,
                                  ),
                                  Text(
                                    "\$50 000.00",
                                    style: AppTextStyle.title,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 30),
                              child: IconButton(
                                onPressed: () {
                                  FirebaseAuth.instance
                                      .signOut()
                                      .then((onValue) {
                                    Navigator.of(context).pushReplacementNamed(
                                        "/LoginSignupPage");
                                  });
                                },
                                icon: Icon(
                                  Icons.account_circle,
                                  size: 35,
                                ),
                              ),
                            )
                          ],
                        ),
                        DefaultTabController(
                          length: 3,
                          child: Column(
                            children: <Widget>[
                              TabBar(
                                indicator: UnderlineTabIndicator(
                                    insets:
                                        EdgeInsets.symmetric(horizontal: 80),
                                    borderSide: BorderSide(
                                      color: AppSwatch.foregroundGreen,
                                      width: 2,
                                    )),
                                labelPadding:
                                    EdgeInsets.symmetric(vertical: 10),
                                tabs: <Widget>[
                                  Text(
                                    "Last Week",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  Text(
                                    "Last Month",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  Text(
                                    "All time",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                              Divider(),
                              Container(
                                // height: 250,
                                height:
                                    MediaQuery.of(context).size.height * 0.35,
                                decoration: BoxDecoration(
                                    color: AppSwatch.backgroundGreen,
                                    borderRadius: BorderRadius.circular(40)),
                                child: TabBarView(
                                  //  These children should be different graphs?
                                  // I'm thinking maybe use a bloc for this...
                                  children: <Widget>[
                                    Center(child: Text("Last Week Chart Here")),
                                    Center(
                                        child: Text("Last Month Chart Here")),
                                    Center(child: Text("All Time Chart Here")),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
                // im guessing the container is here because
                // it's on the top of a stack, interesting.
                // so the bottom sheet is part of a container
                // that fits the screen
                Container(
                  height: MediaQuery.of(context).size.height,
                  child: cardAndTransactionsSheetBuilder(),
                )
              ],
            );
          }),
    );
  }

  // note 2020-01-21: I refactored this, better check if it works
  Widget cardAndTransactionsSheetBuilder() {
    return DraggableScrollableSheet(
      minChildSize: 0.39,
      initialChildSize: 0.39,
      // maxChildSize: 0.82,
      maxChildSize: 0.95,
      builder: (context, controller) => Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(40)),
        child: Stack(
          children: <Widget>[
            ListView(
              // Check if card is overscrolling or not
              // i want to it not overscroll, while the list
              // of transactions do.
              // looks like slivers are the right way to go
              // maybe mess with this?
              // ACTUALLY. maybe it is okay, imagine if the
              // transactions list was rather long, i would
              // want it to overscroll above the card, wouldn't i?
              // ... would i?
              // ok i increased maxChildSize to 0.95
              // makes it a lot more presentable that's for sure
              physics: ClampingScrollPhysics(),
              controller: controller,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Text("Cards",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                Container(
                    child: Center(
                  child: Image.asset('assets/images/Card.png'),
                )),
                // Divider(),
                Padding(
                  padding: const EdgeInsets.only(left: 30, top: 15, bottom: 0),
                  child: Text(
                    "Transactions",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                buildTransactionsContainerWithFirebaseStream(),
                // buildTransactionsContainer(),
              ],
            ),
            Container(
              height: 8,
              margin: EdgeInsets.symmetric(horizontal: 175, vertical: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: AppSwatch.backgroundGreen),
            ),
          ],
        ),
      ),
    );
  }

  // ok this is working! woohoo
  Widget buildTransactionsContainer() {
    return BlocBuilder<TransactionBloc, TransactionState>(
        bloc: BlocProvider.of<TransactionBloc>(context),
        builder: (context, state) {
          List<BankTransaction> myList2;

          if (state is TransactionsLoaded) {
            myList2 = state.transactionList;
          }

          return Container(
            height: 400,
            child: ListView.builder(
              physics: ClampingScrollPhysics(),
              itemCount: (myList2 == null) ? 1 : myList2.length,
              itemBuilder: (context, value) {
                return Container(
                  height: 100,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Card(
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Icon(
                            // ok so it's giving me an error
                            // because i am calling [0] while mylist has nothing
                            // looks like ill need to do some if statement
                            // something like if (mylist .rage = blah blah blah)
                            // or maybe it hsould be higher, at the itemcount thing
                            // and asserting that itemcount can't be 0
                            // myList2[0].icon ?? Icons.error,
                            //  UPDATE: ok i fixed it with the following:
                            (myList2 == null)
                                ? Icons.error
                                : myList2[value].icon,
                            size: 36,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                (myList2 == null)
                                    ? "Loading"
                                    : myList2[value].name,
                                textAlign: TextAlign.center,
                                style: AppTextStyle.paragraph_bold,
                              ),
                              Text(
                                (myList2 == null)
                                    ? "Loading"
                                    : myList2[value]
                                        .date
                                        .toString()
                                        .substring(0, 16),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Text(
                            (myList2 == null)
                                ? "Loading"
                                : ("\$" + myList2[value].price),
                            textAlign: TextAlign.center,
                            style: AppTextStyle.paragraph_bold,
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        });
  }

  Widget buildTransactionsContainerWithFirebaseStream() {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection("users/test/transactions")
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          List<BankTransaction> myList2 = [];

          if (snapshot.data != null) {
            List<BankTransaction> _tempList = [];
            // TODO: Try to change this to snapshot.data.documentchanges
            // the current issue is if i do, for somereason when it
            // rebuilds, it rebuilds with just the new doc, and THEN
            // when i scroll, it updates to the new list
            // im sure there's a way to make it work. try!
            
            snapshot.data.documents.forEach((doc) {
              BankTransaction _transaction =
                  BankTransaction.fromMap(doc.data);
                  _tempList.add(_transaction);
            });
            _tempList.sort((a,b) {return b.date.compareTo(a.date);});
            if (myList2 != _tempList) {
              myList2 = _tempList;
            }
          }

          return Container(
            height: 400,
            child: ListView.builder(
              physics: ClampingScrollPhysics(),
              itemCount: (myList2 == null) ? 1 : myList2.length,
              itemBuilder: (context, value) {
                return Container(
                  height: 100,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Card(
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Icon(
                            (myList2 == null)
                                ? Icons.error
                                : myList2[value].icon,
                            size: 36,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                (myList2 == null)
                                    ? "Loading"
                                    : myList2[value].name,
                                textAlign: TextAlign.center,
                                style: AppTextStyle.paragraph_bold,
                              ),
                              Text(
                                (myList2 == null)
                                    ? "Loading"
                                    : myList2[value]
                                        .date
                                        .toString()
                                        .substring(0, 16),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Text(
                            (myList2 == null)
                                ? "Loading"
                                : ("\$" + myList2[value].price),
                            textAlign: TextAlign.center,
                            style: AppTextStyle.paragraph_bold,
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );

        });
  }
}