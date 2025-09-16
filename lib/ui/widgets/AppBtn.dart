import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Helper/Color.dart';

class AppBtn extends StatelessWidget {
  final String? title;
  final AnimationController? btnCntrl;
  final Animation? btnAnim;
  final VoidCallback? onBtnSelected;

  const AppBtn(
      {Key? key, this.title, this.btnCntrl, this.btnAnim, this.onBtnSelected})
      : super(key: key);


  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: _buildBtnAnimation,
      animation: btnCntrl!,
    );
  }



  Widget _buildBtnAnimation(BuildContext context, Widget? child) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: CupertinoButton(
        child: Container(
          width: btnAnim!.value,
          height: 45,
          alignment: FractionalOffset.center,
          decoration: BoxDecoration(
            border: Border.all(
                          color: colors.primary,
                          width: 2.5,
                        ),
            color: colors.blackTemp,
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          child: btnAnim!.value > 75.0
              ? Text(title!,
              textAlign: TextAlign.center,
              style: Theme
                  .of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: colors.primary, fontWeight: FontWeight.normal))
              : const CircularProgressIndicator(color: colors.primary,
            valueColor: AlwaysStoppedAnimation<Color>(colors.whiteTemp),
          ),
        ),

        onPressed: () {
          onBtnSelected!();
        },
      ),
    );
  }

}
