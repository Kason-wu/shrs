import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

interface BookingRecord {
  id: string;
  museum: any;
  date: string;
  timeSlot: any;
  visitorCount: number;
  visitorName: string;
  visitorPhone: string;
  totalPrice: number;
  status: string; // 'confirmed', 'cancelled', 'completed'
  bookingTime: string;
}

@Entry
@Component
struct BookingHistory {
  @State bookings: BookingRecord[] = [];
  @State currentTab: number = 0; // 0: 全部, 1: 待参观, 2: 已完成, 3: 已取消
  @State tabs: string[] = ['全部', '待参观', '已完成', '已取消'];

  aboutToAppear() {
    this.loadBookings();
  }

  loadBookings() {
    // 从本地存储加载预约记录
    const savedBookings = AppStorage.Get('userBookings') as BookingRecord[] || [];
    
    // 添加一些示例数据（如果没有真实数据）
    if (savedBookings.length === 0) {
      const sampleBookings: BookingRecord[] = [
        {
          id: '1',
          museum: {
            id: 1,
            name: '国家博物馆',
            location: '北京市东城区',
            image: 'museum1.jpg'
          },
          date: '2024-09-15',
          timeSlot: { time: '09:00-10:00' },
          visitorCount: 2,
          visitorName: '张三',
          visitorPhone: '138****8888',
          totalPrice: 0,
          status: 'confirmed',
          bookingTime: '2024-09-01T10:30:00Z'
        },
        {
          id: '2',
          museum: {
            id: 2,
            name: '故宫博物院',
            location: '北京市东城区',
            image: 'museum2.jpg'
          },
          date: '2024-08-20',
          timeSlot: { time: '14:00-15:00' },
          visitorCount: 1,
          visitorName: '张三',
          visitorPhone: '138****8888',
          totalPrice: 60,
          status: 'completed',
          bookingTime: '2024-08-15T14:20:00Z'
        },
        {
          id: '3',
          museum: {
            id: 3,
            name: '中国科技馆',
            location: '北京市朝阳区',
            image: 'museum3.jpg'
          },
          date: '2024-07-10',
          timeSlot: { time: '10:00-11:00' },
          visitorCount: 3,
          visitorName: '张三',
          visitorPhone: '138****8888',
          totalPrice: 90,
          status: 'cancelled',
          bookingTime: '2024-07-05T09:15:00Z'
        }
      ];
      this.bookings = sampleBookings;
    } else {
      this.bookings = savedBookings;
    }
  }

  getFilteredBookings(): BookingRecord[] {
    if (this.currentTab === 0) {
      return this.bookings;
    } else if (this.currentTab === 1) {
      return this.bookings.filter(booking => booking.status === 'confirmed');
    } else if (this.currentTab === 2) {
      return this.bookings.filter(booking => booking.status === 'completed');
    } else if (this.currentTab === 3) {
      return this.bookings.filter(booking => booking.status === 'cancelled');
    }
    return [];
  }

  getStatusText(status: string): string {
    switch (status) {
      case 'confirmed':
        return '待参观';
      case 'completed':
        return '已完成';
      case 'cancelled':
        return '已取消';
      default:
        return '未知';
    }
  }

  getStatusColor(status: string): string {
    switch (status) {
      case 'confirmed':
        return '#007DFF';
      case 'completed':
        return '#00C853';
      case 'cancelled':
        return '#99182431';
      default:
        return '#99182431';
    }
  }

  formatDate(dateStr: string): string {
    const date = new Date(dateStr);
    const month = date.getMonth() + 1;
    const day = date.getDate();
    const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    const weekday = weekdays[date.getDay()];
    return `${month}月${day}日 ${weekday}`;
  }

  formatBookingTime(timeStr: string): string {
    const date = new Date(timeStr);
    const month = date.getMonth() + 1;
    const day = date.getDate();
    const hours = date.getHours();
    const minutes = date.getMinutes();
    return `${month}月${day}日 ${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}`;
  }

  cancelBooking(booking: BookingRecord) {
    if (booking.status !== 'confirmed') {
      return;
    }

    promptAction.showDialog({
      title: '取消预约',
      message: '确定要取消这个预约吗？取消后不可恢复。',
      buttons: [
        {
          text: '取消',
          color: '#99182431'
        },
        {
          text: '确定',
          color: '#FF3B30'
        }
      ]
    }).then((result) => {
      if (result.index === 1) {
        // 更新预约状态
        const index = this.bookings.findIndex(b => b.id === booking.id);
        if (index !== -1) {
          this.bookings[index].status = 'cancelled';
          
          // 保存到本地存储
          AppStorage.SetOrCreate('userBookings', this.bookings);
          
          promptAction.showToast({
            message: '预约已取消',
            duration: 2000
          });
        }
      }
    });
  }

  rebookMuseum(booking: BookingRecord) {
    router.pushUrl({
      url: 'pages/BookingPage',
      params: { museum: booking.museum }
    });
  }

  @Builder
  BookingCard(booking: BookingRecord) {
    Column() {
      // 博物馆信息
      Row() {
        Image($r('app.media.icon'))
          .width(60)
          .height(60)
          .objectFit(ImageFit.Cover)
          .borderRadius(8)
          .margin({ right: 12 })

        Column() {
          Text(booking.museum.name)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#182431')
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 4 })

          Text(booking.museum.location)
            .fontSize(12)
            .fontColor('#99182431')
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 4 })

          Text(`预约时间：${this.formatBookingTime(booking.bookingTime)}`)
            .fontSize(12)
            .fontColor('#99182431')
            .alignSelf(ItemAlign.Start)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Text(this.getStatusText(booking.status))
          .fontSize(12)
          .fontColor(this.getStatusColor(booking.status))
          .backgroundColor(booking.status === 'confirmed' ? '#E6F2FF' : 
                          booking.status === 'completed' ? '#E8F5E8' : '#F5F5F5')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(4)
      }
      .width('100%')
      .margin({ bottom: 12 })

      Divider()
        .color('#F5F5F5')
        .margin({ bottom: 12 })

      // 预约详情
      Column() {
        Row() {
          Text('参观日期')
            .fontSize(14)
            .fontColor('#99182431')
            .width(80)

          Text(this.formatDate(booking.date))
            .fontSize(14)
            .fontColor('#182431')
            .layoutWeight(1)
        }
        .width('100%')
        .margin({ bottom: 8 })

        Row() {
          Text('参观时间')
            .fontSize(14)
            .fontColor('#99182431')
            .width(80)

          Text(booking.timeSlot.time)
            .fontSize(14)
            .fontColor('#182431')
            .layoutWeight(1)
        }
        .width('100%')
        .margin({ bottom: 8 })

        Row() {
          Text('参观人数')
            .fontSize(14)
            .fontColor('#99182431')
            .width(80)

          Text(`${booking.visitorCount}人`)
            .fontSize(14)
            .fontColor('#182431')
            .layoutWeight(1)
        }
        .width('100%')
        .margin({ bottom: 8 })

        Row() {
          Text('参观者')
            .fontSize(14)
            .fontColor('#99182431')
            .width(80)

          Text(booking.visitorName)
            .fontSize(14)
            .fontColor('#182431')
            .layoutWeight(1)
        }
        .width('100%')
        .margin({ bottom: 8 })

        Row() {
          Text('费用')
            .fontSize(14)
            .fontColor('#99182431')
            .width(80)

          Text(booking.totalPrice === 0 ? '免费' : `¥${booking.totalPrice}`)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(booking.totalPrice === 0 ? '#00C853' : '#FF6B35')
            .layoutWeight(1)
        }
        .width('100%')
      }
      .margin({ bottom: 16 })

      // 操作按钮
      Row() {
        if (booking.status === 'confirmed') {
          Button('取消预约')
            .height(32)
            .backgroundColor('#FFFFFF')
            .fontColor('#FF3B30')
            .borderWidth(1)
            .borderColor('#FF3B30')
            .borderRadius(16)
            .fontSize(12)
            .margin({ right: 8 })
            .onClick(() => {
              this.cancelBooking(booking);
            })

          Button('查看详情')
            .height(32)
            .backgroundColor('#007DFF')
            .fontColor('#FFFFFF')
            .borderRadius(16)
            .fontSize(12)
            .onClick(() => {
              router.pushUrl({
                url: 'pages/MuseumDetail',
                params: { museum: booking.museum }
              });
            })
        } else if (booking.status === 'completed') {
          Button('再次预约')
            .height(32)
            .backgroundColor('#007DFF')
            .fontColor('#FFFFFF')
            .borderRadius(16)
            .fontSize(12)
            .onClick(() => {
              this.rebookMuseum(booking);
            })
        } else if (booking.status === 'cancelled') {
          Button('重新预约')
            .height(32)
            .backgroundColor('#007DFF')
            .fontColor('#FFFFFF')
            .borderRadius(16)
            .fontSize(12)
            .onClick(() => {
              this.rebookMuseum(booking);
            })
        }

        Blank()
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 12 })
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

        Text('预约记录')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#182431')

        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      Column() {
        // 标签页
        Row() {
          ForEach(this.tabs, (tab: string, index: number) => {
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

        // 预约列表
        if (this.getFilteredBookings().length > 0) {
          List() {
            ForEach(this.getFilteredBookings(), (booking: BookingRecord) => {
              ListItem() {
                this.BookingCard(booking)
              }
            })
          }
          .width('100%')
          .layoutWeight(1)
          .padding({ left: 16, right: 16, top: 16 })
          .scrollBar(BarState.Auto)
        } else {
          // 空状态
          Column() {
            Image($r('app.media.icon'))
              .width(80)
              .height(80)
              .margin({ bottom: 16 })

            Text('暂无预约记录')
              .fontSize(16)
              .fontColor('#99182431')
              .margin({ bottom: 8 })

            Text('快去预约心仪的博物馆吧')
              .fontSize(14)
              .fontColor('#99182431')
              .margin({ bottom: 24 })

            Button('去预约')
              .height(40)
              .backgroundColor('#007DFF')
              .fontColor('#FFFFFF')
              .borderRadius(20)
              .fontSize(14)
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/MuseumList'
                });
              })
          }
          .width('100%')
          .layoutWeight(1)
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