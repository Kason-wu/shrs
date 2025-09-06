import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { BookingService, BookingRecord, BookingStatus, BookingStatistics } from '../common/services/BookingService';
import { DateUtils } from '../common/utils/DateUtils';
import { BookingFilter } from '../common/components/BookingFilter';

@Entry
@ComponentV2
struct BookingHistory {
  @Local bookings: BookingRecord[] = [];
  @Local filteredBookings: BookingRecord[] = [];
  @Local currentTab: number = 0; // 0: 全部, 1: 待参观, 2: 已完成, 3: 已取消
  @Local tabs: string[] = ['全部', '待参观', '已完成', '已取消'];
  @Local statistics: BookingStatistics | null = null;
  @Local showStatistics: boolean = false;
  @Local showFilter: boolean = false;
  
  private bookingService: BookingService = BookingService.getInstance();

  aboutToAppear() {
    this.loadBookings();
    this.loadStatistics();
    // 清理过期预约
    this.bookingService.cleanupExpiredBookings();
  }

  loadBookings() {
    this.bookings = this.bookingService.getAllBookings();
    this.filteredBookings = this.getFilteredBookings();
  }

  loadStatistics() {
    this.statistics = this.bookingService.getBookingStatistics();
  }

  getFilteredBookings(): BookingRecord[] {
    if (this.currentTab === 0) {
      return this.bookings;
    } else if (this.currentTab === 1) {
      return this.bookingService.getBookingsByStatus(BookingStatus.CONFIRMED);
    } else if (this.currentTab === 2) {
      return this.bookingService.getBookingsByStatus(BookingStatus.COMPLETED);
    } else if (this.currentTab === 3) {
      return this.bookingService.getBookingsByStatus(BookingStatus.CANCELLED);
    }
    return [];
  }

  onFilterChange = (filtered: BookingRecord[]) => {
    this.filteredBookings = filtered;
  }

  onTabChange(index: number) {
    this.currentTab = index;
    this.filteredBookings = this.getFilteredBookings();
  }

  getStatusText(status: BookingStatus): string {
    switch (status) {
      case BookingStatus.CONFIRMED:
        return '待参观';
      case BookingStatus.COMPLETED:
        return '已完成';
      case BookingStatus.CANCELLED:
        return '已取消';
      case BookingStatus.PENDING:
        return '处理中';
      default:
        return '未知';
    }
  }

  getStatusColor(status: BookingStatus): string {
    switch (status) {
      case BookingStatus.CONFIRMED:
        return '#007DFF';
      case BookingStatus.COMPLETED:
        return '#00C853';
      case BookingStatus.CANCELLED:
        return '#99182431';
      case BookingStatus.PENDING:
        return '#FF9500';
      default:
        return '#99182431';
    }
  }

  formatDate(dateStr: string): string {
    return DateUtils.formatDateChinese(dateStr);
  }

  formatBookingTime(timeStr: string): string {
    return DateUtils.formatDateTime(timeStr);
  }

  async cancelBooking(booking: BookingRecord) {
    if (booking.status !== BookingStatus.CONFIRMED) {
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
    }).then(async (result) => {
      if (result.index === 1) {
        const cancelResult = await this.bookingService.cancelBooking(booking.id);
        
        if (cancelResult.success) {
          promptAction.showToast({
            message: '预约已取消',
            duration: 2000
          });
          // 重新加载数据
          this.loadBookings();
          this.loadStatistics();
        } else {
          promptAction.showToast({
            message: cancelResult.error || '取消失败，请重试',
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
  StatisticsCard() {
    if (this.statistics) {
      Column() {
        Row() {
          Text('预约统计')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#182431')
          
          Blank()
          
          Button(this.showStatistics ? '收起' : '展开')
            .height(28)
            .backgroundColor('#F5F5F5')
            .fontColor('#007DFF')
            .fontSize(12)
            .onClick(() => {
              this.showStatistics = !this.showStatistics;
            })
        }
        .width('100%')
        .margin({ bottom: 12 })

        if (this.showStatistics) {
          Column() {
            // 预约数量统计
            Row() {
              Column() {
                Text(this.statistics.totalBookings.toString())
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#007DFF')
                Text('总预约')
                  .fontSize(12)
                  .fontColor('#99182431')
              }
              .layoutWeight(1)

              Column() {
                Text(this.statistics.confirmedBookings.toString())
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FF9500')
                Text('待参观')
                  .fontSize(12)
                  .fontColor('#99182431')
              }
              .layoutWeight(1)

              Column() {
                Text(this.statistics.completedBookings.toString())
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#00C853')
                Text('已完成')
                  .fontSize(12)
                  .fontColor('#99182431')
              }
              .layoutWeight(1)

              Column() {
                Text(`¥${this.statistics.totalSpent}`)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FF6B35')
                Text('总消费')
                  .fontSize(12)
                  .fontColor('#99182431')
              }
              .layoutWeight(1)
            }
            .width('100%')
            .margin({ bottom: 16 })

            // 常访问博物馆
            if (this.statistics.favoriteMuseums.length > 0) {
              Column() {
                Text('常访问博物馆')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#182431')
                  .alignSelf(ItemAlign.Start)
                  .margin({ bottom: 8 })

                ForEach(this.statistics.favoriteMuseums, (museum: string, index: number) => {
                  Row() {
                    Text(`${index + 1}. ${museum}`)
                      .fontSize(12)
                      .fontColor('#99182431')
                  }
                  .width('100%')
                  .margin({ bottom: 4 })
                })
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
            }
          }
          .width('100%')
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .margin({ bottom: 12 })
    }
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
        if (booking.status === BookingStatus.CONFIRMED) {
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
        } else if (booking.status === BookingStatus.COMPLETED) {
          Button('再次预约')
            .height(32)
            .backgroundColor('#007DFF')
            .fontColor('#FFFFFF')
            .borderRadius(16)
            .fontSize(12)
            .onClick(() => {
              this.rebookMuseum(booking);
            })
        } else if (booking.status === BookingStatus.CANCELLED) {
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

        Button() {
          Image($r('app.media.icon'))
            .width(20)
            .height(20)
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.showFilter = !this.showFilter;
        })
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
                this.onTabChange(index);
              })
          })
        }
        .width('100%')
        .backgroundColor('#FFFFFF')

        // 筛选组件
        if (this.showFilter) {
          BookingFilter({
            bookings: this.getFilteredBookings(),
            onFilterChange: this.onFilterChange
          })
        }

        // 预约列表
        if (this.filteredBookings.length > 0) {
          List() {
            // 统计卡片（仅在全部标签页显示）
            if (this.currentTab === 0) {
              ListItem() {
                this.StatisticsCard()
              }
            }
            
            ForEach(this.filteredBookings, (booking: BookingRecord) => {
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