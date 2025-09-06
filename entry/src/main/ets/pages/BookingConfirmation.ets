import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { BookingRecord, BookingService } from '../common/services/BookingService';
import { ReminderService, ReminderInfo } from '../common/services/ReminderService';
import { DateUtils } from '../common/utils/DateUtils';
import { AppConstants } from '../common/constants/AppConstants';

@Entry
@ComponentV2
struct BookingConfirmation {
  @Local booking: BookingRecord | null = null;
  @Local reminders: ReminderInfo[] = [];
  @Local isLoading: boolean = false;
  @Local showQRCode: boolean = false;
  
  private bookingService: BookingService = BookingService.getInstance();
  private reminderService: ReminderService = ReminderService.getInstance();

  aboutToAppear() {
    const params = router.getParams() as { booking: BookingRecord };
    if (params && params.booking) {
      this.booking = params.booking;
      this.loadReminders();
    } else {
      // 如果没有预约信息，返回上一页
      router.back();
    }
  }

  loadReminders() {
    if (this.booking) {
      this.reminders = this.reminderService.getBookingReminders(this.booking.id);
    }
  }

  formatDate(dateStr: string): string {
    return DateUtils.formatDateChinese(dateStr);
  }

  formatDateTime(timeStr: string): string {
    return DateUtils.formatDateTime(timeStr);
  }

  generateQRCodeData(): string {
    if (!this.booking) return '';
    
    return JSON.stringify({
      bookingId: this.booking.id,
      museum: this.booking.museum.name,
      date: this.booking.date,
      time: this.booking.timeSlot.time,
      visitor: this.booking.visitorName,
      count: this.booking.visitorCount
    });
  }

  async shareBooking() {
    if (!this.booking) return;

    const shareText = `我已预约${this.booking.museum.name}
参观时间：${this.formatDate(this.booking.date)} ${this.booking.timeSlot.time}
参观人数：${this.booking.visitorCount}人
预约号：${this.booking.id}`;

    try {
      // 这里可以集成系统分享API
      promptAction.showToast({
        message: '分享功能开发中',
        duration: 2000
      });
    } catch (error) {
      promptAction.showToast({
        message: '分享失败',
        duration: 2000
      });
    }
  }

  async addToCalendar() {
    if (!this.booking) return;

    try {
      // 这里可以集成系统日历API
      promptAction.showToast({
        message: '已添加到日历',
        duration: 2000
      });
    } catch (error) {
      promptAction.showToast({
        message: '添加日历失败',
        duration: 2000
      });
    }
  }

  goToBookingHistory() {
    router.replaceUrl({
      url: 'pages/BookingHistory'
    });
  }

  goToMuseumDetail() {
    if (this.booking) {
      router.pushUrl({
        url: 'pages/MuseumDetail',
        params: { museum: this.booking.museum }
      });
    }
  }

  @Builder
  SuccessHeader() {
    Column() {
      // 成功图标
      Stack() {
        Circle({ width: 80, height: 80 })
          .fill('#E8F5E8')
        
        Image($r('app.media.icon'))
          .width(40)
          .height(40)
          .fillColor('#00C853')
      }
      .margin({ bottom: 16 })

      Text('预约成功！')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#182431')
        .margin({ bottom: 8 })

      Text('您的预约已确认，请按时参观')
        .fontSize(14)
        .fontColor('#99182431')
        .margin({ bottom: 24 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  BookingDetails() {
    Column() {
      Text('预约详情')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#182431')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 16 })

      // 博物馆信息
      Row() {
        Image($r('app.media.icon'))
          .width(60)
          .height(60)
          .objectFit(ImageFit.Cover)
          .borderRadius(8)
          .margin({ right: 12 })

        Column() {
          Text(this.booking?.museum.name || '')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#182431')
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 4 })

          Text(this.booking?.museum.location || '')
            .fontSize(12)
            .fontColor('#99182431')
            .alignSelf(ItemAlign.Start)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Button('查看详情')
          .height(32)
          .backgroundColor('#F5F5F5')
          .fontColor('#007DFF')
          .fontSize(12)
          .onClick(() => {
            this.goToMuseumDetail();
          })
      }
      .width('100%')
      .margin({ bottom: 20 })

      // 预约信息
      Column() {
        this.DetailRow('预约号', this.booking?.id || '')
        this.DetailRow('参观日期', this.formatDate(this.booking?.date || ''))
        this.DetailRow('参观时间', this.booking?.timeSlot.time || '')
        this.DetailRow('参观人数', `${this.booking?.visitorCount || 0}人`)
        this.DetailRow('参观者', this.booking?.visitorName || '')
        this.DetailRow('联系电话', this.booking?.visitorPhone || '')
        this.DetailRow('预约时间', this.formatDateTime(this.booking?.bookingTime || ''))
        
        Divider()
          .margin({ top: 12, bottom: 12 })

        Row() {
          Text('总费用')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#182431')

          Blank()

          Text(this.booking?.totalPrice === 0 ? '免费' : `¥${this.booking?.totalPrice || 0}`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.booking?.totalPrice === 0 ? '#00C853' : '#FF6B35')
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 16 })
  }

  @Builder
  DetailRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#99182431')
        .width(80)

      Text(value)
        .fontSize(14)
        .fontColor('#182431')
        .layoutWeight(1)
    }
    .width('100%')
    .margin({ bottom: 12 })
  }

  @Builder
  QRCodeSection() {
    Column() {
      Row() {
        Text('电子凭证')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#182431')

        Blank()

        Button(this.showQRCode ? '收起' : '展开')
          .height(28)
          .backgroundColor('#F5F5F5')
          .fontColor('#007DFF')
          .fontSize(12)
          .onClick(() => {
            this.showQRCode = !this.showQRCode;
          })
      }
      .width('100%')
      .margin({ bottom: 12 })

      if (this.showQRCode) {
        Column() {
          // 模拟二维码
          Stack() {
            Rect({ width: 120, height: 120 })
              .fill('#F5F5F5')
              .borderRadius(8)
            
            Text('QR')
              .fontSize(20)
              .fontColor('#99182431')
          }
          .margin({ bottom: 12 })

          Text('请在参观时出示此二维码')
            .fontSize(12)
            .fontColor('#99182431')
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 16 })
  }

  @Builder
  ReminderSection() {
    if (this.reminders.length > 0) {
      Column() {
        Text('提醒设置')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#182431')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 12 })

        ForEach(this.reminders, (reminder: ReminderInfo) => {
          Row() {
            Circle({ width: 8, height: 8 })
              .fill(reminder.isActive ? '#00C853' : '#99182431')
              .margin({ right: 8 })

            Column() {
              Text(reminder.title)
                .fontSize(14)
                .fontColor('#182431')
                .alignSelf(ItemAlign.Start)

              Text(reminder.message)
                .fontSize(12)
                .fontColor('#99182431')
                .alignSelf(ItemAlign.Start)
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .margin({ bottom: 8 })
        })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .margin({ bottom: 16 })
    }
  }

  @Builder
  ActionButtons() {
    Column() {
      // 主要操作按钮
      Row() {
        Button('分享预约')
          .layoutWeight(1)
          .height(48)
          .backgroundColor('#FFFFFF')
          .fontColor('#007DFF')
          .borderWidth(1)
          .borderColor('#007DFF')
          .borderRadius(8)
          .margin({ right: 8 })
          .onClick(() => {
            this.shareBooking();
          })

        Button('添加日历')
          .layoutWeight(1)
          .height(48)
          .backgroundColor('#007DFF')
          .fontColor('#FFFFFF')
          .borderRadius(8)
          .margin({ left: 8 })
          .onClick(() => {
            this.addToCalendar();
          })
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 次要操作按钮
      Button('查看所有预约')
        .width('100%')
        .height(48)
        .backgroundColor('#F5F5F5')
        .fontColor('#182431')
        .borderRadius(8)
        .onClick(() => {
          this.goToBookingHistory();
        })
    }
    .width('100%')
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

        Text('预约确认')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#182431')

        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      if (this.booking) {
        Scroll() {
          Column() {
            this.SuccessHeader()
            this.BookingDetails()
            this.QRCodeSection()
            this.ReminderSection()
            this.ActionButtons()
          }
          .width('100%')
          .padding(16)
        }
        .layoutWeight(1)
        .backgroundColor('#F5F5F5')
      } else {
        // 加载状态或错误状态
        Column() {
          Text('加载中...')
            .fontSize(16)
            .fontColor('#99182431')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F5F5F5')
      }
    }
    .width('100%')
    .height('100%')
  }
}