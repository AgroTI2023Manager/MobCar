import 'package:flutter/cupertino.dart';

import '../model/address_model.dart';

class AppInfo extends ChangeNotifier
{
  AddressModel? pickUpLocation;
  AddressModel? dropOffLocation;

  void updatePickUpLocation(AddressModel pickUpModel)
  {
    pickUpLocation = pickUpModel;
    notifyListeners();
  }

  void updateDropOffLocation(AddressModel dropoffModel)
  {
    dropOffLocation = dropoffModel;
    notifyListeners();
  }
}