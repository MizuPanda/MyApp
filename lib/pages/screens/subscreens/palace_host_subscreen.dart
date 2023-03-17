import 'package:flutter/material.dart';
import 'package:myapp/pages/screens/dual_linking_screen.dart';
import 'package:myapp/providers/dual_provider.dart';
import 'package:myapp/widgets/progress_indicator.dart';


class PalaceHostSubScreen extends StatefulWidget {
  final Function back;
  const PalaceHostSubScreen({Key? key, required this.back}) : super(key: key);

  @override
  State<PalaceHostSubScreen> createState() => _PalaceHostSubScreenState();
}

class _PalaceHostSubScreenState extends State<PalaceHostSubScreen> {
  final DualProvider _provider = DualProvider();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DualProvider.getPalaceName(),
        builder: (BuildContext context, AsyncSnapshot<String> palaceNameData) {
          if(palaceNameData.hasData) {
            if(palaceNameData.data!.isEmpty) { //THE USER DOESN'T HAVE A PALACE YET
              return Center(
                child: SizedBox(
                  width: double.maxFinite,
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Text('You need to unlock a Palace first.', style: TextStyle(color: Colors.black,fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                          SizedBox(height: 8,),
                          Text('Palace unlockable at power 12', style: TextStyle(color: Colors.grey,fontSize: 17, fontWeight: FontWeight.bold),)
                        ],
                    ),
                      ),
                      Align(alignment: Alignment.topLeft, child: BackArrow(back: widget.back,),),
                    ]
                  ),
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
                        Align(alignment: Alignment.topLeft, child: BackArrow(back: widget.back,)),
                        Text(palaceNameData.requireData, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                      ],
                    ),
                    Expanded(
                        child:
                        ListView.builder(
                          itemCount: _provider.length(),
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: CircleAvatar(
                                  backgroundImage:
                               _provider.avatar(index)),
                              title: Text(_provider.name(index)),
                              subtitle: Text(_provider.username(index)),
                              trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.delete_rounded, color: Colors.red,),),
                            );
                          },
                        )
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton( //DISABLE THE BUTTON UNTIL LENGTH >= 2
                        onPressed: () {}, //DO THE LINKING HERE
                        child: const Text('Continue'),
                      ),
                    )
                  ],
                ),
              ); //Main Code
            }
          } else {
            return const Center(child: MyCircularProgress());
          }
        }
    );
  }
}
