import { BookingRecord, BookingStatus } from './BookingService';
import { DateUtils } from '../utils/DateUtils';

/**
 * 提醒类型枚举
 */
export enum ReminderType {
  BOOKING_CONFIRMATION = 'booking_confirmation',
  VISIT_REMINDER = 'visit_reminder',
  CANCELLATION_NOTICE = 'cancellation_notice'
}

/**
 * 提醒信息接口
 */
export interface ReminderInfo {
  id: string;
  bookingId: string;
  type: ReminderType;
  title: string;
  message: string;
  scheduledTime: string;
  isActive: boolean;
  createdAt: string;
}

/**
 * 预约提醒服务类
 * 负责管理预约相关的提醒和通知
 */
export class ReminderService {
  private static instance: ReminderService;
  private readonly STORAGE_KEY = 'booking_reminders';
  
  private constructor() {}
  
  /**
   * 获取单例实例
   */
  static getInstance(): ReminderService {
    if (!ReminderService.instance) {
      ReminderService.instance = new ReminderService();
    }
    return ReminderService.instance;
  }

  /**
   * 为预约设置提醒
   */
  setBookingReminder(booking: BookingRecord): void {
    try {
      // 预约确认提醒（立即）
      this.createReminder({
        bookingId: booking.id,
        type: ReminderType.BOOKING_CONFIRMATION,
        title: '预约成功',
        message: `您已成功预约${booking.museum.name}，参观时间：${DateUtils.formatDateChinese(booking.date)} ${booking.timeSlot.time}`,
        scheduledTime: new Date().toISOString()
      });

      // 参观提醒（提前1小时）
      const visitDateTime = new Date(`${booking.date} ${booking.timeSlot.time.split('-')[0]}`);
      const reminderTime = new Date(visitDateTime.getTime() - 60 * 60 * 1000); // 提前1小时

      if (reminderTime > new Date()) {
        this.createReminder({
          bookingId: booking.id,
          type: ReminderType.VISIT_REMINDER,
          title: '参观提醒',
          message: `您预约的${booking.museum.name}参观时间即将到来，请提前准备出发`,
          scheduledTime: reminderTime.toISOString()
        });
      }
    } catch (error) {
      console.error('设置预约提醒失败:', error);
    }
  }

  /**
   * 取消预约提醒
   */
  cancelBookingReminder(booking: BookingRecord): void {
    try {
      const reminders = this.getAllReminders();
      const updatedReminders = reminders.map(reminder => {
        if (reminder.bookingId === booking.id) {
          return { ...reminder, isActive: false };
        }
        return reminder;
      });

      this.saveReminders(updatedReminders);

      // 创建取消通知
      this.createReminder({
        bookingId: booking.id,
        type: ReminderType.CANCELLATION_NOTICE,
        title: '预约已取消',
        message: `您的${booking.museum.name}预约已成功取消`,
        scheduledTime: new Date().toISOString()
      });
    } catch (error) {
      console.error('取消预约提醒失败:', error);
    }
  }

  /**
   * 创建提醒
   */
  private createReminder(reminderData: Omit<ReminderInfo, 'id' | 'isActive' | 'createdAt'>): void {
    const reminder: ReminderInfo = {
      ...reminderData,
      id: this.generateReminderId(),
      isActive: true,
      createdAt: new Date().toISOString()
    };

    const reminders = this.getAllReminders();
    reminders.push(reminder);
    this.saveReminders(reminders);

    // 如果是立即提醒，直接显示
    if (new Date(reminder.scheduledTime) <= new Date()) {
      this.showNotification(reminder);
    }
  }

  /**
   * 获取所有提醒
   */
  getAllReminders(): ReminderInfo[] {
    try {
      const reminders = AppStorage.Get(this.STORAGE_KEY) as ReminderInfo[] || [];
      return reminders.sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
    } catch (error) {
      console.error('获取提醒列表失败:', error);
      return [];
    }
  }

  /**
   * 获取活跃的提醒
   */
  getActiveReminders(): ReminderInfo[] {
    return this.getAllReminders().filter(reminder => reminder.isActive);
  }

  /**
   * 获取指定预约的提醒
   */
  getBookingReminders(bookingId: string): ReminderInfo[] {
    return this.getAllReminders().filter(reminder => reminder.bookingId === bookingId);
  }

  /**
   * 检查并触发到期的提醒
   */
  checkPendingReminders(): ReminderInfo[] {
    const now = new Date();
    const activeReminders = this.getActiveReminders();
    const pendingReminders: ReminderInfo[] = [];

    activeReminders.forEach(reminder => {
      const scheduledTime = new Date(reminder.scheduledTime);
      if (scheduledTime <= now && reminder.type !== ReminderType.BOOKING_CONFIRMATION) {
        pendingReminders.push(reminder);
        this.showNotification(reminder);
        this.markReminderAsShown(reminder.id);
      }
    });

    return pendingReminders;
  }

  /**
   * 显示通知
   */
  private showNotification(reminder: ReminderInfo): void {
    try {
      // 这里可以集成系统通知API
      // 目前使用简单的Toast提示
      console.log(`提醒: ${reminder.title} - ${reminder.message}`);
      
      // 可以在这里添加更复杂的通知逻辑
      // 比如系统通知、应用内弹窗等
    } catch (error) {
      console.error('显示通知失败:', error);
    }
  }

  /**
   * 标记提醒为已显示
   */
  private markReminderAsShown(reminderId: string): void {
    const reminders = this.getAllReminders();
    const updatedReminders = reminders.map(reminder => {
      if (reminder.id === reminderId) {
        return { ...reminder, isActive: false };
      }
      return reminder;
    });

    this.saveReminders(updatedReminders);
  }

  /**
   * 保存提醒到本地存储
   */
  private saveReminders(reminders: ReminderInfo[]): void {
    try {
      AppStorage.SetOrCreate(this.STORAGE_KEY, reminders);
    } catch (error) {
      console.error('保存提醒失败:', error);
    }
  }

  /**
   * 生成提醒ID
   */
  private generateReminderId(): string {
    return `reminder_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * 清理过期的提醒
   */
  cleanupExpiredReminders(): void {
    try {
      const reminders = this.getAllReminders();
      const now = new Date();
      const oneWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);

      const validReminders = reminders.filter(reminder => {
        const createdAt = new Date(reminder.createdAt);
        return createdAt > oneWeekAgo || reminder.isActive;
      });

      this.saveReminders(validReminders);
    } catch (error) {
      console.error('清理过期提醒失败:', error);
    }
  }

  /**
   * 获取提醒统计信息
   */
  getReminderStatistics(): {
    totalReminders: number;
    activeReminders: number;
    todayReminders: number;
  } {
    const allReminders = this.getAllReminders();
    const activeReminders = this.getActiveReminders();
    const today = DateUtils.formatDate(new Date());
    
    const todayReminders = activeReminders.filter(reminder => {
      const scheduledDate = DateUtils.formatDate(new Date(reminder.scheduledTime));
      return scheduledDate === today;
    });

    return {
      totalReminders: allReminders.length,
      activeReminders: activeReminders.length,
      todayReminders: todayReminders.length
    };
  }

  /**
   * 删除指定预约的所有提醒
   */
  deleteBookingReminders(bookingId: string): void {
    try {
      const reminders = this.getAllReminders();
      const filteredReminders = reminders.filter(reminder => reminder.bookingId !== bookingId);
      this.saveReminders(filteredReminders);
    } catch (error) {
      console.error('删除预约提醒失败:', error);
    }
  }

  /**
   * 更新提醒设置
   */
  updateReminderSettings(settings: {
    enableBookingConfirmation: boolean;
    enableVisitReminder: boolean;
    reminderAdvanceMinutes: number;
  }): void {
    try {
      AppStorage.SetOrCreate('reminder_settings', settings);
    } catch (error) {
      console.error('更新提醒设置失败:', error);
    }
  }

  /**
   * 获取提醒设置
   */
  getReminderSettings(): {
    enableBookingConfirmation: boolean;
    enableVisitReminder: boolean;
    reminderAdvanceMinutes: number;
  } {
    try {
      const defaultSettings = {
        enableBookingConfirmation: true,
        enableVisitReminder: true,
        reminderAdvanceMinutes: 60
      };
      
      const settings = AppStorage.Get('reminder_settings') as any;
      return settings || defaultSettings;
    } catch (error) {
      console.error('获取提醒设置失败:', error);
      return {
        enableBookingConfirmation: true,
        enableVisitReminder: true,
        reminderAdvanceMinutes: 60
      };
    }
  }
}