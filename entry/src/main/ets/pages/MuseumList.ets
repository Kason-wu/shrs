import router from '@ohos.router';

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

@Entry
@Component
struct MuseumList {
  @State museums: Museum[] = [
    {
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
    },
    {
      id: 2,
      name: '故宫博物院',
      description: '明清两代皇宫，世界文化遗产，珍藏无数珍贵文物',
      image: 'museum2.jpg',
      location: '北京市东城区',
      rating: 4.9,
      price: 60,
      openTime: '08:30-17:00',
      tags: ['皇宫', '文化遗产', '建筑'],
      distance: '1.8km'
    },
    {
      id: 3,
      name: '中国科技馆',
      description: '现代科技展示中心，互动体验丰富，适合全家参观',
      image: 'museum3.jpg',
      location: '北京市朝阳区',
      rating: 4.7,
      price: 30,
      openTime: '09:30-17:00',
      tags: ['科技', '互动', '教育'],
      distance: '5.2km'
    },
    {
      id: 4,
      name: '首都博物馆',
      description: '展示北京历史文化，建筑现代，展品精美',
      image: 'museum4.jpg',
      location: '北京市西城区',
      rating: 4.6,
      price: 0,
      openTime: '09:00-17:00',
      tags: ['北京历史', '免费', '现代'],
      distance: '3.7km'
    },
    {
      id: 5,
      name: '中国美术馆',
      description: '国家级美术馆，收藏现当代优秀美术作品',
      image: 'museum5.jpg',
      location: '北京市东城区',
      rating: 4.5,
      price: 0,
      openTime: '09:00-17:00',
      tags: ['美术', '艺术', '免费'],
      distance: '2.9km'
    }
  ];

  @State searchText: string = '';
  @State selectedCategory: string = '全部';
  @State categories: string[] = ['全部', '历史', '艺术', '科技', '免费'];

  getFilteredMuseums(): Museum[] {
    let filtered = this.museums;

    // 按分类筛选
    if (this.selectedCategory !== '全部') {
      filtered = filtered.filter(museum => 
        museum.tags.includes(this.selectedCategory)
      );
    }

    // 按搜索文本筛选
    if (this.searchText.trim()) {
      filtered = filtered.filter(museum =>
        museum.name.includes(this.searchText) ||
        museum.description.includes(this.searchText) ||
        museum.location.includes(this.searchText)
      );
    }

    return filtered;
  }

  navigateToDetail(museum: Museum) {
    router.pushUrl({
      url: 'pages/MuseumDetail',
      params: { museum: museum }
    });
  }

  @Builder
  MuseumCard(museum: Museum) {
    Column() {
      // 博物馆图片
      Image($r('app.media.museum_placeholder'))
        .width('100%')
        .height(120)
        .objectFit(ImageFit.Cover)
        .borderRadius({ topLeft: 12, topRight: 12 })

      // 博物馆信息
      Column() {
        // 名称和评分
        Row() {
          Text(museum.name)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#182431')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)

          Row() {
            Image($r('app.media.icon_star'))
              .width(14)
              .height(14)
              .margin({ right: 4 })

            Text(museum.rating.toString())
              .fontSize(12)
              .fontColor('#FF9500')
          }
        }
        .width('100%')
        .margin({ bottom: 8 })

        // 描述
        Text(museum.description)
          .fontSize(12)
          .fontColor('#99182431')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: 8 })

        // 位置和距离
        Row() {
          Image($r('app.media.icon_location'))
            .width(12)
            .height(12)
            .margin({ right: 4 })

          Text(museum.location)
            .fontSize(12)
            .fontColor('#99182431')
            .layoutWeight(1)

          Text(museum.distance)
            .fontSize(12)
            .fontColor('#99182431')
        }
        .width('100%')
        .margin({ bottom: 8 })

        // 标签和价格
        Row() {
          Row() {
            ForEach(museum.tags.slice(0, 2), (tag: string) => {
              Text(tag)
                .fontSize(10)
                .fontColor('#007DFF')
                .backgroundColor('#E6F2FF')
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .borderRadius(4)
                .margin({ right: 4 })
            })
          }
          .layoutWeight(1)

          Text(museum.price === 0 ? '免费' : `¥${museum.price}`)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(museum.price === 0 ? '#00C853' : '#FF6B35')
        }
        .width('100%')
      }
      .padding(12)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .onClick(() => {
      this.navigateToDetail(museum);
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

        Text('博物馆列表')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#182431')

        Blank()

        Button() {
          Image($r('app.media.icon_search'))
            .width(24)
            .height(24)
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      Column() {
        // 搜索框
        Row() {
          TextInput({ placeholder: '搜索博物馆名称或地点' })
            .layoutWeight(1)
            .height(40)
            .backgroundColor('#F5F5F5')
            .borderRadius(20)
            .fontSize(14)
            .onChange((value: string) => {
              this.searchText = value;
            })

          Button('搜索')
            .height(40)
            .backgroundColor('#007DFF')
            .borderRadius(20)
            .fontSize(14)
            .margin({ left: 12 })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 16 })

        // 分类筛选
        Scroll(Scroller()) {
          Row() {
            ForEach(this.categories, (category: string) => {
              Button(category)
                .height(32)
                .backgroundColor(this.selectedCategory === category ? '#007DFF' : '#F5F5F5')
                .fontColor(this.selectedCategory === category ? '#FFFFFF' : '#182431')
                .fontSize(12)
                .borderRadius(16)
                .margin({ right: 8 })
                .onClick(() => {
                  this.selectedCategory = category;
                })
            })
          }
          .padding({ left: 16, right: 16 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .margin({ bottom: 16 })

        // 博物馆列表
        List() {
          ForEach(this.getFilteredMuseums(), (museum: Museum) => {
            ListItem() {
              this.MuseumCard(museum)
            }
            .margin({ bottom: 12 })
          })
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16 })
        .scrollBar(BarState.Auto)

        // 底部提示
        if (this.getFilteredMuseums().length === 0) {
          Column() {
            Image($r('app.media.icon_empty'))
              .width(80)
              .height(80)
              .margin({ bottom: 16 })

            Text('暂无符合条件的博物馆')
              .fontSize(16)
              .fontColor('#99182431')
          }
          .width('100%')
          .height(200)
          .justifyContent(FlexAlign.Center)
        }
      }
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
  }
}