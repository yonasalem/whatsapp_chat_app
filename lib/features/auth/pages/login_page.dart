import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_chat_app/common/extensions/custom_theme_extension.dart';
import 'package:whatsapp_chat_app/common/helper/show_alert_dialog.dart';
import 'package:whatsapp_chat_app/common/utils/coloors.dart';
import 'package:whatsapp_chat_app/common/widgets/custom_elevated_button.dart';
import 'package:whatsapp_chat_app/common/widgets/my_icon_button.dart';
import 'package:whatsapp_chat_app/features/auth/controllers/auth_controller.dart';
import 'package:whatsapp_chat_app/features/auth/widgets/custom_text_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  static const String id = 'login';
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  TextEditingController countryNameController = TextEditingController();
  TextEditingController countryCodeController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  pickCountryCode() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      favorite: ['ET'],
      countryListTheme: CountryListThemeData(
        bottomSheetHeight: 600,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        flagSize: 22,
        borderRadius: BorderRadius.circular(20),
        textStyle: TextStyle(color: context.color.greyColor!),
        inputDecoration: InputDecoration(
          labelStyle: TextStyle(color: context.color.greyColor),
          prefixIcon: const Icon(
            Icons.language,
            color: Coloors.greenDark,
          ),
          hintText: 'Search country code or name',
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: context.color.greyColor!.withOpacity(0.2)),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Coloors.greenDark, width: 2),
          ),
        ),
      ),
      onSelect: (code) {
        countryNameController.text = code.name;
        countryCodeController.text = code.phoneCode;
      },
    );
  }

  @override
  void didChangeDependencies() {
    countryCodeController.text = '251';
    countryNameController.text = 'Ethiopia';
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    countryNameController.dispose();
    countryCodeController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  sendCodeToPhone() {
    final phoneNumber = phoneNumberController.text;
    final countryCode = countryCodeController.text;
    final countryName = countryNameController.text;

    // check phone number before requesting login
    if (phoneNumber.isEmpty) {
      return showAlertDialog(
        context: context,
        message: 'Please enter your phone number',
      );
    } else if (phoneNumber.length < 9) {
      return showAlertDialog(
        context: context,
        message: "The phone number you entered is too short for the country: $countryName.\n\n"
            "Include your area code if you haven't",
      );
    } else if (phoneNumber.length > 10) {
      return showAlertDialog(
        context: context,
        message: 'The phone number you entered is too long for the country: $countryName.',
      );
    }

    // request a verification code
    ref.read(authControllerProvider).sendSmsCode(
          context: context,
          phone: "+$countryCode$phoneNumber",
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Enter your phone number',
          style: TextStyle(color: context.color.authAppbarTextColor),
        ),
        centerTitle: true,
        actions: [
          MyIconButton(
            onTap: () {},
            icon: Icons.more_vert,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    color: context.color.greyColor,
                    height: 1.3,
                  ),
                  children: [
                    const TextSpan(
                      text: 'WhatsApp will need to verify your phone number. ',
                    ),
                    TextSpan(
                      text: "What's my number?",
                      style: TextStyle(color: context.color.blueColor),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: CustomTextField(
                onTap: pickCountryCode,
                controller: countryNameController,
                readOnly: true,
                suffixIcon: const Icon(
                  Icons.arrow_drop_down,
                  color: Coloors.greenDark,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: CustomTextField(
                      onTap: pickCountryCode,
                      controller: countryCodeController,
                      prefixText: ' +',
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: phoneNumberController,
                      hintText: 'phone number',
                      textAlign: TextAlign.left,
                      autoFocus: true,
                      keyBoardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Carrier charges may apply',
              style: TextStyle(color: context.color.greyColor),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: CustomElevatedButton(
        onPressed: sendCodeToPhone,
        text: 'NEXT',
        buttonWidth: 90,
      ),
    );
  }
}
