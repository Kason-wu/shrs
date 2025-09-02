/**
 * 日期工具类
 */
export class DateUtils {
  
  /**
   * 格式化日期为 YYYY-MM-DD 格式
   */
  static formatDate(date: Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  /**
   * 格式化日期为中文显示格式
   */
  static formatDateChinese(dateStr: string): string {
    const date = new Date(dateStr);
    const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    const month = date.getMonth() + 1;
    const day = date.getDate();
    const weekday = weekdays[date.getDay()];
    return `${month}月${day}日 ${weekday}`;
  }

  /**
   * 格式化时间戳为显示格式
   */
  static formatDateTime(timeStr: string): string {
    const date = new Date(timeStr);
    const month = date.getMonth() + 1;
    const day = date.getDate();
    const hours = date.getHours();
    const minutes = date.getMinutes();
    return `${month}月${day}日 ${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}`;
  }

  /**
   * 获取未来指定天数的日期数组
   */
  static getFutureDates(days: number): string[] {
    const dates: string[] = [];
    const today = new Date();
    
    for (let i = 1; i <= days; i++) {
      const date = new Date(today);
      date.setDate(today.getDate() + i);
      dates.push(this.formatDate(date));
    }
    
    return dates;
  }

  /**
   * 检查日期是否为今天
   */
  static isToday(dateStr: string): boolean {
    const today = this.formatDate(new Date());
    return dateStr === today;
  }

  /**
   * 检查日期是否为明天
   */
  static isTomorrow(dateStr: string): boolean {
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    return dateStr === this.formatDate(tomorrow);
  }

  /**
   * 获取两个日期之间的天数差
   */
  static getDaysDifference(date1: string, date2: string): number {
    const d1 = new Date(date1);
    const d2 = new Date(date2);
    const timeDiff = Math.abs(d2.getTime() - d1.getTime());
    return Math.ceil(timeDiff / (1000 * 3600 * 24));
  }

  /**
   * 检查日期是否在有效范围内（未来30天内）
   */
  static isValidBookingDate(dateStr: string): boolean {
    const today = new Date();
    const bookingDate = new Date(dateStr);
    const maxDate = new Date();
    maxDate.setDate(today.getDate() + 30);
    
    return bookingDate > today && bookingDate <= maxDate;
  }
}