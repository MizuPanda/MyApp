import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';

import '../models/friend.dart';

class PhotoGridProvider extends ChangeNotifier {
  static const pageSize = 10;

  final PagingController<int, String> _pagingController =
      PagingController(firstPageKey: 0);
  final List<String> _photoUrls = [];
  String? _nextPageToken;

  PagingController<int, String> get pagingController => _pagingController;

  String _getDateString(String url) {
    final int firstIndex = url.indexOf('DATE_');
    final int lastIndex = url.lastIndexOf('_out');
    String dateTaken = url.substring(firstIndex + 5, lastIndex);
    //dateTaken = dateTaken.replaceFirst('%', ' ');

    int percentIndex = dateTaken.indexOf('%');
    dateTaken =
        '${dateTaken.substring(0, percentIndex)} ${dateTaken.substring(percentIndex + 3)}';

    percentIndex = dateTaken.indexOf('%');
    dateTaken = dateTaken.substring(0, percentIndex) +
        dateTaken.substring(percentIndex + 3);

    percentIndex = dateTaken.indexOf('%');
    dateTaken = dateTaken.substring(0, percentIndex) +
        dateTaken.substring(percentIndex + 3);

    return dateTaken;
  }

  void init(Friend friend) {
    _pagingController.addPageRequestListener((pageKey) {
      loadPhotos(pageKey, friend);
    });
  }

  void loadPhotos(int pageKey, Friend friend) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('friendships/${friend.friendship.docId()}');
    if (_nextPageToken == null && _photoUrls.isNotEmpty) {
      _pagingController.appendLastPage([]);
      return;
    }
    final pageResult = await ref.list(ListOptions(
        maxResults: pageSize, pageToken: pageKey != 0 ? _nextPageToken : null));

    if (pageResult.items.isEmpty) {
      _pagingController.appendLastPage([]);
      return;
    }

    final urls = await Future.wait(
        pageResult.items.map((ref) => ref.getDownloadURL()).toList());

    _photoUrls.addAll(urls);
    notifyListeners();

    _pagingController.appendPage(urls, pageKey + 1);
    _nextPageToken = pageResult.nextPageToken;
  }

/*
  void loadPhotos(int pageKey, Friend friend) async {
    final ref = FirebaseStorage.instance.ref().child('friendships/${friend.friendship.docId()}');
    final pageResult = await ref.list(
      ListOptions(
        maxResults: pageSize,
        pageToken: pageKey != 0 ? _nextPageToken : null
      )
    );

    final urls = await Future.wait(pageResult.items.map((ref) => ref.getDownloadURL()).toList());

    _photoUrls.addAll(urls);
    notifyListeners();

    _pagingController.appendPage(urls, pageKey + 1);
    _nextPageToken = pageResult.nextPageToken;
  }*/

  void showPhoto(BuildContext context, String url) async {
    String dateString = _getDateString(url);
    DateTime dateTime = DateTime.parse(dateString);
    DateFormat format = DateFormat.yMd();
    dateString = format.format(dateTime);

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(url),
                const SizedBox(height: 10),
                Text('Date taken: $dateString'),
              ],
            ),
          );
        },
      );
    }
  }
}
