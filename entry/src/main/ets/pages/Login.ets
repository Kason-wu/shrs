import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct Login {
  @State username: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;

  async handleLogin() {
    if (!this.username.trim()) {
      promptAction.showToast({
        message: '请输入用户名',
        duration: 2000
      });
      return;
    }

    if (!this.password.trim()) {
      promptAction.showToast({
        message: '请输入密码',
        duration: 2000
      });
      return;
    }

    this.isLoading = true;

    // 模拟登录请求
    setTimeout(() => {
      this.isLoading = false;
      
      // 模拟登录成功
      AppStorage.SetOrCreate('currentUser', this.username);
      AppStorage.SetOrCreate('isLoggedIn', true);
      
      promptAction.showToast({
        message: '登录成功',
        duration: 2000
      });

      // 返回首页
      router.back();
    }, 1500);
  }

  navigateToRegister() {
    router.pushUrl({
      url: 'pages/Register'
    });
  }

  build() {
    Column() {
      // 顶部导航
      Row() {
        Button() {
          Image($r('app.media.icon_back'))
            .width(24)
            .height(24)
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          router.back();
        })

        Text('用户登录')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#182431')

        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      // 登录表单
      Column() {
        // Logo区域
        Column() {
          Image($r('app.media.app_icon'))
            .width(80)
            .height(80)
            .margin({ bottom: 16 })

          Text('博物馆预约系统')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#182431')
            .margin({ bottom: 8 })

          Text('欢迎回来')
            .fontSize(16)
            .fontColor('#99182431')
            .margin({ bottom: 40 })
        }
        .margin({ top: 60, bottom: 40 })

        // 输入框区域
        Column() {
          // 用户名输入框
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
          .margin({ bottom: 20 })

          // 密码输入框
          Column() {
            Text('密码')
              .fontSize(14)
              .fontColor('#182431')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 8 })

            TextInput({ placeholder: '请输入密码' })
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
          .margin({ bottom: 30 })

          // 登录按钮
          Button(this.isLoading ? '登录中...' : '登录')
            .width('100%')
            .height(48)
            .backgroundColor('#007DFF')
            .borderRadius(8)
            .fontSize(16)
            .fontColor('#FFFFFF')
            .enabled(!this.isLoading)
            .onClick(() => {
              this.handleLogin();
            })

          // 注册链接
          Row() {
            Text('还没有账号？')
              .fontSize(14)
              .fontColor('#99182431')

            Text('立即注册')
              .fontSize(14)
              .fontColor('#007DFF')
              .onClick(() => {
                this.navigateToRegister();
              })
          }
          .margin({ top: 20 })
        }
        .width('100%')
        .padding({ left: 24, right: 24 })
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#FFFFFF')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}