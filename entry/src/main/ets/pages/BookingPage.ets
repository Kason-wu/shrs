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

interface TimeSlot {
  id: string;
  time: string;
  available: number;
  total: number;
}

interface BookingInfo {
  museum: Museum;
  date: string;
  timeSlot: TimeSlot;
  visitorCount: number;
  visitorName: string;
  visitorPhone: string;
  visitorIdCard: string;
  totalPrice: number;
}

@Entry
@Component
struct BookingPage {
  @State museum: Museum = {
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

  @State selectedDate: string = '';
  @State selectedTimeSlot: TimeSlot | null = null;
  @State visitorCount: number = 1;
  @State visitorName: string = '';
  @State visitorPhone: string = '';
  @State visitorIdCard: string = '';
  @State currentStep: number = 0; // 0: 选择日期时间, 1: 填写信息, 2: 确认订单
  @State isLoading: boolean = false;

  @State availableDates: string[] = [];
  @State timeSlots: TimeSlot[] = [
    { id: '1', time: '09:00-10:00', available: 45, total: 50 },
    { id: '2', time: '10:00-11:00', available: 32, total: 50 },
    { id: '3', time: '11:00-12:00', available: 28, total: 50 },
    { id: '4', time: '14:00-15:00', available: 38, total: 50 },
    { id: '5', time: '15:00-16:00', available: 41, total: 50 },
    { id: '6', time: '16:00-17:00', available: 35, total: 50 }
  ];

  aboutToAppear() {
    const params = router.getParams() as { museum: Museum };
    if (params && params.museum) {
      this.museum = params.museum;
    }
    this.generateAvailableDates();
  }

  generateAvailableDates() {
    const dates: string[] = [];
    const today = new Date();
    
    for (let i = 1; i <= 30; i++) {
      const date = new Date(today);
      date.setDate(today.getDate() + i);
      const dateStr = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
      dates.push(dateStr);
    }
    
    this.availableDates = dates;
  }

  formatDate(dateStr: string): string {
    const date = new Date(dateStr);
    const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    const month = date.getMonth() + 1;
    const day = date.getDate();
    const weekday = weekdays[date.getDay()];
    return `${month}月${day}日 ${weekday}`;
  }

  getTotalPrice(): number {
    return this.museum.price * this.visitorCount;
  }

  validateForm(): boolean {
    if (!this.visitorName.trim()) {
      promptAction.showToast({ message: '请输入参观者姓名', duration: 2000 });
      return false;
    }
    
    if (!this.visitorPhone.trim() || !/^1[3-9]\d{9}$/.test(this.visitorPhone)) {
      promptAction.showToast({ message: '请输入有效的手机号码', duration: 2000 });
      return false;
    }
    
    if (!this.visitorIdCard.trim() || !/^\d{17}[\dXx]$/.test(this.visitorIdCard)) {
      promptAction.showToast({ message: '请输入有效的身份证号码', duration: 2000 });
      return false;
    }
    
    return true;
  }

  async submitBooking() {
    this.isLoading = true;
    
    // 模拟提交预约
    setTimeout(() => {
      this.isLoading = false;
      
      // 保存预约记录到本地存储
      const bookingRecord = {
        id: Date.now().toString(),
        museum: this.museum,
        date: this.selectedDate,
        timeSlot: this.selectedTimeSlot,
        visitorCount: this.visitorCount,
        visitorName: this.visitorName,
        visitorPhone: this.visitorPhone,
        totalPrice: this.getTotalPrice(),
        status: 'confirmed',
        bookingTime: new Date().toISOString()
      };
      
      // 获取现有预约记录
      const existingBookings = AppStorage.Get('userBookings') as any[] || [];
      existingBookings.push(bookingRecord);
      AppStorage.SetOrCreate('userBookings', existingBookings);
      
      promptAction.showToast({
        message: '预约成功！',
        duration: 2000
      });
      
      // 跳转到预约历史页面
      router.replaceUrl({
        url: 'pages/BookingHistory'
      });
    }, 2000);
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
                  if (slot.available > 0) {
                    this.selectedTimeSlot = slot;
                  }
                })
                .enabled(slot.available > 0)
                .opacity(slot.available > 0 ? 1 : 0.5)
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