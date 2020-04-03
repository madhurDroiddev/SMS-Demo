import 'dart:async';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactBody extends StatefulWidget {
  @override
  _ContactBodyState createState() => _ContactBodyState();
}

class _ContactBodyState extends State<ContactBody>
    with AutomaticKeepAliveClientMixin {
  StreamController<List<Contact>> listController = StreamController.broadcast();

  Iterable<Contact> contacts;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    listController.close();
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus status = await Permission.contacts.status;

    if (!status.isGranted) {
      Permission.contacts.request().then((value) async {
        if (await Permission.contacts.isGranted) {
          getContact();
        } else {
          _getContactPermission();
        }
      });
    } else {
      getContact();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getContactPermission();
//    getContact();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ContactBody();
  }

  Future<void> getContact() async {
    PermissionStatus status = await Permission.contacts.status;
    contacts = await ContactsService.getContacts(
        withThumbnails: false, photoHighResolution: false);
    listController?.sink?.add(contacts.toList());
  }

  ContactBody() {
    return StreamBuilder<List<Contact>>(
        stream: listController.stream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? Container(
                  child: ListView.separated(
                    itemCount: snapshot.data.length,
                    itemBuilder: (buildContext, position) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          child: Text(
                              snapshot.data[position].displayName != null
                                  ? snapshot.data[position].displayName
                                      .substring(0, 1)
                                  : "#"),
                        ),
                        title: Text(snapshot.data[position].displayName != null
                            ? snapshot.data[position].displayName
                            : ""),
                        subtitle: Text(
                          snapshot.data[position].phones.toList().length > 0
                              ? snapshot.data[position].phones.toList()[0].value
                              : "",
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
