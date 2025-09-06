import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { BookingService, Museum, TimeSlot, BookingRecord } from '../common/services/BookingService';
import { DateUtils } from '../common/utils/DateUtils';
import { ValidationUtils } from '../common/utils/ValidationUtils';
import { AppConstants } from '../common/constants/AppConstants';

@Entry
@ComponentV2
struct BookingPage {
  @Local museum: Museum = {
    id: 1,
    name: '国家博物馆',
    description: '中国历史文化的重要展示窗口',
    image: 'museum1.jpg',
    location: '北京市东城区',
    rating: 4.8,
    price: 0,
    openTime: '09:00-17:00',
    tags: ['历史', '文物', '免费'],
    distance: '2.3km'
  };

  @Local selectedDate: string = '';
  @Local selectedTimeSlot: TimeSlot | null = null;
  @Local visitorCount: number = 1;
  @Local visitorName: string = '';
  @Local visitorPhone: string = '';
  @Local visitorIdCard: string = '';
  @Local currentStep: number = 0; // 0: 选择日期时间, 1: 填写信息, 2: 确认订单
  @Local isLoading: boolean = false;
  @Local validationErrors: string[] = [];
  @Local validationWarnings: string[] = [];

  @Local availableDates: string[] = [];
  @Local timeSlots: TimeSlot[] = [];
  
  private bookingService: BookingService = BookingService.getInstance();

  aboutToAppear() {
    const params = router.getParams() as { museum: Museum };
    if (params && params.museum) {
      this.museum = params.museum;
    }
    this.generateAvailableDates();
    this.loadTimeSlots();
  }

  generateAvailableDates() {
    this.availableDates = DateUtils.getFutureDates(AppConstants.BOOKING_ADVANCE_DAYS);
  }

  loadTimeSlots() {
    if (this.selectedDate) {
      this.timeSlots = this.bookingService.getAvailableTimeSlots(this.museum.id, this.selectedDate);
    }
  }

  formatDate(dateStr: string): string {
    return DateUtils.formatDateChinese(dateStr);
  }

  getTotalPrice(): number {
    return this.museum.price * this.visitorCount;
  }

  validateForm(): boolean {
    this.validationErrors = [];
    this.validationWarnings = [];

    // 验证参观者信息
    if (!ValidationUtils.validateName(this.visitorName)) {
      this.validationErrors.push('请输入有效的参观者姓名');
    }
    
    if (!ValidationUtils.validatePhone(this.visitorPhone)) {
      this.validationErrors.push('请输入有效的手机号码');
    }
    
    if (!ValidationUtils.validateIdCard(this.visitorIdCard)) {
      this.validationErrors.push('请输入有效的身份证号码');
    }

    // 检查预约冲突
    if (this.selectedTimeSlot && this.bookingService.hasConflictingBooking(this.selectedDate, this.selectedTimeSlot)) {
      this.validationErrors.push('您在该时间段已有预约');
    }

    // 显示错误信息
    if (this.validationErrors.length > 0) {
      promptAction.showToast({ 
        message: this.validationErrors[0], 
        duration: 2000 
      });
      return false;
    }
    
    return true;
  }

  async submitBooking() {
    if (!this.selectedTimeSlot) {
      promptAction.showToast({ message: '请选择时间段', duration: 2000 });
      return;
    }

    this.isLoading = true;
    
    try {
      // 创建预约数据
      const bookingData = {
        museum: this.museum,
        date: this.selectedDate,
        timeSlot: this.selectedTimeSlot,
        visitorCount: this.visitorCount,
        visitorName: this.visitorName,
        visitorPhone: this.visitorPhone,
        visitorIdCard: this.visitorIdCard,
        totalPrice: this.getTotalPrice()
      };

      // 使用预约服务创建预约
      const result = await this.bookingService.createBooking(bookingData);
      
      this.isLoading = false;
      
      if (result.success) {
        promptAction.showToast({
          message: '预约成功！',
          duration: 2000
        });
        
        // 跳转到预约确认页面
        router.replaceUrl({
          url: 'pages/BookingConfirmation',
          params: { booking: result.booking }
        });
      } else {
        promptAction.showToast({
          message: result.error || '预约失败，请重试',
          duration: 2000
        });
      }
    } catch (error) {
      this.isLoading = false;
      promptAction.showToast({
        message: '预约失败，请重试',
        duration: 2000
      });
    }
  }

  @Builder
  StepIndicator() {
    Row() {
      ForEach([0, 1, 2], (step: number) => {
        Row() {
          Circle({ width: 24, height: 24 })
            .fill(this.currentStep >= step ? '#007DFF' : '#E5E5E5')
            .stroke(this.currentStep >= step ? '#007DFF' : '#E5E5E5', 2)
          
          if (step < 2) {
            Line()
              .width(40)
              .height(2)
              .backgroundColor(this.currentStep > step ? '#007DFF' : '#E5E5E5')
              .margin({ left: 4, right: 4 })
          }
        }
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .margin({ bottom: 20 })
  }

  @Builder
  DateTimeSelection() {
    Column() {
      // 日期选择
      Column() {
        Text('选择参观日期')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#182431')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 12 })

        Grid() {
          ForEach(this.availableDates.slice(0, 14), (date: string) => {
            GridItem() {
              Column() {
                Text(this.formatDate(date))
                  .fontSize(12)
                  .fontColor(this.selectedDate === date ? '#FFFFFF' : '#182431')
                  .textAlign(TextAlign.Center)
              }
              .width('100%')
              .height(40)
              .backgroundColor(this.selectedDate === date ? '#007DFF' : '#F5F5F5')
              .borderRadius(8)
              .justifyContent(FlexAlign.Center)
              .onClick(() => {
                this.selectedDate = date;
                this.selectedTimeSlot = null;
                this.loadTimeSlots(); // 重新加载时间段
              })
            }
          })
        }
        .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
        .rowsTemplate('1fr 1fr')
        .columnsGap(8)
        .rowsGap(8)
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .margin({ bottom: 16 })

      // 时间段选择
      if (this.selectedDate) {
        Column() {
          Text('选择参观时间')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#182431')
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 12 })

          Grid() {
            ForEach(this.timeSlots, (slot: TimeSlot) => {
              GridItem() {
                Column() {
                  Text(slot.time)
                    .fontSize(14)
                    .fontColor(this.selectedTimeSlot?.id === slot.id ? '#FFFFFF' : '#182431')
                    .fontWeight(FontWeight.Medium)
                    .margin({ bottom: 4 })

                  Text(`余${slot.available}位`)
                    .fontSize(12)
                    .fontColor(this.selectedTimeSlot?.id === slot.id ? '#FFFFFF' : '#99182431')
                }
                .width('100%')
                .height(60)
                .backgroundColor(this.selectedTimeSlot?.id === slot.id ? '#007DFF' : '#F5F5F5')
                .borderRadius(8)
                .justifyContent(FlexAlign.Center)
                .onClick(() => {
                  if (slot.isAvailable && slot.available > 0) {
                    this.selectedTimeSlot = slot;
                  }
                })
                .enabled(slot.isAvailable && slot.available > 0)
                .opacity(slot.isAvailable && slot.available > 0 ? 1 : 0.5)
              }
            })
          }
          .columnsTemplate('1fr 1fr')
          .rowsTemplate('1fr 1fr 1fr')
          .columnsGap(12)
          .rowsGap(12)
          .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .margin({ bottom: 16 })
      }

      // 参观人数
      Column() {
        Text('参观人数')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#182431')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 12 })

        Row() {
          Button('-')
            .width(40)
            .height(40)
            .backgroundColor('#F5F5F5')
            .fontColor('#182431')
            .enabled(this.visitorCount > 1)
            .onClick(() => {
              if (this.visitorCount > 1) {
                this.visitorCount--;
              }
            })

          Text(this.visitorCount.toString())
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#182431')
            .width(60)
            .textAlign(TextAlign.Center)

          Button('+')
            .width(40)
            .height(40)
            .backgroundColor('#F5F5F5')
            .fontColor('#182431')
            .enabled(this.visitorCount < 6)
            .onClick(() => {
              if (this.visitorCount < 6) {
                this.visitorCount++;
              }
            })

          Blank()

          Text(`¥${this.getTotalPrice()}`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF6B35')
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
    }
    .width('100%')
  }

  @Builder
  VisitorInfoForm() {
    Column() {
      Column() {
        Text('参观者信息')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#182431')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 16 })

        // 姓名
        Column() {
          Text('姓名')
            .fontSize(14)
            .fontColor('#182431')
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 8 })

          TextInput({ placeholder: '请输入参观者姓名' })
            .width('100%')
            .height(48)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .onChange((value: string) => {
              this.visitorName = value;
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
            .type(InputType.PhoneNumber)
            .onChange((value: string) => {
              this.visitorPhone = value;
            })
        }
        .width('100%')
        .margin({ bottom: 16 })

        // 身份证号
        Column() {
          Text('身份证号')
            .fontSize(14)
            .fontColor('#182431')
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 8 })

          TextInput({ placeholder: '请输入身份证号码' })
            .width('100%')
            .height(48)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .onChange((value: string) => {
              this.visitorIdCard = value;
            })
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
    }
    .width('100%')
  }

  @Builder
  OrderConfirmation() {
    Column() {
      // 预约信息确认
      Column() {
        Text('预约信息确认')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#182431')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 16 })

        Column() {
          Row() {
            Text('博物馆')
              .fontSize(14)
              .fontColor('#99182431')
              .width(80)

            Text(this.museum.name)
              .fontSize(14)
              .fontColor('#182431')
              .layoutWeight(1)
          }
          .width('100%')
          .margin({ bottom: 12 })

          Row() {
            Text('参观日期')
              .fontSize(14)
              .fontColor('#99182431')
              .width(80)

            Text(this.formatDate(this.selectedDate))
              .fontSize(14)
              .fontColor('#182431')
              .layoutWeight(1)
          }
          .width('100%')
          .margin({ bottom: 12 })

          Row() {
            Text('参观时间')
              .fontSize(14)
              .fontColor('#99182431')
              .width(80)

            Text(this.selectedTimeSlot?.time || '')
              .fontSize(14)
              .fontColor('#182431')
              .layoutWeight(1)
          }
          .width('100%')
          .margin({ bottom: 12 })

          Row() {
            Text('参观人数')
              .fontSize(14)
              .fontColor('#99182431')
              .width(80)

            Text(`${this.visitorCount}人`)
              .fontSize(14)
              .fontColor('#182431')
              .layoutWeight(1)
          }
          .width('100%')
          .margin({ bottom: 12 })

          Row() {
            Text('参观者')
              .fontSize(14)
              .fontColor('#99182431')
              .width(80)

            Text(this.visitorName)
              .fontSize(14)
              .fontColor('#182431')
              .layoutWeight(1)
          }
          .width('100%')
          .margin({ bottom: 12 })

          Row() {
            Text('联系电话')
              .fontSize(14)
              .fontColor('#99182431')
              .width(80)

            Text(this.visitorPhone)
              .fontSize(14)
              .fontColor('#182431')
              .layoutWeight(1)
          }
          .width('100%')
          .margin({ bottom: 12 })

          Divider()
            .margin({ top: 8, bottom: 8 })

          Row() {
            Text('总费用')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#182431')
              .width(80)

            Text(`¥${this.getTotalPrice()}`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF6B35')
              .layoutWeight(1)
          }
          .width('100%')
        }
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
          if (this.currentStep > 0) {
            this.currentStep--;
          } else {
            router.back();
          }
        })

        Text('预约参观')
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
        // 步骤指示器
        this.StepIndicator()

        // 内容区域
        Scroll() {
          Column() {
            if (this.currentStep === 0) {
              this.DateTimeSelection()
            } else if (this.currentStep === 1) {
              this.VisitorInfoForm()
            } else if (this.currentStep === 2) {
              this.OrderConfirmation()
            }
          }
          .width('100%')
          .padding(16)
        }
        .layoutWeight(1)

        // 底部按钮
        Row() {
          if (this.currentStep < 2) {
            Button('下一步')
              .width('100%')
              .height(48)
              .backgroundColor('#007DFF')
              .borderRadius(8)
              .fontSize(16)
              .fontColor('#FFFFFF')
              .onClick(() => {
                if (this.currentStep === 0) {
                  if (!this.selectedDate || !this.selectedTimeSlot) {
                    promptAction.showToast({
                      message: '请选择参观日期和时间',
                      duration: 2000
                    });
                    return;
                  }
                  this.currentStep = 1;
                } else if (this.currentStep === 1) {
                  if (this.validateForm()) {
                    this.currentStep = 2;
                  }
                }
              })
          } else {
            Button(this.isLoading ? '提交中...' : '确认预约')
              .width('100%')
              .height(48)
              .backgroundColor('#007DFF')
              .borderRadius(8)
              .fontSize(16)
              .fontColor('#FFFFFF')
              .enabled(!this.isLoading)
              .onClick(() => {
                this.submitBooking();
              })
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
      }
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
  }
}