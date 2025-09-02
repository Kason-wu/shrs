/**
 * 空状态组件
 */
@Component
export struct EmptyState {
  @Prop icon: Resource = $r('app.media.icon');
  @Prop title: string = '暂无数据';
  @Prop subtitle: string = '';
  @Prop buttonText: string = '';
  @Prop onButtonClick: () => void = () => {};

  build() {
    Column() {
      Image(this.icon)
        .width(80)
        .height(80)
        .margin({ bottom: 16 })

      Text(this.title)
        .fontSize(16)
        .fontColor('#99182431')
        .margin({ bottom: this.subtitle ? 8 : 24 })

      if (this.subtitle) {
        Text(this.subtitle)
          .fontSize(14)
          .fontColor('#99182431')
          .margin({ bottom: 24 })
      }

      if (this.buttonText) {
        Button(this.buttonText)
          .height(40)
          .backgroundColor('#007DFF')
          .fontColor('#FFFFFF')
          .borderRadius(20)
          .fontSize(14)
          .onClick(() => {
            this.onButtonClick();
          })
      }
    }
    .width('100%')
    .height(200)
    .justifyContent(FlexAlign.Center)
  }
}