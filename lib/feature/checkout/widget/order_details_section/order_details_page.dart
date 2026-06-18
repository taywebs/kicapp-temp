import 'package:demandium/feature/checkout/widget/choose_booking_type_widget.dart';
import 'package:demandium/feature/checkout/widget/order_details_section/create_account_widget.dart';
import 'package:demandium/feature/checkout/widget/order_details_section/repeat_booking_schedule_widget.dart';
import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({super.key}) ;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocationController>(builder: (locationController){
      return GetBuilder<CartController>(builder: (cartController){

        bool isLoggedIn  = Get.find<AuthController>().isLoggedIn();
        bool createGuestAccount = Get.find<SplashController>().configModel.content?.createGuestUserAccount == 1;
        ConfigModel configModel = Get.find<SplashController>().configModel;
        AddressModel? addressModel = CheckoutHelper.selectedAddressModel(selectedAddress: locationController.selectedAddress, pickedAddress: locationController.getUserAddress());
        bool contactPersonInfoAvailable = addressModel !=null && addressModel.contactPersonNumber !=null && addressModel.contactPersonNumber != "";

        return SingleChildScrollView( child: Column(children: [


          GetBuilder<ScheduleController>(builder: (scheduleController){
            return  Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Column(children: [

                isLoggedIn && configModel.content?.repeatBooking == 1 ? const ChooseBookingTypeWidget() : const SizedBox(),
                const SizedBox(height: Dimensions.paddingSizeSmall,),

                (scheduleController.selectedServiceType == ServiceType.regular || !isLoggedIn) ?
                const ServiceSchedule() : const RepeatBookingScheduleWidget(),

              ]),
            );
          }),

          const SizedBox(height: Dimensions.paddingSizeDefault,),
          const Padding(padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: AddressInformation(),
          ),


          if(!isLoggedIn && createGuestAccount &&  contactPersonInfoAvailable) const Padding( padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: CreateAccountWidget(),
          ),

          if(!isLoggedIn && createGuestAccount && contactPersonInfoAvailable) const SizedBox(height: Dimensions.paddingSizeDefault,),

          cartController.cartList.isNotEmpty &&  cartController.cartList.first.provider!= null ?
          ProviderDetailsCard( providerData: Get.find<CartController>().cartList.first.provider,): const SizedBox(),

          Get.find<AuthController>().isLoggedIn() ? const ShowVoucher() : const SizedBox(),

          const CartSummery()

        ]));
      });
    });
  }
}

