import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct Register {
  @State username: string = '';
  @State email: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State phone: string = '';
  @State isLoading: boolean = false;
  @State agreeTerms: boolean = false;

  validateEmail(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  validatePhone(phone: string): boolean {
    const phoneRegex = /^1[3-9]\d{9}$/;
    return phoneRegex.test(phone);
  }

  async handleRegister() {
    if (!this.username.trim()) {
      promptAction.showToast({
        message: '请输入用户名',
        duration: 2000
      });
      return;
    }

    if (!this.email.trim() || !this.validateEmail(this.email)) {
      promptAction.showToast({
        message: '请输入有效的邮箱地址',
        duration: 2000
      });
      return;
    }

    if (!this.phone.trim() || !this.validatePhone(this.phone)) {
      promptAction.showToast({
        message: '请输入有效的手机号码',
        duration: 2000
      });
      return;
    }

    if (!this.password.trim() || this.password.length < 6) {
      promptAction.showToast({
        message: '密码长度不能少于6位',
        duration: 2000
      });
      return;
    }

    if (this.password !== this.confirmPassword) {
      promptAction.showToast({
        message: '两次输入的密码不一致',
        duration: 2000
      });
      return;
    }

    if (!this.agreeTerms) {
      promptAction.showToast({
        message: '请同意用户协议和隐私政策',
        duration: 2000
      });
      return;
    }

    this.isLoading = true;

    // 模拟注册请求
    setTimeout(() => {
      this.isLoading = false;
      
      promptAction.showToast({
        message: '注册成功，请登录',
        duration: 2000
      });

      // 跳转到登录页面
      router.replaceUrl({
        url: 'pages/Login'
      });
    }, 2000);
  }

  build() {
    Column() {
      // 顶部导航
      Row() {
        Button() {
          Image($r('app.media.icon'))
            .width(24)
            .height(24)
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          router.back();
        })

        Text('用户注册')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#182431')

        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      // 注册表单
      Scroll() {
        Column() {
          // 标题区域
          Column() {
            Text('创建账号')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#182431')
              .margin({ bottom: 8 })

            Text('加入博物馆预约系统')
              .fontSize(16)
              .fontColor('#99182431')
              .margin({ bottom: 30 })
          }
          .margin({ top: 30, bottom: 20 })

          // 输入框区域
          Column() {
            // 用户名
            Column() {
              Text('用户名')
                .fontSize(14)
                .fontColor('#182431')
                .alignSelf(ItemAlign.Start)
                .margin({ bottom: 8 })

              TextInput({ placeholder: '请输入用户名' })
                .width('100%')
                .height(48)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
                .fontSize(16)
                .onChange((value: string) => {
                  this.username = value;
                })
            }
            .width('100%')
            .margin({ bottom: 16 })

            // 邮箱
            Column() {
              Text('邮箱')
                .fontSize(14)
                .fontColor('#182431')
                .alignSelf(ItemAlign.Start)
                .margin({ bottom: 8 })

              TextInput({ placeholder: '请输入邮箱地址' })
                .width('100%')
                .height(48)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
                .fontSize(16)
                .type(InputType.Email)
                .onChange((value: string) => {
                  this.email = value;
                })
            }
            .width('100%')
            .margin({ bottom: 16 })

            // 手机号
            Column() {
              Text('手机号')
                .fontSize(14)
                .fontColor('#182431')
                .alignSelf(ItemAlign.Start)
                .margin({ bottom: 8 })

              TextInput({ placeholder: '请输入手机号码' })
                .width('100%')
                .height(48)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
                .fontSize(16)
                .type(InputType.PhoneNumber)
                .onChange((value: string) => {
                  this.phone = value;
                })
            }
            .width('100%')
            .margin({ bottom: 16 })

            // 密码
            Column() {
              Text('密码')
                .fontSize(14)
                .fontColor('#182431')
                .alignSelf(ItemAlign.Start)
                .margin({ bottom: 8 })

              TextInput({ placeholder: '请输入密码（至少6位）' })
                .width('100%')
                .height(48)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
                .fontSize(16)
                .type(InputType.Password)
                .onChange((value: string) => {
                  this.password = value;
                })
            }
            .width('100%')
            .margin({ bottom: 16 })

            // 确认密码
            Column() {
              Text('确认密码')
                .fontSize(14)
                .fontColor('#182431')
                .alignSelf(ItemAlign.Start)
                .margin({ bottom: 8 })

              TextInput({ placeholder: '请再次输入密码' })
                .width('100%')
                .height(48)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
                .fontSize(16)
                .type(InputType.Password)
                .onChange((value: string) => {
                  this.confirmPassword = value;
                })
            }
            .width('100%')
            .margin({ bottom: 20 })

            // 协议同意
            Row() {
              Checkbox()
                .select(this.agreeTerms)
                .onChange((value: boolean) => {
                  this.agreeTerms = value;
                })

              Text() {
                Span('我已阅读并同意')
                  .fontSize(14)
                  .fontColor('#99182431')
                Span('《用户协议》')
                  .fontSize(14)
                  .fontColor('#007DFF')
                Span('和')
                  .fontSize(14)
                  .fontColor('#99182431')
                Span('《隐私政策》')
                  .fontSize(14)
                  .fontColor('#007DFF')
              }
              .margin({ left: 8 })
            }
            .alignItems(VerticalAlign.Center)
            .margin({ bottom: 30 })

            // 注册按钮
            Button(this.isLoading ? '注册中...' : '注册')
              .width('100%')
              .height(48)
              .backgroundColor('#007DFF')
              .borderRadius(8)
              .fontSize(16)
              .fontColor('#FFFFFF')
              .enabled(!this.isLoading)
              .onClick(() => {
                this.handleRegister();
              })

            // 登录链接
            Row() {
              Text('已有账号？')
                .fontSize(14)
                .fontColor('#99182431')

              Text('立即登录')
                .fontSize(14)
                .fontColor('#007DFF')
                .onClick(() => {
                  router.replaceUrl({
                    url: 'pages/Login'
                  });
                })
            }
            .margin({ top: 20 })
          }
          .width('100%')
          .padding({ left: 24, right: 24 })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .backgroundColor('#FFFFFF')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}