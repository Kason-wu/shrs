/**
 * 加载对话框组件
 */
@CustomDialog
export struct LoadingDialog {
  controller: CustomDialogController;
  message: string = '加载中...';

  build() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
        .color('#007DFF')
        .margin({ bottom: 16 })

      Text(this.message)
        .fontSize(14)
        .fontColor('#182431')
    }
    .width(120)
    .height(120)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}