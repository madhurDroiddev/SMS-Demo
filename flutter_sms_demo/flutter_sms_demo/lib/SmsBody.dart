import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sms/contact.dart';
import 'package:sms/sms.dart';

class SmsBody extends StatefulWidget {
  @override
  _SmsBodyState createState() => _SmsBodyState();
}

class _SmsBodyState extends State<SmsBody> with AutomaticKeepAliveClientMixin {
  SmsQuery query;
  List<SmsMessage> messages;
  ContactQuery contactQuery;

  Random random = new Random();

  StreamController<List<SmsMessage>> listController =
      StreamController.broadcast();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    listController.close();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    query = new SmsQuery();
    contactQuery = new ContactQuery();
    _getSmsPermission();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return smsBody();
  }

  Future<void> getSms() async {
    messages = await query.querySms();
    listController.sink.add(messages);
    /*setState(() {});*/
  }

  Future<PermissionStatus> _getSmsPermission() async {
    PermissionStatus status = await Permission.sms.status;

    if (!status.isGranted) {
      List<Permission> list = List();

      list.add(Permission.sms);
      list.add(Permission.contacts);

      list.request().then((value) async {
        if (await Permission.sms.isGranted) {
          getSms();
        } else {
          _getSmsPermission();
        }
      });
    } else {
      getSms();
    }
  }

  smsBody() {
    return StreamBuilder<List<SmsMessage>>(
        stream: listController.stream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? Container(
                  child: ListView.separated(
                    itemCount: snapshot.data.length,
                    itemBuilder: (buildContext, position) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color.fromARGB(
                              255,
                              random.nextInt(255),
                              random.nextInt(255),
                              random.nextInt(255)),
                          child: Text(
                              snapshot.data[position].address.substring(0, 2)),
                        ),
                        title: FutureBuilder<Contact>(
                            initialData: Contact("", fullName: ""),
                            future: contactQuery
                                .queryContact(snapshot.data[position].address),
                            builder: (context, _snapshot) {
                              return Text(_snapshot?.data?.fullName != null
                                  ? _snapshot.data.fullName
                                  : snapshot.data[position].address);
                            }),
                        subtitle: Text(
                          snapshot.data[position].body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          style: TextStyle(),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        height: 1,
                        color: Colors.grey,
                      );
                    },
                  ),
                )
              : Center(child: CircularProgressIndicator());
        });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
