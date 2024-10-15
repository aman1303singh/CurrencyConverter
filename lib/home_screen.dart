// ignore_for_file: unnecessary_string_interpolations

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String fromCurrency = "USD";
  String toCurrency = "EUR";
  double rate = 0.0;
  double total = 0.0;
  TextEditingController amountController = TextEditingController();
  List<String> currencies = [];

  @override
  void initState() {
    super.initState();
    _getcurrencies();
  }

  Future<void> _getcurrencies() async {
    var response = await http
        .get(Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'));

    var data = json.decode(response.body);
    setState(() {
      currencies = (data['rates'] as Map<String, dynamic>).keys.toList();
      rate = data['rates'][toCurrency];
    });
  }

  Future<void> _getrate() async {
    var response = await http.get(
        Uri.parse('https://api.exchangerate-api.com/v4/latest/$fromCurrency'));

    var data = json.decode(response.body);
    setState(() {
      rate = data['rates'][toCurrency];
    });
  }

  void _swapCurrencies() {
    setState(() {
      String temp = fromCurrency;
      fromCurrency = toCurrency;
      toCurrency = temp;
      _getrate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Currency Converter"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Column(
              children: [
                TextField(
                  cursorColor: Colors.white,
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    labelText: "Amount",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelStyle: const TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.white,
                        )),
                        focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.white,
                        )),
                  ),
                  onChanged: (value) {
                    setState(() {
                      double amount = double.parse(value);
                      total = amount * rate;
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 100,
                        child: DropdownButton<String>(
                          dropdownColor: Colors.black,
                          value: fromCurrency,
                          isExpanded: true,
                          style: const TextStyle(color: Colors.white),
                          items: currencies.map((String value) {
                            return DropdownMenuItem<String>(
                                value: value, child: Text(value));
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              fromCurrency = newValue!;
                              _getrate();
                            });
                          },
                        ),
                      ),
                      IconButton(
                          onPressed: _swapCurrencies,
                          icon: const Icon(
                            Icons.swap_horiz,
                            color: Colors.white,
                          )),
                      SizedBox(
                        width: 100,
                        child: DropdownButton<String>(
                          dropdownColor: Colors.black,
                          value: toCurrency,
                          isExpanded: true,
                          style: const TextStyle(color: Colors.white),
                          items: currencies.map((String value) {
                            return DropdownMenuItem<String>(
                                value: value, child: Text(value));
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              toCurrency = newValue!;
                              _getrate();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  " Rate $rate",
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "${total.toStringAsFixed(3)}",
                  style: const TextStyle(color: Colors.yellowAccent),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
