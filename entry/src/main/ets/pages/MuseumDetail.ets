import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

interface Museum {
  id: number;
  name: string;
  description: string;
  image: string;
  location: string;
  rating: number;
  price: number;
  openTime: string;
  tags: string[];
  distance: string;
}

interface Exhibition {
  id: number;
  name: string;
  description: string;
  startDate: string;
  endDate: string;
  image: string;
}

@Entry
@Component
struct MuseumDetail {
  @State museum: Museum = {
    id: 1,
    name: '国家博物馆',
    description: '中国历史文化的重要展示窗口，收藏丰富的文物珍品',
    image: 'museum1.jpg',
    location: '北京市东城区',
    rating: 4.8,
    price: 0,
    openTime: '09:00-17:00',
    tags: ['历史', '文物', '免费'],
    distance: '2.3km'
  };

  @State currentTab: number = 0;
  @State isFavorite: boolean = false;
  @State exhibitions: Exhibition[] = [
    {
      id: 1,
      name: '古代中国文明展',
      description: '展示中华五千年文明发展历程',
      startDate: '2024-01-01',
      endDate: '2024-12-31',
      image: 'exhibition1.jpg'
    },
    {
      id: 2,
      name: '丝绸之路文物展',
      description: '重现古代丝绸之路的繁荣景象',
      startDate: '2024-03-01',
      endDate: '2024-08-31',
      image: 'exhibition2.jpg'
    }
  ];

  @State facilities: string[] = ['停车场', '餐厅', '纪念品店', '无障碍通道', 'WiFi', '导览服务'];
  @State visitRules: string[] = [
    '请提前预约参观时间',
    '参观时请保持安静',
    '禁止触摸展品',
    '禁止使用闪光灯拍照',
    '请勿携带食物和饮料入馆',
    '请配合安检工作'
  ];

  aboutToAppear() {
    const params = router.getParams() as { museum: Museum };
    if (params && params.museum) {
      this.museum = params.museum;
    }
  }

  toggleFavorite() {
    this.isFavorite = !this.isFavorite;
    promptAction.showToast({
      message: this.isFavorite ? '已添加到收藏' : '已取消收藏',
      duration: 2000
    });
  }

  navigateToBooking() {
    const isLoggedIn = AppStorage.Get('isLoggedIn') as boolean;
    if (!isLoggedIn) {
      promptAction.showToast({
        message: '请先登录',
        duration: 2000
      });
      router.pushUrl({ url: 'pages/Login' });
      return;
    }

    router.pushUrl({
      url: 'pages/BookingPage',
      params: { museum: this.museum }
    });
  }

  @Builder
  TabContent() {
    if (this.currentTab === 0) {
      // 基本信息
      this.BasicInfoContent()
    } else if (this.currentTab === 1) {
      // 展览信息
      this.ExhibitionContent()
    } else if (this.currentTab === 2) {
      // 参观须知
      this.VisitRulesContent()
    }
  }

  @Builder
  BasicInfoContent() {
    Column() {
      // 详细描述
      Column() {
        Text('博物馆介绍')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#182431')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 12 })

        Text(this.museum.description + '\n\n这里收藏着丰富的历史文物和艺术珍品，是了解中华文明的重要窗口。博物馆建筑宏伟，展陈设计精美，为观众提供了良好的参观体验。')
          .fontSize(14)
          .fontColor('#182431')
          .lineHeight(22)
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .margin({ bottom: 12 })

      // 开放时间
      Column() {
        Text('开放时间')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#182431')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 12 })

        Row() {
          Text('周一至周日')
            .fontSize(14)
            .fontColor('#182431')
            .layoutWeight(1)

          Text(this.museum.openTime)
            .fontSize(14)
            .fontColor('#007DFF')
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')

        Text('* 节假日开放时间可能有所调整，请提前确认')
          .fontSize(12)
          .fontColor('#99182431')
          .margin({ top: 8 })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .margin({ bottom: 12 })

      // 设施服务
      Column() {
        Text('设施服务')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#182431')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 12 })

        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.facilities, (facility: string) => {
            Text(facility)
              .fontSize(12)
              .fontColor('#007DFF')
              .backgroundColor('#E6F2FF')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(4)
              .margin({ right: 8, bottom: 8 })
          })
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .margin({ bottom: 12 })
    }
    .width('100%')
  }

  @Builder
  ExhibitionContent() {
    Column() {
      if (this.exhibitions.length > 0) {
        ForEach(this.exhibitions, (exhibition: Exhibition) => {
          Column() {
            Row() {
              Image($r('app.media.exhibition_placeholder'))
                .width(80)
                .height(60)
                .objectFit(ImageFit.Cover)
                .borderRadius(8)
                .margin({ right: 12 })

              Column() {
                Text(exhibition.name)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#182431')
                  .alignSelf(ItemAlign.Start)
                  .margin({ bottom: 4 })

                Text(exhibition.description)
                  .fontSize(12)
                  .fontColor('#99182431')
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .margin({ bottom: 4 })

                Text(`${exhibition.startDate} - ${exhibition.endDate}`)
                  .fontSize(12)
                  .fontColor('#007DFF')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ bottom: 12 })
        })
      } else {
        Column() {
          Image($r('app.media.icon_empty'))
            .width(60)
            .height(60)
            .margin({ bottom: 16 })

          Text('暂无展览信息')
            .fontSize(16)
            .fontColor('#99182431')
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
  }

  @Builder
  VisitRulesContent() {
    Column() {
      Column() {
        Text('参观须知')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#182431')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 16 })

        ForEach(this.visitRules, (rule: string, index: number) => {
          Row() {
            Text(`${index + 1}.`)
              .fontSize(14)
              .fontColor('#007DFF')
              .margin({ right: 8 })

            Text(rule)
              .fontSize(14)
              .fontColor('#182431')
              .layoutWeight(1)
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)
          .margin({ bottom: 12 })
        })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
    }
    .width('100%')
  }

  build() {
    Column() {
      // 顶部图片和导航
      Stack({ alignContent: Alignment.TopStart }) {
        Image($r('app.media.museum_detail_banner'))
          .width('100%')
          .height(250)
          .objectFit(ImageFit.Cover)

        // 顶部导航按钮
        Row() {
          Button() {
            Image($r('app.media.icon_back_white'))
              .width(24)
              .height(24)
          }
          .width(40)
          .height(40)
          .backgroundColor('rgba(0,0,0,0.3)')
          .borderRadius(20)
          .onClick(() => {
            router.back();
          })

          Blank()

          Button() {
            Image(this.isFavorite ? $r('app.media.icon_heart_filled') : $r('app.media.icon_heart'))
              .width(24)
              .height(24)
          }
          .width(40)
          .height(40)
          .backgroundColor('rgba(0,0,0,0.3)')
          .borderRadius(20)
          .onClick(() => {
            this.toggleFavorite();
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 44 })
      }

      // 博物馆基本信息
      Column() {
        Row() {
          Column() {
            Text(this.museum.name)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#182431')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 4 })

            Row() {
              Image($r('app.media.icon_location'))
                .width(14)
                .height(14)
                .margin({ right: 4 })

              Text(this.museum.location)
                .fontSize(14)
                .fontColor('#99182431')

              Text(this.museum.distance)
                .fontSize(14)
                .fontColor('#99182431')
                .margin({ left: 8 })
            }
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Column() {
            Row() {
              Image($r('app.media.icon_star'))
                .width(16)
                .height(16)
                .margin({ right: 4 })

              Text(this.museum.rating.toString())
                .fontSize(16)
                .fontColor('#FF9500')
                .fontWeight(FontWeight.Bold)
            }

            Text(this.museum.price === 0 ? '免费' : `¥${this.museum.price}`)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.museum.price === 0 ? '#00C853' : '#FF6B35')
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.End)
        }
        .width('100%')
        .margin({ bottom: 16 })

        // 标签
        Row() {
          ForEach(this.museum.tags, (tag: string) => {
            Text(tag)
              .fontSize(12)
              .fontColor('#007DFF')
              .backgroundColor('#E6F2FF')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(4)
              .margin({ right: 8 })
          })
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')

      // 标签页
      Column() {
        Row() {
          ForEach(['基本信息', '展览信息', '参观须知'], (tab: string, index: number) => {
            Text(tab)
              .fontSize(14)
              .fontColor(this.currentTab === index ? '#007DFF' : '#99182431')
              .fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Normal)
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .onClick(() => {
                this.currentTab = index;
              })
          })
        }
        .width('100%')
        .backgroundColor('#FFFFFF')

        // 内容区域
        Scroll() {
          this.TabContent()
        }
        .layoutWeight(1)
        .padding({ top: 16 })
        .backgroundColor('#F5F5F5')
      }
      .layoutWeight(1)

      // 底部预约按钮
      Row() {
        Button('立即预约')
          .width('100%')
          .height(48)
          .backgroundColor('#007DFF')
          .borderRadius(8)
          .fontSize(16)
          .fontColor('#FFFFFF')
          .onClick(() => {
            this.navigateToBooking();
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
    }
    .width('100%')
    .height('100%')
  }
}