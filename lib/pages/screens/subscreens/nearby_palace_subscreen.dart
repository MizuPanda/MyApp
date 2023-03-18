import 'package:flutter/material.dart';

import '../../../providers/dual_provider.dart';
import '../dual_linking_screen.dart';

class NearbyPalaceSubScreen extends StatefulWidget {
  final Function back;
  const NearbyPalaceSubScreen({Key? key, required this.back}) : super(key: key);

  @override
  State<NearbyPalaceSubScreen> createState() => _NearbyPalaceSubScreenState();
}

class _NearbyPalaceSubScreenState extends State<NearbyPalaceSubScreen> {
  final DualProvider _provider = DualProvider();

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      if (_provider.getConnectedUsers() == null) {
        return SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Align(
                      alignment: Alignment.topLeft,
                      child: BackArrow(
                        back: widget.back,
                      )),
                  const Text(
                    'Nearby Palaces',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Expanded(
                  child: ListView.builder(
                itemCount: _provider.length(),
                itemBuilder: (context, index) {
                  return ListTile(
                    isThreeLine: true,
                    leading:
                        CircleAvatar(backgroundImage: _provider.avatar(index)),
                    title: Text(
                      _provider.palace(index),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _provider.name(index),
                          maxLines: 1,
                        ),
                        Text(
                          _provider.username(index),
                          maxLines: 1,
                        ),
                      ],
                    ),
                    trailing: Text(_provider.power(index)),
                    onTap: () async {
                      await _provider.onTap(index, context);
                    },
                  );
                },
              )),
            ],
          ),
        );
      } else {
        return SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Align(
                      alignment: Alignment.topLeft,
                      child: BackArrow(
                        back: widget.back,
                      )),
                  Text(
                    _provider.hostPalace(),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Expanded(
                  child: ListView.builder(
                itemCount: _provider.hostLength(),
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                        backgroundImage: _provider.hostAvatar(index)),
                    title: Text(_provider.hostName(index)),
                    subtitle: Text(_provider.hostUsername(index)),
                  );
                },
              )),
            ],
          ),
        ); //Main Code
      }
    }); //M
  }
}
