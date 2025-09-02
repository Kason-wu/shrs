import router from '@ohos.router';

@Entry
@Component
struct Index {
  @State currentUser: string = '';
  @State isLoggedIn: boolean = false;

  aboutToAppear() {
    // 检查用户登录状态
    this.checkLoginStatus();
  }

  checkLoginStatus() {
    // 模拟检查登录状态
    const userData = AppStorage.Get('currentUser');
    if (userData) {
      this.currentUser = userData as string;
      this.isLoggedIn = true;
    }
  }

  navigateToLogin() {
    router.pushUrl({
      url: 'pages/Login'
    });
  }

  navigateToMuseumList() {
    router.pushUrl({
      url: 'pages/MuseumList'
    });
  }

  navigateToProfile() {
    router.pushUrl({
      url: 'pages/Profile'
    });
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('博物馆预约系统')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#182431')
        
        Blank()
        
        if (this.isLoggedIn) {
          Button('个人中心')
            .fontSize(14)
            .backgroundColor('#007DFF')
            .onClick(() => {
              this.navigateToProfile();
            })
        } else {
          Button('登录')
            .fontSize(14)
            .backgroundColor('#007DFF')
            .onClick(() => {
              this.navigateToLogin();
            })
        }
      }
      .width('100%')
      .height(60)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      // 主要内容区域
      Column() {
        // 欢迎区域
        Column() {
          Image($r('app.media.icon'))
            .width('100%')
            .height(200)
            .objectFit(ImageFit.Cover)
            .borderRadius(12)
            .margin({ bottom: 16 })
          
          Text('探索文化之旅')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#182431')
            .margin({ bottom: 8 })
          
          Text('预约参观，感受历史文化的魅力')
            .fontSize(16)
            .fontColor('#99182431')
            .margin({ bottom: 24 })
        }
        .padding(16)

        // 功能按钮区域
        Grid() {
          GridItem() {
            Column() {
              Image($r('app.media.icon'))
                .width(48)
                .height(48)
                .margin({ bottom: 8 })
              
              Text('博物馆列表')
                .fontSize(14)
                .fontColor('#182431')
            }
            .width('100%')
            .height(100)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.navigateToMuseumList();
            })
          }

          GridItem() {
            Column() {
              Image($r('app.media.icon'))
                .width(48)
                .height(48)
                .margin({ bottom: 8 })
              
              Text('我的预约')
                .fontSize(14)
                .fontColor('#182431')
            }
            .width('100%')
            .height(100)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              if (this.isLoggedIn) {
                router.pushUrl({ url: 'pages/BookingHistory' });
              } else {
                this.navigateToLogin();
              }
            })
          }

          GridItem() {
            Column() {
              Image($r('app.media.icon'))
                .width(48)
                .height(48)
                .margin({ bottom: 8 })
              
              Text('个人中心')
                .fontSize(14)
                .fontColor('#182431')
            }
            .width('100%')
            .height(100)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              if (this.isLoggedIn) {
                this.navigateToProfile();
              } else {
                this.navigateToLogin();
              }
            })
          }

          GridItem() {
            Column() {
              Image($r('app.media.icon'))
                .width(48)
                .height(48)
                .margin({ bottom: 8 })
              
              Text('帮助中心')
                .fontSize(14)
                .fontColor('#182431')
            }
            .width('100%')
            .height(100)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              // 显示帮助信息
            })
          }
        }
        .columnsTemplate('1fr 1fr')
        .rowsTemplate('1fr 1fr')
        .columnsGap(12)
        .rowsGap(12)
        .width('100%')
        .height(220)
        .padding({ left: 16, right: 16 })

        Blank()

        // 底部信息
        Text('© 2024 博物馆预约系统')
          .fontSize(12)
          .fontColor('#99182431')
          .margin({ bottom: 16 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
  }
}