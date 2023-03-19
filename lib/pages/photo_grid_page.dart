import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:myapp/providers/photo_grid_provider.dart';

import '../models/friend.dart';

class PhotoGrid extends StatefulWidget {
  final Friend friend;

  const PhotoGrid({super.key, required this.friend});

  @override
  State<PhotoGrid> createState() => _PhotoGridState();
}

class _PhotoGridState extends State<PhotoGrid> {
  final PhotoGridProvider _provider = PhotoGridProvider();
  @override
  void initState() {
    super.initState();
    _provider.init(widget.friend);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('${widget.friend.name} and You'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(children: [
          PagedGridView<int, String>(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            pagingController: _provider.pagingController,
            builderDelegate: PagedChildBuilderDelegate<String>(
              noItemsFoundIndicatorBuilder: (context) {
                return const Center(child: Text('No pictures yet'));
              },
              itemBuilder: (BuildContext context, String url, int index) {
                return GestureDetector(
                  onTap: () => _provider.showPhoto(context, url),
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
          Container(
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                'Your Pictures',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    backgroundColor: Color.fromRGBO(255, 255, 255, 0.50)),
              )),
        ]),
      ),
    );
  }
}
