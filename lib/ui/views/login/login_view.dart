import 'package:distributor/conf/dds_brand_guide.dart';
import 'package:distributor/conf/style/lib/text_styles.dart';
import 'package:distributor/ui/shared/widgets.dart';
import 'package:distributor/ui/views/login/login_viewmodel.dart';
import 'package:distributor/ui/widgets/dumb_widgets/busy_widget.dart';
import 'package:distributor/ui/widgets/smart_widgets/progress_bars/linear_progress_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:tripletriocore/tripletriocore.dart';

class LoginView extends StatefulWidget {
  final String userId;
  final String password;

  const LoginView({Key key, this.userId, this.password}) : super(key: key);
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _userIdController;
  TextEditingController _passwordController;
  @override
  void initState() {
    _userIdController = TextEditingController(text: widget.userId);
    _passwordController = TextEditingController(text: widget.password);
    super.initState();
  }

  @override
  void dispose() {
    _userIdController?.dispose();
    _passwordController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LoginViewModel>.reactive(
      onModelReady: (model) => model.init(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            title: model.environments.length > 1
                ? _buildEnvironmentSelectionDropdown(model: model)
                : Container()),
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: BoxDecoration(
              // image: DecorationImage(
              //     image: AssetImage('assets/images/login_bg.jpg'),
              //     fit: BoxFit.cover),
              color: kColDDSPrimaryDark
              // gradient: LinearGradient(
              //   begin: Alignment.topCenter,
              //   end: Alignment.bottomCenter,
              //   colors: [
              //     kDarkNeutral,
              //     kDarkNeutral20,
              //   ],
              // ),
              ),
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              // NetworkSensitiveWidget(),
              // model.enableSignIn
              //     ? Container()
              //     : Container(
              //         color: Colors.red,
              //         child: Padding(
              //           padding: const EdgeInsets.all(8.0),
              //           child: Text(
              //             'You are currently outside your preassigned zone. ',
              //             style: TextStyle(
              //                 color: Colors.black, fontSize: 16),
              //           ),
              //         )),
              Spacer(),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLoginContainer(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Container(
                          //   child: Image.asset('assets/images/mini_logo.png'),
                          //   // width: 150,
                          //   height: 100,
                          // ),
                          Container(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                  'assets/images/dds_logo_horizontal.png'),
                            ),
                            // width: 150,
                            height: 80,
                          ),
                          // Image.asset('asset/images/login.png'),

                          // LoginTextField(
                          //   text: 'DDS Sign In',
                          // ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormFieldPadding(
                            child: TextFormField(
                              controller: _userIdController,
                              style: kFormInputTextStyle,
                              onChanged: (String val) {
                                model.setUserId(val);
                              },
                              onFieldSubmitted: (value) {
                                FocusScope.of(context).nextFocus();
                              },
                              onEditingComplete: () =>
                                  FocusScope.of(context).nextFocus(),
                              validator: (String value) {
                                if (value != null) {
                                  return 'Please enter a valid email address or phone number';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                filled: false,
                                hintText: 'Email Address / Phone ',
                                hintStyle: kFormHintTextStyle,
                                prefixIcon: Icon(
                                  Icons.person,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormFieldPadding(
                            child: TextFormField(
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Please enter a password";
                                }
                                return null;
                              },
                              style: kFormInputTextStyle,
                              onChanged: (String val) =>
                                  model.updatePassword(val),
                              keyboardType: TextInputType.text,
                              controller: _passwordController,
                              obscureText: model.obscurePassword,
                              decoration: InputDecoration(
                                filled: false,
                                hintText: 'password',
                                hintStyle: kFormHintTextStyle,
                                prefixIcon: Icon(
                                  Icons.lock,
                                  size: 20,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: model.toggleObscurePassword,
                                  icon: model.obscurePassword
                                      ? Icon(
                                          FontAwesomeIcons.eye,
                                          size: 15,
                                          color: Colors.grey,
                                        )
                                      : Icon(
                                          FontAwesomeIcons.eyeSlash,
                                          size: 15,
                                          color: Colors.grey,
                                        ),
                                ),
                              ),
                            ),
                          ),

                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 18.0),
                            child: Row(
                              children: [
                                Text('Select Language : '),
                                SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: DropdownButton(
                                      isExpanded: true,
                                      value: model.language,
                                      items: model.languages
                                          .map(
                                            (e) => DropdownMenuItem(
                                              child: Text(e),
                                              value: e,
                                            ),
                                          )
                                          .toList(),
                                      onChanged: model.setLanguage),
                                ),
                              ],
                            ),
                          ),
                          model.passwordValidationMessage == null
                              ? Container()
                              : FormErrorContainer(
                                  errorMsg: model.passwordValidationMessage,
                                ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Padding(
                              //   padding:
                              //       const EdgeInsets.only(left: 8.0, top: 5),
                              //   child: RememberMeCheckbox(),
                              // ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 8.0, top: 10),
                                child: TextButton(
                                    onPressed: model.navigateToForgotPassword,
                                    child: Text(
                                      'Reset Password',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          decoration: TextDecoration.underline),
                                    )),
                              )
                            ],
                          ),
                          UIHelper.verticalSpace(10),
                          model.isBusy
                              ? BusyWidget()
                              : ElevatedButton(
                                  // padding: EdgeInsets.symmetric(
                                  //     horizontal: 20, vertical: 14),
                                  // shape: RoundedRectangleBorder(
                                  //     borderRadius: BorderRadius.circular(6)),
                                  child: Container(
                                    width: 250,
                                    child: Center(
                                      child: Text(
                                        'Sign in'.toUpperCase(),
                                        style: TextStyle(
                                          fontFamily: 'NerisBlack',
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  onPressed: model.userId == null ||
                                          model.password == null ||
                                          model.userId.isEmpty ||
                                          model.password.isEmpty
                                      ? null
                                      : () {
                                          // if (_formKey.currentState.validate()) {
                                          //Close the keyboard
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();

                                          model.login();
                                          // }
                                        },
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              kColDDSPrimaryDark)),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onTap: () => model.checkForUpdates(),
                  child: Text(
                    'Version : ${model.versionCode}',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ),
              Spacer(),
              model.hasUpdate && !model.isComplete
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: LinearProgressIndicatorWidget(
                          progressValue: model.downloaded),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
      viewModelBuilder: () => LoginViewModel(widget.userId, widget.password),
    );
  }

  Widget _buildLoginContainer({Widget child}) {
    return SizedBox(
      width: 400,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: child,
        ),
        decoration: BoxDecoration(
            boxShadow: [
              // BoxShadow(
              //     color: kDarkNeutral20,
              //     offset: Offset(1, 1),
              //     blurRadius: 6,
              //     spreadRadius: 0.8)
            ],
            // borderRadius: BorderRadius.circular(4),
            color: Colors.white),
      ),
    );
  }

  Widget _buildEnvironmentSelectionDropdown({@required LoginViewModel model}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: DropdownButton(
            dropdownColor: Color(0xFF022065),
            isExpanded: true,
            onChanged: (AppEnv val) {
              model.updateEnv(val);
            },
            value: model.appEnv,
            items: model.environments
                .map((e) => DropdownMenuItem(
                      child: Text(
                        e.name,
                        style: TextStyle(color: Colors.white),
                      ),
                      value: e,
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}
