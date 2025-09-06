import { BookingRecord, BookingStatus } from '../services/BookingService';
import { DateUtils } from '../utils/DateUtils';

/**
 * 预约筛选条件接口
 */
export interface BookingFilterOptions {
  status?: BookingStatus[];
  dateRange?: {
    start: string;
    end: string;
  };
  museumName?: string;
  sortBy?: 'date' | 'bookingTime' | 'price';
  sortOrder?: 'asc' | 'desc';
}

/**
 * 预约筛选组件
 */
@ComponentV2
export struct BookingFilter {
  @Param bookings: BookingRecord[] = [];
  @Param onFilterChange: (filteredBookings: BookingRecord[]) => void = () => {};
  
  @Local showFilter: boolean = false;
  @Local filterOptions: BookingFilterOptions = {};
  @Local searchKeyword: string = '';

  /**
   * 应用筛选条件
   */
  applyFilter() {
    let filtered = [...this.bookings];

    // 关键词搜索
    if (this.searchKeyword.trim()) {
      const keyword = this.searchKeyword.toLowerCase();
      filtered = filtered.filter(booking => 
        booking.museum.name.toLowerCase().includes(keyword) ||
        booking.visitorName.toLowerCase().includes(keyword) ||
        booking.id.toLowerCase().includes(keyword)
      );
    }

    // 状态筛选
    if (this.filterOptions.status && this.filterOptions.status.length > 0) {
      filtered = filtered.filter(booking => 
        this.filterOptions.status!.includes(booking.status)
      );
    }

    // 日期范围筛选
    if (this.filterOptions.dateRange) {
      const { start, end } = this.filterOptions.dateRange;
      filtered = filtered.filter(booking => 
        booking.date >= start && booking.date <= end
      );
    }

    // 博物馆名称筛选
    if (this.filterOptions.museumName) {
      filtered = filtered.filter(booking => 
        booking.museum.name.includes(this.filterOptions.museumName!)
      );
    }

    // 排序
    if (this.filterOptions.sortBy) {
      filtered.sort((a, b) => {
        let valueA: any, valueB: any;
        
        switch (this.filterOptions.sortBy) {
          case 'date':
            valueA = new Date(`${a.date} ${a.timeSlot.time.split('-')[0]}`);
            valueB = new Date(`${b.date} ${b.timeSlot.time.split('-')[0]}`);
            break;
          case 'bookingTime':
            valueA = new Date(a.bookingTime);
            valueB = new Date(b.bookingTime);
            break;
          case 'price':
            valueA = a.totalPrice;
            valueB = b.totalPrice;
            break;
          default:
            return 0;
        }

        if (this.filterOptions.sortOrder === 'desc') {
          return valueB > valueA ? 1 : valueB < valueA ? -1 : 0;
        } else {
          return valueA > valueB ? 1 : valueA < valueB ? -1 : 0;
        }
      });
    }

    this.onFilterChange(filtered);
  }

  /**
   * 重置筛选条件
   */
  resetFilter() {
    this.filterOptions = {};
    this.searchKeyword = '';
    this.onFilterChange(this.bookings);
  }

  /**
   * 切换状态筛选
   */
  toggleStatusFilter(status: BookingStatus) {
    if (!this.filterOptions.status) {
      this.filterOptions.status = [];
    }
    
    const index = this.filterOptions.status.indexOf(status);
    if (index > -1) {
      this.filterOptions.status.splice(index, 1);
    } else {
      this.filterOptions.status.push(status);
    }
    
    this.applyFilter();
  }

  /**
   * 设置日期范围
   */
  setDateRange(start: string, end: string) {
    this.filterOptions.dateRange = { start, end };
    this.applyFilter();
  }

  /**
   * 设置排序方式
   */
  setSorting(sortBy: 'date' | 'bookingTime' | 'price', sortOrder: 'asc' | 'desc') {
    this.filterOptions.sortBy = sortBy;
    this.filterOptions.sortOrder = sortOrder;
    this.applyFilter();
  }

  @Builder
  SearchBar() {
    Row() {
      TextInput({ placeholder: '搜索博物馆、预约号或参观者' })
        .layoutWeight(1)
        .height(40)
        .backgroundColor('#F5F5F5')
        .borderRadius(20)
        .padding({ left: 16, right: 16 })
        .onChange((value: string) => {
          this.searchKeyword = value;
          this.applyFilter();
        })

      Button() {
        Image($r('app.media.icon'))
          .width(20)
          .height(20)
      }
      .width(40)
      .height(40)
      .backgroundColor('#F5F5F5')
      .borderRadius(20)
      .margin({ left: 8 })
      .onClick(() => {
        this.showFilter = !this.showFilter;
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
  }

  @Builder
  FilterPanel() {
    if (this.showFilter) {
      Column() {
        // 状态筛选
        Column() {
          Text('预约状态')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#182431')
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 8 })

          Row() {
            this.StatusChip('待参观', BookingStatus.CONFIRMED)
            this.StatusChip('已完成', BookingStatus.COMPLETED)
            this.StatusChip('已取消', BookingStatus.CANCELLED)
          }
          .width('100%')
        }
        .width('100%')
        .margin({ bottom: 16 })

        // 排序选项
        Column() {
          Text('排序方式')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#182431')
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 8 })

          Row() {
            this.SortChip('按日期', 'date')
            this.SortChip('按预约时间', 'bookingTime')
            this.SortChip('按费用', 'price')
          }
          .width('100%')
        }
        .width('100%')
        .margin({ bottom: 16 })

        // 操作按钮
        Row() {
          Button('重置')
            .layoutWeight(1)
            .height(36)
            .backgroundColor('#F5F5F5')
            .fontColor('#182431')
            .fontSize(14)
            .margin({ right: 8 })
            .onClick(() => {
              this.resetFilter();
            })

          Button('确定')
            .layoutWeight(1)
            .height(36)
            .backgroundColor('#007DFF')
            .fontColor('#FFFFFF')
            .fontSize(14)
            .margin({ left: 8 })
            .onClick(() => {
              this.showFilter = false;
            })
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .margin({ left: 16, right: 16, bottom: 8 })
    }
  }

  @Builder
  StatusChip(label: string, status: BookingStatus) {
    const isSelected = this.filterOptions.status?.includes(status) || false;
    
    Text(label)
      .fontSize(12)
      .fontColor(isSelected ? '#FFFFFF' : '#182431')
      .backgroundColor(isSelected ? '#007DFF' : '#F5F5F5')
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .borderRadius(16)
      .margin({ right: 8 })
      .onClick(() => {
        this.toggleStatusFilter(status);
      })
  }

  @Builder
  SortChip(label: string, sortBy: 'date' | 'bookingTime' | 'price') {
    const isSelected = this.filterOptions.sortBy === sortBy;
    
    Text(label)
      .fontSize(12)
      .fontColor(isSelected ? '#FFFFFF' : '#182431')
      .backgroundColor(isSelected ? '#007DFF' : '#F5F5F5')
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .borderRadius(16)
      .margin({ right: 8 })
      .onClick(() => {
        const currentOrder = this.filterOptions.sortOrder || 'desc';
        const newOrder = isSelected && currentOrder === 'desc' ? 'asc' : 'desc';
        this.setSorting(sortBy, newOrder);
      })
  }

  build() {
    Column() {
      this.SearchBar()
      this.FilterPanel()
    }
    .width('100%')
  }
}