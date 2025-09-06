import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { ReminderService, ReminderType, ReminderInfo } from '../../main/ets/common/services/ReminderService';
import { BookingRecord, BookingStatus } from '../../main/ets/common/services/BookingService';
import { DateUtils } from '../../main/ets/common/utils/DateUtils';

/**
 * 提醒服务测试套件
 */
export default function ReminderServiceTest() {
  describe('ReminderService', function () {
    let reminderService: ReminderService;
    let testBooking: BookingRecord;

    beforeAll(function () {
      // 测试前的设置
    });

    beforeEach(function () {
      // 每个测试前的设置
      reminderService = ReminderService.getInstance();
      
      // 清理测试数据
      AppStorage.SetOrCreate('booking_reminders', []);
      AppStorage.SetOrCreate('reminder_settings', null);

      // 准备测试预约数据
      const tomorrow = DateUtils.formatDate(new Date(Date.now() + 24 * 60 * 60 * 1000));
      
      testBooking = {
        id: 'test_booking_reminder',
        museum: {
          id: 1,
          name: '测试博物馆',
          description: '用于测试的博物馆',
          image: 'test.jpg',
          location: '测试地址',
          rating: 4.5,
          price: 50,
          openTime: '09:00-17:00',
          tags: ['测试'],
          distance: '1km'
        },
        date: tomorrow,
        timeSlot: {
          id: 'slot_1',
          time: '10:00-11:00',
          available: 50,
          total: 50,
          isAvailable: true
        },
        visitorCount: 1,
        visitorName: '提醒测试',
        visitorPhone: '13100131000',
        visitorIdCard: '110101199001011242',
        totalPrice: 50,
        status: BookingStatus.CONFIRMED,
        bookingTime: new Date().toISOString()
      };
    });

    afterEach(function () {
      // 每个测试后的清理
      AppStorage.SetOrCreate('booking_reminders', []);
      AppStorage.SetOrCreate('reminder_settings', null);
    });

    afterAll(function () {
      // 测试后的清理
    });

    /**
     * 测试设置预约提醒
     */
    it('should set booking reminder successfully', 0, function () {
      reminderService.setBookingReminder(testBooking);
      
      const reminders = reminderService.getAllReminders();
      expect(reminders.length).assertLarger(0);
      
      // 应该有预约确认提醒
      const confirmationReminder = reminders.find(r => r.type === ReminderType.BOOKING_CONFIRMATION);
      expect(confirmationReminder).assertNotNull();
      expect(confirmationReminder!.bookingId).assertEqual(testBooking.id);
    });

    /**
     * 测试取消预约提醒
     */
    it('should cancel booking reminder successfully', 0, function () {
      // 先设置提醒
      reminderService.setBookingReminder(testBooking);
      
      let reminders = reminderService.getActiveReminders();
      const initialActiveCount = reminders.length;
      
      // 取消提醒
      reminderService.cancelBookingReminder(testBooking);
      
      reminders = reminderService.getActiveReminders();
      expect(reminders.length).assertLess(initialActiveCount);
      
      // 应该有取消通知
      const allReminders = reminderService.getAllReminders();
      const cancellationNotice = allReminders.find(r => r.type === ReminderType.CANCELLATION_NOTICE);
      expect(cancellationNotice).assertNotNull();
    });

    /**
     * 测试获取指定预约的提醒
     */
    it('should get booking reminders correctly', 0, function () {
      reminderService.setBookingReminder(testBooking);
      
      const bookingReminders = reminderService.getBookingReminders(testBooking.id);
      expect(bookingReminders.length).assertLarger(0);
      
      // 所有提醒都应该属于这个预约
      bookingReminders.forEach(reminder => {
        expect(reminder.bookingId).assertEqual(testBooking.id);
      });
    });

    /**
     * 测试活跃提醒筛选
     */
    it('should filter active reminders correctly', 0, function () {
      reminderService.setBookingReminder(testBooking);
      
      const allReminders = reminderService.getAllReminders();
      const activeReminders = reminderService.getActiveReminders();
      
      expect(activeReminders.length).assertLessOrEqual(allReminders.length);
      
      // 所有活跃提醒的isActive应该为true
      activeReminders.forEach(reminder => {
        expect(reminder.isActive).assertTrue();
      });
    });

    /**
     * 测试提醒统计
     */
    it('should calculate reminder statistics correctly', 0, function () {
      reminderService.setBookingReminder(testBooking);
      
      const statistics = reminderService.getReminderStatistics();
      
      expect(statistics.totalReminders).assertLarger(0);
      expect(statistics.activeReminders).assertLarger(0);
      expect(statistics.totalReminders).assertLargerOrEqual(statistics.activeReminders);
    });

    /**
     * 测试提醒设置
     */
    it('should manage reminder settings correctly', 0, function () {
      const settings = {
        enableBookingConfirmation: true,
        enableVisitReminder: false,
        reminderAdvanceMinutes: 120
      };
      
      reminderService.updateReminderSettings(settings);
      
      const savedSettings = reminderService.getReminderSettings();
      expect(savedSettings.enableBookingConfirmation).assertTrue();
      expect(savedSettings.enableVisitReminder).assertFalse();
      expect(savedSettings.reminderAdvanceMinutes).assertEqual(120);
    });

    /**
     * 测试清理过期提醒
     */
    it('should cleanup expired reminders correctly', 0, function () {
      // 创建一个过期的提醒
      const expiredReminder: ReminderInfo = {
        id: 'expired_reminder',
        bookingId: testBooking.id,
        type: ReminderType.VISIT_REMINDER,
        title: '过期提醒',
        message: '这是一个过期的提醒',
        scheduledTime: new Date(Date.now() - 10 * 24 * 60 * 60 * 1000).toISOString(), // 10天前
        isActive: false,
        createdAt: new Date(Date.now() - 10 * 24 * 60 * 60 * 1000).toISOString()
      };
      
      AppStorage.SetOrCreate('booking_reminders', [expiredReminder]);
      
      const beforeCleanup = reminderService.getAllReminders();
      expect(beforeCleanup.length).assertEqual(1);
      
      reminderService.cleanupExpiredReminders();
      
      const afterCleanup = reminderService.getAllReminders();
      expect(afterCleanup.length).assertEqual(0);
    });

    /**
     * 测试删除预约相关提醒
     */
    it('should delete booking reminders correctly', 0, function () {
      reminderService.setBookingReminder(testBooking);
      
      const beforeDelete = reminderService.getBookingReminders(testBooking.id);
      expect(beforeDelete.length).assertLarger(0);
      
      reminderService.deleteBookingReminders(testBooking.id);
      
      const afterDelete = reminderService.getBookingReminders(testBooking.id);
      expect(afterDelete.length).assertEqual(0);
    });

    /**
     * 测试检查待处理提醒
     */
    it('should check pending reminders correctly', 0, function () {
      // 创建一个应该触发的提醒
      const pendingReminder: ReminderInfo = {
        id: 'pending_reminder',
        bookingId: testBooking.id,
        type: ReminderType.VISIT_REMINDER,
        title: '待处理提醒',
        message: '这是一个待处理的提醒',
        scheduledTime: new Date(Date.now() - 1000).toISOString(), // 1秒前
        isActive: true,
        createdAt: new Date().toISOString()
      };
      
      AppStorage.SetOrCreate('booking_reminders', [pendingReminder]);
      
      const pendingReminders = reminderService.checkPendingReminders();
      expect(pendingReminders.length).assertLarger(0);
    });

    /**
     * 测试默认提醒设置
     */
    it('should return default reminder settings when none exist', 0, function () {
      const settings = reminderService.getReminderSettings();
      
      expect(settings.enableBookingConfirmation).assertTrue();
      expect(settings.enableVisitReminder).assertTrue();
      expect(settings.reminderAdvanceMinutes).assertEqual(60);
    });
  });
}