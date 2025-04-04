import 'package:flutter/material.dart';
import 'package:mobcar_drivers/global.dart';
import 'package:mobcar_drivers/model/trip_details.dart';

class NotificationDialog extends StatefulWidget
{
  TripDetails? tripDetailsInfo;

  NotificationDialog({super.key, this.tripDetailsInfo,});

  @override
  State<NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Container(
        margin: const EdgeInsets.all(7),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const SizedBox(height: 29.0,),

            Image.asset(
              "assets/uberexec.png",
              width: 140,
            ),

            const SizedBox(height: 16.0,),

            //title
            const Text(
              "NOVA SOLICITAÇÃO DE VIAGEM",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 20.0,),

            const Divider(
              height: 1,
              color: Colors.black,
              thickness: 1,
            ),

            const SizedBox(height: 10.0,),

            //pick - dropoff
            Padding(
              padding: EdgeInsets.all(17.0),
              child: Column(
                children: [


                  //pickup
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Image.asset(
                        "assets/initial.png",
                        height: 16,
                        width: 16,
                      ),

                      const SizedBox(width: 18,),

                      Expanded(
                        child: Text(
                          widget.tripDetailsInfo!.pickupAddress.toString(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ),

                    ],
                  ),


                  //dropoff
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Image.asset(
                        "assets/final.png",
                        height: 16,
                        width: 16,
                      ),

                      const SizedBox(width: 18,),

                      Expanded(
                        child: Text(
                          widget.tripDetailsInfo!.dropOffAddress.toString(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ),

                    ],
                  ),

                ],
              ),
            ),

            const SizedBox(height: 20,),

            const Divider(
              height: 1,
              color: Colors.black,
              thickness: 1,
            ),

            const SizedBox(height: 8,),

            //decline btn - accept btn
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Expanded(
                    child: ElevatedButton(
                      onPressed: ()
                      {
                        Navigator.pop(context);
                        audioPlayer.stop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      child: const Text(
                        //DECLINE
                        "CANCELAR",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10,),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: ()
                      {
                        Navigator.pop(context);
                        audioPlayer.stop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        "ACEITAR",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),



                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
