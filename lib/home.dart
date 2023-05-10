import 'package:flutter/material.dart';
import 'package:noti/about.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:noti/notification.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'dart:async';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _items = Hive.box('items');
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController dayController = TextEditingController();
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _itemList = [];
  List<Map<String, dynamic>> results = [];
  List<Map<String, dynamic>> filteredList = [];

  DateTime _dateTime = DateTime.now();

  @override
  void initState() {
    getItems();
    results = _itemList;
    filteredList = results;
    startTimer();
    tz.initializeTimeZones();
    super.initState();
  }

  void _showDatePicker(int? key) {
    showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2023),
      lastDate: DateTime(2050),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: 'SELECT DATE',
      cancelText: 'CANCEL',
      confirmText: 'OK',
      errorFormatText: 'Invalid date format',
      errorInvalidText: 'Invalid date',
      fieldLabelText: 'Select a date',
      fieldHintText: 'Month/Date/Year',
    ).then((selectedDate) {
      if (selectedDate == null) {
        return;
      }
      showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dateTime),
      ).then((selectedTime) {
        if (selectedTime == null) {
          return;
        }

        setState(() {
          _dateTime = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        });
      });
    });
  }

  Future<dynamic> getItems() async {
    final data = _items.keys.map((key) {
      final item = _items.get(key);
      return {
        "key": key,
        "Item Name": item['Item Name'],
        "Description": item['Description'],
        "Date": item['Date'],
        "Days": item['Days']
      };
    }).toList();
    setState(() {
      _itemList = data;
    });
  }

  Future<dynamic> storeItem(Map<String, dynamic> newItem) async {
    await _items.add(newItem);
    filteredList = _itemList;
  }

  Future<dynamic> deleteItem({required int key}) async {
    await _items.delete(key);
    getItems();
    filteredList = _itemList;
  }

  Future<dynamic> editItem(
      {required int key, required Map<String, dynamic> updatedItem}) async {
    await _items.put(key, updatedItem);
    filteredList = _itemList;
    getItems();
  }

  void _form(BuildContext context, int? key) async {
    late String addoredit = "Edit Item";
    if (key == null) {
      nameController.text = '';
      descriptionController.text = '';
      dayController.text = '';
      addoredit = "Add Item";
    }
    _dateTime = key == null
        ? DateTime.now().add(Duration(minutes: 1))
        : _itemList.firstWhere((item) => item['key'] == key)['Date'];
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        elevation: 5,
        isScrollControlled: true,
        context: context,
        builder: (_) {
          DateTime date;
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 15,
              left: 15,
              right: 15,
            ),
            decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.transparent,
                    spreadRadius: 4,
                    offset: Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0))),
            child: Form(
              key: _formKey,
              child: ListView(shrinkWrap: true, children: [
                Center(
                  child: Text(
                    addoredit,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                ),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter item name';
                    }
                    return null;
                  },
                  controller: nameController,
                  decoration: const InputDecoration(hintText: 'Item Name'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration:
                      const InputDecoration(hintText: 'Optional description'),
                ),
                TextFormField(
                  validator: (value) {
                    date = _dateTime;
                    if (value == null || value.isEmpty) {
                      return 'Please enter the number';
                    } else if (date
                        .subtract(Duration(days: int.parse(dayController.text)))
                        .isBefore(DateTime.now())) {
                      return 'notification date past, enter a valid number';
                    }
                    return null;
                  },
                  controller: dayController,
                  decoration: const InputDecoration(
                      hintText: '# of days ahead to be notified'),
                ),
                MaterialButton(
                  color: Colors.black38,
                  onPressed: () {
                    _showDatePicker(key);
                  },
                  child: Text(
                    'Select Expiration Date: ${_dateTime.month}/'
                    '${_dateTime.day}/'
                    '${_dateTime.year}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      String name = nameController.text;
                      String description = descriptionController.text;
                      date = _dateTime;
                      int days = dayController.text.isNotEmpty
                          ? int.parse(dayController.text)
                          : 0;

                      if (name.isNotEmpty) {
                        if (key == null) {
                          storeItem({
                            "Item Name": name.toString(),
                            "Description": description.toString(),
                            "Date": date,
                            "Days": days,
                          });

                          Future.delayed(Duration(milliseconds: 500), () {
                            if (days != 0) {
                              NotificationApi.showScheduledNotification(
                                scheduledDate:
                                    date.subtract(Duration(days: days)),
                                title: 'Item: ' +
                                    name.toString() +
                                    '  Expires: ' +
                                    '${date.month}/'
                                        '${date.day}/'
                                        '${date.year}',
                                body: 'Description: ' + description.toString(),
                                id: _itemList.firstWhere((item) =>
                                    item["Item Name"] ==
                                    name.toString())['key'],
                              );
                            }
                            NotificationApi.showScheduledNotification(
                              scheduledDate: date,
                              title: 'Item: ' +
                                  name.toString() +
                                  '  Expired: ' +
                                  '${date.month}/'
                                      '${date.day}/'
                                      '${date.year}',
                              body: 'Description: ' + description.toString(),
                              id: _itemList.firstWhere((item) =>
                                      item["Item Name"] ==
                                      name.toString())['key'] *
                                  10000000,
                            );
                          });
                          nameController.text = '';
                          descriptionController.text = '';
                        } else {
                          NotificationApi.cancelNotification(key);
                          NotificationApi.cancelNotification(key * 10000000);
                          if (days != 0) {
                            NotificationApi.showScheduledNotification(
                              scheduledDate:
                                  date.subtract(Duration(days: days)),
                              title: 'Item: ' +
                                  name.toString() +
                                  '  Expires: ' +
                                  '${date.month}/'
                                      '${date.day}/'
                                      '${date.year}',
                              body: 'Description: ' + description.toString(),
                              id: key,
                            );
                          }
                          NotificationApi.showScheduledNotification(
                            scheduledDate: date,
                            title: 'Item: ' +
                                name.toString() +
                                '  Expired: ' +
                                '${date.month}/'
                                    '${date.day}/'
                                    '${date.year}',
                            body: 'Description: ' + description.toString(),
                            id: key * 10000000,
                          );
                          editItem(key: key, updatedItem: {
                            "Item Name": name.toString(),
                            "Description": description.toString(),
                            "Date": date,
                            "Days": days,
                          });
                        }
                        filteredList = _itemList;
                        getItems();
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: Text(key == null ? "Confirm" : "Update"),
                )
              ]),
            ),
          );
        });
  }

  void startTimer() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  void _runFilter(String enteredKeyword) {
    if (enteredKeyword.isEmpty) {
      results = _itemList;
    } else {
      results = _itemList
          .where((item) => item["Item Name"]
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      filteredList = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white24,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 5,
            ),
            TextField(
              onChanged: (value) => _runFilter(value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Search',
                labelStyle: TextStyle(
                  color: Colors.white,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.white),
                suffixIcon: IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _runFilter('');
                  },
                  icon: Icon(Icons.clear, color: Colors.white),
                ),
              ),
              controller: _searchController,
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        color: Colors.red.withOpacity(0.5),
                        margin: EdgeInsets.only(right: 5),
                      ),
                      Text(
                        'Expired',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        color: Colors.orange.withOpacity(0.5),
                        margin: EdgeInsets.only(right: 5),
                      ),
                      Text(
                        'Expiring soon',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        color: Colors.lightGreen.withOpacity(0.5),
                        margin: EdgeInsets.only(right: 5),
                      ),
                      Text(
                        'Fresh',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Flexible(
              child: Material(
                color: Colors.black12,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final item = filteredList[index];
                    return Container(
                      margin: const EdgeInsets.only(top: 5, left: 5, right: 5),
                      child: ListTile(
                        tileColor: item["Date"]
                                .subtract(Duration(days: item["Days"]))
                                .isAfter(DateTime.now())
                            ? Colors.lightGreen.withOpacity(0.5)
                            : item["Date"]
                                        .subtract(Duration(days: item["Days"]))
                                        .isBefore(DateTime.now()) &&
                                    item["Date"].isAfter(DateTime.now())
                                ? Colors.orange.withOpacity(0.5)
                                : Colors.red.withOpacity(0.5),
                        title: Text(item['Item Name'],
                            style: const TextStyle(color: Colors.white)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['Description'],
                                style: const TextStyle(color: Colors.white)),
                            Text(
                                'Expires: ' +
                                    '${item['Date'].month}/'
                                        '${item['Date'].day}/'
                                        '${item['Date'].year}',
                                style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                nameController.text = item['Item Name'];
                                descriptionController.text =
                                    item['Description'];
                                dayController.text = item['Days'].toString();
                                _form(context, item['key']);
                              },
                              icon: const Icon(Icons.edit, color: Colors.white),
                            ),
                            IconButton(
                              onPressed: () {
                                NotificationApi.cancelNotification(item['key']);
                                NotificationApi.cancelNotification(
                                    item['key'] * 10000000);
                                deleteItem(key: item['key']);
                              },
                              icon:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Center(
            child: Text(
              widget.title,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.hourglass_empty_sharp),
            tooltip: 'About',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                _form(context, null);
              },
              tooltip: 'Add Item',
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
