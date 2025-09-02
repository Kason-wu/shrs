import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct Profile {
  @State currentUser: string = '';
  @State userInfo: any = {
    name: '张三',
    phone: '138****8888',
    email: 'zhangsan@example.com',
    avatar: '',
    memberLevel: '普通会员',
    joinDate: '2024-01-15'
  };

  @State menuItems: any[] = [
    {
      icon: 'icon_booking_history',
      title: '预约记录',
      subtitle: '查看我的预约历史',
      route: 'pages/BookingHistory'
    },
    {
      icon: 'icon_favorite',
      title: '我的收藏',
      subtitle: '收藏的博物馆',
      route: ''
    },
    {
      icon: 'icon_settings',
      title: '设置',
      subtitle: '账户设置和偏好',
      route: ''
    },
    {
      icon: 'icon_help',
      title: '帮助与反馈',
      subtitle: '常见问题和意见反馈',
      route: ''
    },
    {
      icon: 'icon_about',
      title: '关于我们',
      subtitle: '了解博物馆预约系统',
      route: ''
    }
  ];

  aboutToAppear() {
    const userData = AppStorage.Get('currentUser');
    if (userData) {
      this.currentUser = userData as string;
      this.userInfo.name = this.currentUser;
    }
  }

  handleLogout() {
    promptAction.showDialog({
      title: '退出登录',
      message: '确定要退出当前账户吗？',
      buttons: [
        {
          text: '取消',
          color: '#99182431'
        },
        {
          text: '确定',
          color: '#007DFF'
        }
      ]
    }).then((result) => {
      if (result.index === 1) {
        // 清除登录状态
        AppStorage.Delete('currentUser');
        AppStorage.Delete('isLoggedIn');
        
        promptAction.showToast({
          message: '已退出登录',
          duration: 2000
        });
        
        // 返回首页
        router.replaceUrl({
          url: 'pages/Index'
        });
      }
    });
  }

  navigateToPage(route: string) {
    if (route) {
      router.pushUrl({ url: route });
    } else {
      promptAction.showToast({
        message: '功能开发中',
        duration: 2000
      });
    }
  }

  @Builder
  ProfileHeader() {
    Column() {
      // 用户头像和基本信息
      Row() {
        // 头像
        Image($r('app.media.default_avatar'))
          .width(60)
          .height(60)
          .borderRadius(30)
          .backgroundColor('#F5F5F5')
          .margin({ right: 16 })

        // 用户信息
        Column() {
          Text(this.userInfo.name)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#182431')
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 4 })

          Text(this.userInfo.memberLevel)
            .fontSize(12)
            .fontColor('#007DFF')
            .backgroundColor('#E6F2FF')
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .borderRadius(4)
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 4 })

          Text(`加入时间：${this.userInfo.joinDate}`)
            .fontSize(12)
            .fontColor('#99182431')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        // 编辑按钮
        Button() {
          Image($r('app.media.icon_edit'))
            .width(20)
            .height(20)
        }
        .width(36)
        .height(36)
        .backgroundColor('#F5F5F5')
        .borderRadius(18)
        .onClick(() => {
          promptAction.showToast({
            message: '编辑功能开发中',
            duration: 2000
          });
        })
      }
      .width('100%')
      .padding(20)

      // 统计信息
      Row() {
        Column() {
          Text('5')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#182431')
            .margin({ bottom: 4 })

          Text('预约次数')
            .fontSize(12)
            .fontColor('#99182431')
        }
        .layoutWeight(1)

        Divider()
          .vertical(true)
          .height(40)
          .color('#E5E5E5')

        Column() {
          Text('3')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#182431')
            .margin({ bottom: 4 })

          Text('收藏博物馆')
            .fontSize(12)
            .fontColor('#99182431')
        }
        .layoutWeight(1)

        Divider()
          .vertical(true)
          .height(40)
          .color('#E5E5E5')

        Column() {
          Text('128')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#182431')
            .margin({ bottom: 4 })

          Text('积分')
            .fontSize(12)
            .fontColor('#99182431')
        }
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 20 })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 16 })
  }

  @Builder
  MenuItem(item: any) {
    Row() {
      Image($r(`app.media.${item.icon}`))
        .width(24)
        .height(24)
        .margin({ right: 16 })

      Column() {
        Text(item.title)
          .fontSize(16)
          .fontColor('#182431')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 2 })

        Text(item.subtitle)
          .fontSize(12)
          .fontColor('#99182431')
          .alignSelf(ItemAlign.Start)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Image($r('app.media.icon_arrow_right'))
        .width(16)
        .height(16)
    }
    .width('100%')
    .height(60)
    .padding({ left: 20, right: 20 })
    .backgroundColor('#FFFFFF')
    .onClick(() => {
      this.navigateToPage(item.route);
    })
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

        Text('个人中心')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#182431')

        Blank()

        Button() {
          Image($r('app.media.icon_message'))
            .width(24)
            .height(24)
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          promptAction.showToast({
            message: '消息功能开发中',
            duration: 2000
          });
        })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      // 内容区域
      Scroll() {
        Column() {
          // 用户信息头部
          this.ProfileHeader()

          // 功能菜单
          Column() {
            ForEach(this.menuItems, (item: any, index: number) => {
              Column() {
                this.MenuItem(item)
                
                if (index < this.menuItems.length - 1) {
                  Divider()
                    .color('#F5F5F5')
                    .margin({ left: 60 })
                }
              }
            })
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ bottom: 16 })

          // 退出登录按钮
          Button('退出登录')
            .width('100%')
            .height(48)
            .backgroundColor('#FFFFFF')
            .fontColor('#FF3B30')
            .borderRadius(12)
            .fontSize(16)
            .onClick(() => {
              this.handleLogout();
            })

          // 版本信息
          Text('版本 1.0.0')
            .fontSize(12)
            .fontColor('#99182431')
            .margin({ top: 20, bottom: 20 })
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
  }
}