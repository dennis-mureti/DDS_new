import 'package:distributor/conf/style/lib/text_styles.dart';
import 'package:distributor/core/enums.dart';
import 'package:distributor/src/ui/views/change_password/change_password_viewmodel.dart';
import 'package:distributor/ui/widgets/dumb_widgets/misc_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class ChangePasswordView extends StatelessWidget {
  final PasswordChangeType passwordChangeType;
  final String identityType;
  final String identityValue;

  const ChangePasswordView(
      {Key key,
      @required this.passwordChangeType,
      this.identityType,
      this.identityValue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChangePasswordViewModel>.reactive(
        builder: (context, model, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Change Password'),
            ),
            body: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: ListView(
                children: [
                  Text(
                    model.introTextToDisplay,
                    style: kLeadingBodyText,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  _oldPassTextFormField(),
                  const SizedBox(
                    height: 8,
                  ),
                  _newPassTextFormField(),
                  const SizedBox(
                    height: 8,
                  ),
                  _confirmPassTextFormField(),
                  const SizedBox(
                    height: 8,
                  ),
                  model.isBusy
                      ? BusyWidget()
                      : ElevatedButton(
                          onPressed:
                              model.enableSubmit ? model.changePassword : null,
                          child: const Text('Change Password'),
                        )
                ],
              ),
            ),
          );
        },
        viewModelBuilder: () =>
            ChangePasswordViewModel(passwordChangeType, identityValue));
  }
}

class _oldPassTextFormField
    extends HookViewModelWidget<ChangePasswordViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, ChangePasswordViewModel model) {
    var _controller = useTextEditingController();
    return TextFormField(
      onChanged: (val) => model.setOldPassword(val),
      controller: _controller,
      decoration: InputDecoration(
          labelText: model.passwordChangeType != PasswordChangeType.user
              ? 'Temporary password'
              : 'Old Password'),
    );
  }
}

class _newPassTextFormField
    extends HookViewModelWidget<ChangePasswordViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, ChangePasswordViewModel model) {
    var _controller = useTextEditingController();
    return TextFormField(
      onChanged: (val) => model.setNewPassword(val),
      controller: _controller,
      decoration: InputDecoration(labelText: 'New password'),
    );
  }
}

class _confirmPassTextFormField
    extends HookViewModelWidget<ChangePasswordViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, ChangePasswordViewModel model) {
    var _controller = useTextEditingController();
    return TextFormField(
      onChanged: (val) => model.setConfirmPassword(val),
      controller: _controller,
      decoration: const InputDecoration(labelText: 'Confirm password'),
    );
  }
}
