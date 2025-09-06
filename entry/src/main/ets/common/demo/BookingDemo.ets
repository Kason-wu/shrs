import { BookingService, BookingRecord, BookingStatus, Museum, TimeSlot } from '../services/BookingService';
import { ReminderService } from '../services/ReminderService';
import { DateUtils } from '../utils/DateUtils';
import { ValidationUtils } from '../utils/ValidationUtils';

/**
 * 预约功能演示类
 * 用于展示和验证预约系统的各项功能
 */
export class BookingDemo {
  private bookingService: BookingService;
  private reminderService: ReminderService;

  constructor() {
    this.bookingService = BookingService.getInstance();
    this.reminderService = ReminderService.getInstance();
  }

  /**
   * 初始化演示数据
   */
  initDemoData(): void {
    console.info('=== 初始化预约系统演示数据 ===');
    
    // 清理现有数据
    AppStorage.SetOrCreate('userBookings', []);
    AppStorage.SetOrCreate('booking_reminders', []);
    
    // 创建示例博物馆数据
    const museums: Museum[] = [
      {
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
      },
      {
        id: 2,
        name: '故宫博物院',
        description: '明清两代的皇家宫殿',
        image: 'museum2.jpg',
        location: '北京市东城区',
        rating: 4.9,
        price: 60,
        openTime: '08:30-17:00',
        tags: ['历史', '建筑', '收费'],
        distance: '1.8km'
      },
      {
        id: 3,
        name: '中国科技馆',
        description: '现代科技的展示平台',
        image: 'museum3.jpg',
        location: '北京市朝阳区',
        rating: 4.6,
        price: 30,
        openTime: '09:30-17:00',
        tags: ['科技', '互动', '收费'],
        distance: '5.2km'
      }
    ];

    console.info(`创建了 ${museums.length} 个示例博物馆`);
  }

  /**
   * 演示预约创建流程
   */
  async demonstrateBookingCreation(): Promise<void> {
    console.info('=== 演示预约创建流程 ===');

    const tomorrow = DateUtils.formatDate(new Date(Date.now() + 24 * 60 * 60 * 1000));
    
    const testBookingData = {
      museum: {
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
      },
      date: tomorrow,
      timeSlot: {
        id: 'slot_1',
        time: '09:00-10:00',
        available: 50,
        total: 50,
        isAvailable: true
      },
      visitorCount: 2,
      visitorName: '张三',
      visitorPhone: '13800138000',
      visitorIdCard: '110101199001011234',
      totalPrice: 0
    };

    console.info('1. 验证预约数据...');
    const isValid = this.validateBookingData(testBookingData);
    console.info(`数据验证结果: ${isValid ? '通过' : '失败'}`);

    if (isValid) {
      console.info('2. 创建预约...');
      const result = await this.bookingService.createBooking(testBookingData);
      
      if (result.success) {
        console.info(`预约创建成功! 预约ID: ${result.booking?.id}`);
        console.info(`预约状态: ${result.booking?.status}`);
        console.info(`预约时间: ${result.booking?.bookingTime}`);
        
        // 演示提醒设置
        if (result.booking) {
          console.info('3. 设置预约提醒...');
          this.reminderService.setBookingReminder(result.booking);
          const reminders = this.reminderService.getBookingReminders(result.booking.id);
          console.info(`设置了 ${reminders.length} 个提醒`);
        }
      } else {
        console.error(`预约创建失败: ${result.error}`);
      }
    }
  }

  /**
   * 演示预约查询和筛选
   */
  demonstrateBookingQuery(): void {
    console.info('=== 演示预约查询和筛选 ===');

    console.info('1. 获取所有预约...');
    const allBookings = this.bookingService.getAllBookings();
    console.info(`总预约数: ${allBookings.length}`);

    console.info('2. 按状态筛选预约...');
    const confirmedBookings = this.bookingService.getBookingsByStatus(BookingStatus.CONFIRMED);
    const completedBookings = this.bookingService.getBookingsByStatus(BookingStatus.COMPLETED);
    const cancelledBookings = this.bookingService.getBookingsByStatus(BookingStatus.CANCELLED);
    
    console.info(`待参观: ${confirmedBookings.length}`);
    console.info(`已完成: ${completedBookings.length}`);
    console.info(`已取消: ${cancelledBookings.length}`);

    console.info('3. 获取即将到来的预约...');
    const upcomingBookings = this.bookingService.getUpcomingBookings();
    console.info(`即将到来的预约: ${upcomingBookings.length}`);

    console.info('4. 获取预约统计...');
    const statistics = this.bookingService.getBookingStatistics();
    console.info(`统计信息:`, {
      总预约: statistics.totalBookings,
      待参观: statistics.confirmedBookings,
      已完成: statistics.completedBookings,
      已取消: statistics.cancelledBookings,
      总消费: statistics.totalSpent,
      常访问博物馆: statistics.favoriteMuseums
    });
  }

  /**
   * 演示预约取消流程
   */
  async demonstrateBookingCancellation(): Promise<void> {
    console.info('=== 演示预约取消流程 ===');

    const confirmedBookings = this.bookingService.getBookingsByStatus(BookingStatus.CONFIRMED);
    
    if (confirmedBookings.length > 0) {
      const bookingToCancel = confirmedBookings[0];
      console.info(`1. 准备取消预约: ${bookingToCancel.id}`);
      console.info(`博物馆: ${bookingToCancel.museum.name}`);
      console.info(`参观日期: ${bookingToCancel.date}`);

      console.info('2. 执行取消操作...');
      const result = await this.bookingService.cancelBooking(bookingToCancel.id, '演示取消');
      
      if (result.success) {
        console.info('预约取消成功!');
        
        // 验证状态更新
        const updatedBooking = this.bookingService.getBookingById(bookingToCancel.id);
        console.info(`更新后状态: ${updatedBooking?.status}`);
      } else {
        console.error(`预约取消失败: ${result.error}`);
      }
    } else {
      console.info('没有可取消的预约');
    }
  }

  /**
   * 演示时间段查询
   */
  demonstrateTimeSlotQuery(): void {
    console.info('=== 演示时间段查询 ===');

    const tomorrow = DateUtils.formatDate(new Date(Date.now() + 24 * 60 * 60 * 1000));
    const museumId = 1;

    console.info(`查询博物馆 ${museumId} 在 ${tomorrow} 的可用时间段...`);
    
    const timeSlots = this.bookingService.getAvailableTimeSlots(museumId, tomorrow);
    
    console.info(`找到 ${timeSlots.length} 个时间段:`);
    timeSlots.forEach((slot, index) => {
      console.info(`${index + 1}. ${slot.time} - 可预约: ${slot.available}/${slot.total} (${slot.isAvailable ? '可用' : '不可用'})`);
    });
  }

  /**
   * 演示提醒功能
   */
  demonstrateReminderFeatures(): void {
    console.info('=== 演示提醒功能 ===');

    console.info('1. 获取所有提醒...');
    const allReminders = this.reminderService.getAllReminders();
    console.info(`总提醒数: ${allReminders.length}`);

    console.info('2. 获取活跃提醒...');
    const activeReminders = this.reminderService.getActiveReminders();
    console.info(`活跃提醒数: ${activeReminders.length}`);

    console.info('3. 检查待处理提醒...');
    const pendingReminders = this.reminderService.checkPendingReminders();
    console.info(`待处理提醒数: ${pendingReminders.length}`);

    console.info('4. 获取提醒统计...');
    const statistics = this.reminderService.getReminderStatistics();
    console.info(`提醒统计:`, {
      总提醒: statistics.totalReminders,
      活跃提醒: statistics.activeReminders,
      今日提醒: statistics.todayReminders
    });

    console.info('5. 获取提醒设置...');
    const settings = this.reminderService.getReminderSettings();
    console.info(`提醒设置:`, {
      预约确认提醒: settings.enableBookingConfirmation,
      参观提醒: settings.enableVisitReminder,
      提前分钟数: settings.reminderAdvanceMinutes
    });
  }

  /**
   * 演示数据清理功能
   */
  demonstrateDataCleanup(): void {
    console.info('=== 演示数据清理功能 ===');

    console.info('1. 清理过期预约...');
    this.bookingService.cleanupExpiredBookings();
    console.info('过期预约清理完成');

    console.info('2. 清理过期提醒...');
    this.reminderService.cleanupExpiredReminders();
    console.info('过期提醒清理完成');
  }

  /**
   * 验证预约数据
   */
  private validateBookingData(bookingData: any): boolean {
    const validations = [
      { field: 'visitorName', value: bookingData.visitorName, validator: ValidationUtils.validateName },
      { field: 'visitorPhone', value: bookingData.visitorPhone, validator: ValidationUtils.validatePhone },
      { field: 'visitorIdCard', value: bookingData.visitorIdCard, validator: ValidationUtils.validateIdCard },
      { field: 'visitorCount', value: bookingData.visitorCount, validator: ValidationUtils.validateVisitorCount }
    ];

    let isValid = true;
    validations.forEach(({ field, value, validator }) => {
      const result = validator(value);
      console.info(`${field}: ${result ? '✓' : '✗'}`);
      if (!result) isValid = false;
    });

    return isValid;
  }

  /**
   * 运行完整演示
   */
  async runFullDemo(): Promise<void> {
    console.info('🎯 开始预约系统功能演示');
    console.info('=====================================');

    try {
      // 1. 初始化数据
      this.initDemoData();
      
      // 2. 演示预约创建
      await this.demonstrateBookingCreation();
      
      // 3. 演示查询功能
      this.demonstrateBookingQuery();
      
      // 4. 演示时间段查询
      this.demonstrateTimeSlotQuery();
      
      // 5. 演示提醒功能
      this.demonstrateReminderFeatures();
      
      // 6. 演示取消功能
      await this.demonstrateBookingCancellation();
      
      // 7. 演示数据清理
      this.demonstrateDataCleanup();
      
      console.info('=====================================');
      console.info('✅ 预约系统功能演示完成');
      
    } catch (error) {
      console.error('❌ 演示过程中发生错误:', error);
    }
  }

  /**
   * 验证系统完整性
   */
  validateSystemIntegrity(): boolean {
    console.info('🔍 验证预约系统完整性');
    
    const checks = [
      { name: '预约服务初始化', test: () => this.bookingService !== null },
      { name: '提醒服务初始化', test: () => this.reminderService !== null },
      { name: '日期工具可用', test: () => DateUtils.formatDate(new Date()) !== '' },
      { name: '验证工具可用', test: () => ValidationUtils.validatePhone('13800138000') },
      { name: '存储功能可用', test: () => {
        AppStorage.SetOrCreate('test_key', 'test_value');
        return AppStorage.Get('test_key') === 'test_value';
      }}
    ];

    let allPassed = true;
    checks.forEach(({ name, test }) => {
      try {
        const result = test();
        console.info(`${name}: ${result ? '✓' : '✗'}`);
        if (!result) allPassed = false;
      } catch (error) {
        console.error(`${name}: ✗ (错误: ${error})`);
        allPassed = false;
      }
    });

    console.info(`系统完整性验证: ${allPassed ? '✅ 通过' : '❌ 失败'}`);
    return allPassed;
  }
}