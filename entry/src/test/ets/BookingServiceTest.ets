import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { BookingService, BookingRecord, BookingStatus, Museum, TimeSlot } from '../../main/ets/common/services/BookingService';
import { ReminderService } from '../../main/ets/common/services/ReminderService';
import { DateUtils } from '../../main/ets/common/utils/DateUtils';

/**
 * 预约服务测试套件
 */
export default function BookingServiceTest() {
  describe('BookingService', function () {
    let bookingService: BookingService;
    let reminderService: ReminderService;
    let testMuseum: Museum;
    let testTimeSlot: TimeSlot;

    beforeAll(function () {
      // 测试前的设置
    });

    beforeEach(function () {
      // 每个测试前的设置
      bookingService = BookingService.getInstance();
      reminderService = ReminderService.getInstance();
      
      // 清理测试数据
      AppStorage.SetOrCreate('userBookings', []);
      AppStorage.SetOrCreate('booking_reminders', []);

      // 准备测试数据
      testMuseum = {
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
      };

      testTimeSlot = {
        id: 'slot_1',
        time: '09:00-10:00',
        available: 50,
        total: 50,
        isAvailable: true
      };
    });

    afterEach(function () {
      // 每个测试后的清理
      AppStorage.SetOrCreate('userBookings', []);
      AppStorage.SetOrCreate('booking_reminders', []);
    });

    afterAll(function () {
      // 测试后的清理
    });

    /**
     * 测试创建预约功能
     */
    it('should create booking successfully', 0, async function () {
      const tomorrow = DateUtils.formatDate(new Date(Date.now() + 24 * 60 * 60 * 1000));
      
      const bookingData = {
        museum: testMuseum,
        date: tomorrow,
        timeSlot: testTimeSlot,
        visitorCount: 2,
        visitorName: '张三',
        visitorPhone: '13800138000',
        visitorIdCard: '110101199001011234',
        totalPrice: 100
      };

      const result = await bookingService.createBooking(bookingData);
      
      expect(result.success).assertTrue();
      expect(result.booking).assertNotNull();
      expect(result.booking!.status).assertEqual(BookingStatus.CONFIRMED);
      expect(result.booking!.visitorName).assertEqual('张三');
    });

    /**
     * 测试预约验证功能
     */
    it('should validate booking data correctly', 0, async function () {
      // 测试无效数据
      const invalidBookingData = {
        museum: testMuseum,
        date: '', // 无效日期
        timeSlot: testTimeSlot,
        visitorCount: 0, // 无效人数
        visitorName: '', // 无效姓名
        visitorPhone: '123', // 无效手机号
        visitorIdCard: '123', // 无效身份证
        totalPrice: 0
      };

      const result = await bookingService.createBooking(invalidBookingData);
      
      expect(result.success).assertFalse();
      expect(result.error).assertNotNull();
    });

    /**
     * 测试取消预约功能
     */
    it('should cancel booking successfully', 0, async function () {
      // 先创建一个预约
      const tomorrow = DateUtils.formatDate(new Date(Date.now() + 24 * 60 * 60 * 1000));
      
      const bookingData = {
        museum: testMuseum,
        date: tomorrow,
        timeSlot: testTimeSlot,
        visitorCount: 1,
        visitorName: '李四',
        visitorPhone: '13900139000',
        visitorIdCard: '110101199001011235',
        totalPrice: 50
      };

      const createResult = await bookingService.createBooking(bookingData);
      expect(createResult.success).assertTrue();

      // 取消预约
      const cancelResult = await bookingService.cancelBooking(createResult.booking!.id);
      
      expect(cancelResult.success).assertTrue();
      
      // 验证预约状态已更新
      const booking = bookingService.getBookingById(createResult.booking!.id);
      expect(booking!.status).assertEqual(BookingStatus.CANCELLED);
    });

    /**
     * 测试时间冲突检测
     */
    it('should detect time conflicts', 0, function () {
      const tomorrow = DateUtils.formatDate(new Date(Date.now() + 24 * 60 * 60 * 1000));
      
      // 模拟已有预约
      const existingBooking: BookingRecord = {
        id: 'test_booking_1',
        museum: testMuseum,
        date: tomorrow,
        timeSlot: testTimeSlot,
        visitorCount: 2,
        visitorName: '王五',
        visitorPhone: '13700137000',
        visitorIdCard: '110101199001011236',
        totalPrice: 100,
        status: BookingStatus.CONFIRMED,
        bookingTime: new Date().toISOString()
      };

      AppStorage.SetOrCreate('userBookings', [existingBooking]);

      // 检查冲突
      const hasConflict = bookingService.hasConflictingBooking(tomorrow, testTimeSlot);
      expect(hasConflict).assertTrue();
    });

    /**
     * 测试获取可用时间段
     */
    it('should get available time slots correctly', 0, function () {
      const tomorrow = DateUtils.formatDate(new Date(Date.now() + 24 * 60 * 60 * 1000));
      
      const timeSlots = bookingService.getAvailableTimeSlots(testMuseum.id, tomorrow);
      
      expect(timeSlots.length).assertLarger(0);
      expect(timeSlots[0].isAvailable).assertTrue();
      expect(timeSlots[0].available).assertEqual(50);
    });

    /**
     * 测试预约统计功能
     */
    it('should calculate booking statistics correctly', 0, async function () {
      // 创建多个测试预约
      const tomorrow = DateUtils.formatDate(new Date(Date.now() + 24 * 60 * 60 * 1000));
      
      const bookings: BookingRecord[] = [
        {
          id: 'stat_test_1',
          museum: testMuseum,
          date: tomorrow,
          timeSlot: testTimeSlot,
          visitorCount: 1,
          visitorName: '统计测试1',
          visitorPhone: '13600136000',
          visitorIdCard: '110101199001011237',
          totalPrice: 50,
          status: BookingStatus.CONFIRMED,
          bookingTime: new Date().toISOString()
        },
        {
          id: 'stat_test_2',
          museum: testMuseum,
          date: tomorrow,
          timeSlot: testTimeSlot,
          visitorCount: 2,
          visitorName: '统计测试2',
          visitorPhone: '13500135000',
          visitorIdCard: '110101199001011238',
          totalPrice: 100,
          status: BookingStatus.COMPLETED,
          bookingTime: new Date().toISOString()
        }
      ];

      AppStorage.SetOrCreate('userBookings', bookings);

      const statistics = bookingService.getBookingStatistics();
      
      expect(statistics.totalBookings).assertEqual(2);
      expect(statistics.confirmedBookings).assertEqual(1);
      expect(statistics.completedBookings).assertEqual(1);
      expect(statistics.totalSpent).assertEqual(100);
    });

    /**
     * 测试即将到来的预约
     */
    it('should get upcoming bookings correctly', 0, function () {
      const tomorrow = DateUtils.formatDate(new Date(Date.now() + 24 * 60 * 60 * 1000));
      const dayAfterTomorrow = DateUtils.formatDate(new Date(Date.now() + 48 * 60 * 60 * 1000));
      
      const bookings: BookingRecord[] = [
        {
          id: 'upcoming_test_1',
          museum: testMuseum,
          date: tomorrow,
          timeSlot: testTimeSlot,
          visitorCount: 1,
          visitorName: '即将测试1',
          visitorPhone: '13400134000',
          visitorIdCard: '110101199001011239',
          totalPrice: 50,
          status: BookingStatus.CONFIRMED,
          bookingTime: new Date().toISOString()
        },
        {
          id: 'upcoming_test_2',
          museum: testMuseum,
          date: dayAfterTomorrow,
          timeSlot: testTimeSlot,
          visitorCount: 1,
          visitorName: '即将测试2',
          visitorPhone: '13300133000',
          visitorIdCard: '110101199001011240',
          totalPrice: 50,
          status: BookingStatus.CONFIRMED,
          bookingTime: new Date().toISOString()
        }
      ];

      AppStorage.SetOrCreate('userBookings', bookings);

      const upcomingBookings = bookingService.getUpcomingBookings();
      
      expect(upcomingBookings.length).assertEqual(2);
      expect(upcomingBookings[0].date).assertEqual(tomorrow); // 应该按时间排序
    });

    /**
     * 测试清理过期预约
     */
    it('should cleanup expired bookings correctly', 0, function () {
      const yesterday = DateUtils.formatDate(new Date(Date.now() - 24 * 60 * 60 * 1000));
      
      const expiredBooking: BookingRecord = {
        id: 'expired_test',
        museum: testMuseum,
        date: yesterday,
        timeSlot: testTimeSlot,
        visitorCount: 1,
        visitorName: '过期测试',
        visitorPhone: '13200132000',
        visitorIdCard: '110101199001011241',
        totalPrice: 50,
        status: BookingStatus.CONFIRMED,
        bookingTime: new Date().toISOString()
      };

      AppStorage.SetOrCreate('userBookings', [expiredBooking]);

      bookingService.cleanupExpiredBookings();

      const bookings = bookingService.getAllBookings();
      expect(bookings[0].status).assertEqual(BookingStatus.COMPLETED);
    });
  });
}