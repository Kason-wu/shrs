import { AppConstants } from '../constants/AppConstants';
import { DateUtils } from '../utils/DateUtils';
import { ValidationUtils } from '../utils/ValidationUtils';
import { ReminderService } from './ReminderService';

/**
 * 预约记录接口
 */
export interface BookingRecord {
  id: string;
  museum: Museum;
  date: string;
  timeSlot: TimeSlot;
  visitorCount: number;
  visitorName: string;
  visitorPhone: string;
  visitorIdCard: string;
  totalPrice: number;
  status: BookingStatus;
  bookingTime: string;
  reminderSet?: boolean;
  notes?: string;
}

/**
 * 博物馆信息接口
 */
export interface Museum {
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
  maxVisitors?: number;
  advanceBookingDays?: number;
}

/**
 * 时间段接口
 */
export interface TimeSlot {
  id: string;
  time: string;
  available: number;
  total: number;
  isAvailable?: boolean;
}

/**
 * 预约状态枚举
 */
export enum BookingStatus {
  CONFIRMED = 'confirmed',
  CANCELLED = 'cancelled',
  COMPLETED = 'completed',
  PENDING = 'pending'
}

/**
 * 预约验证结果接口
 */
export interface BookingValidationResult {
  isValid: boolean;
  errors: string[];
  warnings: string[];
}

/**
 * 预约统计接口
 */
export interface BookingStatistics {
  totalBookings: number;
  confirmedBookings: number;
  completedBookings: number;
  cancelledBookings: number;
  totalSpent: number;
  favoriteMuseums: string[];
}

/**
 * 预约服务类
 * 负责处理所有预约相关的业务逻辑
 */
export class BookingService {
  private static instance: BookingService;
  private reminderService: ReminderService;
  
  private constructor() {
    this.reminderService = ReminderService.getInstance();
  }
  
  /**
   * 获取单例实例
   */
  static getInstance(): BookingService {
    if (!BookingService.instance) {
      BookingService.instance = new BookingService();
    }
    return BookingService.instance;
  }

  /**
   * 获取所有预约记录
   */
  getAllBookings(): BookingRecord[] {
    const bookings = AppStorage.Get(AppConstants.STORAGE_BOOKINGS_KEY) as BookingRecord[] || [];
    return bookings.sort((a, b) => new Date(b.bookingTime).getTime() - new Date(a.bookingTime).getTime());
  }

  /**
   * 根据状态获取预约记录
   */
  getBookingsByStatus(status: BookingStatus): BookingRecord[] {
    return this.getAllBookings().filter(booking => booking.status === status);
  }

  /**
   * 根据ID获取预约记录
   */
  getBookingById(id: string): BookingRecord | null {
    const bookings = this.getAllBookings();
    return bookings.find(booking => booking.id === id) || null;
  }

  /**
   * 创建新的预约记录
   */
  async createBooking(bookingData: Omit<BookingRecord, 'id' | 'bookingTime' | 'status'>): Promise<{ success: boolean; booking?: BookingRecord; error?: string }> {
    try {
      // 验证预约数据
      const validation = this.validateBookingData(bookingData);
      if (!validation.isValid) {
        return { success: false, error: validation.errors.join(', ') };
      }

      // 检查时间冲突
      const conflictCheck = this.checkTimeConflict(bookingData.date, bookingData.timeSlot);
      if (!conflictCheck.isAvailable) {
        return { success: false, error: '该时间段已被预约或不可用' };
      }

      // 创建预约记录
      const booking: BookingRecord = {
        ...bookingData,
        id: this.generateBookingId(),
        bookingTime: new Date().toISOString(),
        status: BookingStatus.CONFIRMED,
        reminderSet: false
      };

      // 保存预约记录
      const bookings = this.getAllBookings();
      bookings.push(booking);
      AppStorage.SetOrCreate(AppConstants.STORAGE_BOOKINGS_KEY, bookings);

      // 设置提醒（如果需要）
      this.reminderService.setBookingReminder(booking);

      return { success: true, booking };
    } catch (error) {
      return { success: false, error: '创建预约失败，请重试' };
    }
  }

  /**
   * 取消预约
   */
  async cancelBooking(bookingId: string, reason?: string): Promise<{ success: boolean; error?: string }> {
    try {
      const bookings = this.getAllBookings();
      const bookingIndex = bookings.findIndex(b => b.id === bookingId);
      
      if (bookingIndex === -1) {
        return { success: false, error: '预约记录不存在' };
      }

      const booking = bookings[bookingIndex];
      
      // 检查是否可以取消
      if (booking.status !== BookingStatus.CONFIRMED) {
        return { success: false, error: '该预约无法取消' };
      }

      // 检查取消时间限制（预约时间前2小时）
      const bookingDateTime = new Date(`${booking.date} ${booking.timeSlot.time.split('-')[0]}`);
      const now = new Date();
      const timeDiff = bookingDateTime.getTime() - now.getTime();
      const hoursDiff = timeDiff / (1000 * 60 * 60);

      if (hoursDiff < 2) {
        return { success: false, error: '预约时间前2小时内无法取消' };
      }

      // 更新预约状态
      bookings[bookingIndex].status = BookingStatus.CANCELLED;
      if (reason) {
        bookings[bookingIndex].notes = reason;
      }

      AppStorage.SetOrCreate(AppConstants.STORAGE_BOOKINGS_KEY, bookings);

      // 取消提醒
      this.reminderService.cancelBookingReminder(booking);

      return { success: true };
    } catch (error) {
      return { success: false, error: '取消预约失败，请重试' };
    }
  }

  /**
   * 完成预约（参观结束后）
   */
  async completeBooking(bookingId: string): Promise<{ success: boolean; error?: string }> {
    try {
      const bookings = this.getAllBookings();
      const bookingIndex = bookings.findIndex(b => b.id === bookingId);
      
      if (bookingIndex === -1) {
        return { success: false, error: '预约记录不存在' };
      }

      bookings[bookingIndex].status = BookingStatus.COMPLETED;
      AppStorage.SetOrCreate(AppConstants.STORAGE_BOOKINGS_KEY, bookings);

      return { success: true };
    } catch (error) {
      return { success: false, error: '更新预约状态失败' };
    }
  }

  /**
   * 验证预约数据
   */
  private validateBookingData(bookingData: Omit<BookingRecord, 'id' | 'bookingTime' | 'status'>): BookingValidationResult {
    const errors: string[] = [];
    const warnings: string[] = [];

    // 验证博物馆信息
    if (!bookingData.museum || !bookingData.museum.id) {
      errors.push('请选择博物馆');
    }

    // 验证日期
    if (!bookingData.date) {
      errors.push('请选择参观日期');
    } else if (!DateUtils.isValidBookingDate(bookingData.date)) {
      errors.push('请选择有效的参观日期');
    }

    // 验证时间段
    if (!bookingData.timeSlot || !bookingData.timeSlot.id) {
      errors.push('请选择参观时间');
    }

    // 验证参观人数
    if (!ValidationUtils.validateVisitorCount(bookingData.visitorCount)) {
      errors.push(`参观人数必须在${AppConstants.MIN_VISITOR_COUNT}-${AppConstants.MAX_VISITOR_COUNT}人之间`);
    }

    // 验证参观者信息
    if (!ValidationUtils.validateName(bookingData.visitorName)) {
      errors.push('请输入有效的参观者姓名');
    }

    if (!ValidationUtils.validatePhone(bookingData.visitorPhone)) {
      errors.push('请输入有效的手机号码');
    }

    if (!ValidationUtils.validateIdCard(bookingData.visitorIdCard)) {
      errors.push('请输入有效的身份证号码');
    }

    // 检查是否为节假日（警告）
    if (this.isHoliday(bookingData.date)) {
      warnings.push('节假日期间参观人数较多，建议提前到达');
    }

    return {
      isValid: errors.length === 0,
      errors,
      warnings
    };
  }

  /**
   * 检查时间冲突
   */
  private checkTimeConflict(date: string, timeSlot: TimeSlot): { isAvailable: boolean; reason?: string } {
    const existingBookings = this.getAllBookings().filter(
      booking => booking.status === BookingStatus.CONFIRMED && 
                 booking.date === date && 
                 booking.timeSlot.id === timeSlot.id
    );

    const bookedCount = existingBookings.reduce((sum, booking) => sum + booking.visitorCount, 0);
    const availableSlots = timeSlot.total - bookedCount;

    if (availableSlots <= 0) {
      return { isAvailable: false, reason: '该时间段已满' };
    }

    return { isAvailable: true };
  }

  /**
   * 生成预约ID
   */
  private generateBookingId(): string {
    return `booking_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }



  /**
   * 检查是否为节假日
   */
  private isHoliday(date: string): boolean {
    const holidays = [
      '2024-01-01', // 元旦
      '2024-02-10', '2024-02-11', '2024-02-12', '2024-02-13', '2024-02-14', '2024-02-15', '2024-02-16', // 春节
      '2024-04-04', '2024-04-05', '2024-04-06', // 清明节
      '2024-05-01', '2024-05-02', '2024-05-03', // 劳动节
      '2024-06-10', // 端午节
      '2024-09-15', '2024-09-16', '2024-09-17', // 中秋节
      '2024-10-01', '2024-10-02', '2024-10-03', '2024-10-04', '2024-10-05', '2024-10-06', '2024-10-07' // 国庆节
    ];
    return holidays.includes(date);
  }

  /**
   * 获取预约统计信息
   */
  getBookingStatistics(): BookingStatistics {
    const bookings = this.getAllBookings();
    
    const totalBookings = bookings.length;
    const confirmedBookings = bookings.filter(b => b.status === BookingStatus.CONFIRMED).length;
    const completedBookings = bookings.filter(b => b.status === BookingStatus.COMPLETED).length;
    const cancelledBookings = bookings.filter(b => b.status === BookingStatus.CANCELLED).length;
    
    const totalSpent = bookings
      .filter(b => b.status === BookingStatus.COMPLETED)
      .reduce((sum, booking) => sum + booking.totalPrice, 0);

    // 统计最常访问的博物馆
    const museumCounts = new Map<string, number>();
    bookings
      .filter(b => b.status === BookingStatus.COMPLETED)
      .forEach(booking => {
        const count = museumCounts.get(booking.museum.name) || 0;
        museumCounts.set(booking.museum.name, count + 1);
      });

    const favoriteMuseums = Array.from(museumCounts.entries())
      .sort((a, b) => b[1] - a[1])
      .slice(0, 3)
      .map(entry => entry[0]);

    return {
      totalBookings,
      confirmedBookings,
      completedBookings,
      cancelledBookings,
      totalSpent,
      favoriteMuseums
    };
  }

  /**
   * 获取可用时间段
   */
  getAvailableTimeSlots(museumId: number, date: string): TimeSlot[] {
    const defaultSlots: TimeSlot[] = AppConstants.DEFAULT_TIME_SLOTS.map((time, index) => ({
      id: `slot_${index + 1}`,
      time,
      available: 50,
      total: 50,
      isAvailable: true
    }));

    // 计算已预约的人数
    const existingBookings = this.getAllBookings().filter(
      booking => booking.status === BookingStatus.CONFIRMED && 
                 booking.date === date &&
                 booking.museum.id === museumId
    );

    return defaultSlots.map(slot => {
      const bookedCount = existingBookings
        .filter(booking => booking.timeSlot.id === slot.id)
        .reduce((sum, booking) => sum + booking.visitorCount, 0);
      
      const available = slot.total - bookedCount;
      
      return {
        ...slot,
        available: Math.max(0, available),
        isAvailable: available > 0
      };
    });
  }

  /**
   * 检查用户是否有冲突的预约
   */
  hasConflictingBooking(date: string, timeSlot: TimeSlot): boolean {
    const userBookings = this.getAllBookings().filter(
      booking => booking.status === BookingStatus.CONFIRMED
    );

    return userBookings.some(booking => 
      booking.date === date && booking.timeSlot.id === timeSlot.id
    );
  }

  /**
   * 获取即将到来的预约
   */
  getUpcomingBookings(): BookingRecord[] {
    const now = new Date();
    const today = DateUtils.formatDate(now);
    
    return this.getBookingsByStatus(BookingStatus.CONFIRMED)
      .filter(booking => booking.date >= today)
      .sort((a, b) => {
        const dateA = new Date(`${a.date} ${a.timeSlot.time.split('-')[0]}`);
        const dateB = new Date(`${b.date} ${b.timeSlot.time.split('-')[0]}`);
        return dateA.getTime() - dateB.getTime();
      });
  }

  /**
   * 清理过期的预约记录
   */
  cleanupExpiredBookings(): void {
    const bookings = this.getAllBookings();
    const now = new Date();
    
    const updatedBookings = bookings.map(booking => {
      if (booking.status === BookingStatus.CONFIRMED) {
        const bookingDateTime = new Date(`${booking.date} ${booking.timeSlot.time.split('-')[1]}`);
        if (bookingDateTime < now) {
          return { ...booking, status: BookingStatus.COMPLETED };
        }
      }
      return booking;
    });

    AppStorage.SetOrCreate(AppConstants.STORAGE_BOOKINGS_KEY, updatedBookings);
    
    // 同时清理过期提醒
    this.reminderService.cleanupExpiredReminders();
  }
}