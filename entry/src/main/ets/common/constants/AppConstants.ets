/**
 * 应用常量定义
 */
export class AppConstants {
  // 颜色常量
  static readonly PRIMARY_COLOR = '#007DFF';
  static readonly BACKGROUND_COLOR = '#F5F5F5';
  static readonly WHITE_COLOR = '#FFFFFF';
  static readonly TEXT_PRIMARY = '#182431';
  static readonly TEXT_SECONDARY = '#99182431';
  static readonly SUCCESS_COLOR = '#00C853';
  static readonly WARNING_COLOR = '#FF9500';
  static readonly ERROR_COLOR = '#FF3B30';
  static readonly ACCENT_COLOR = '#FF6B35';

  // 尺寸常量
  static readonly BORDER_RADIUS_SMALL = 4;
  static readonly BORDER_RADIUS_MEDIUM = 8;
  static readonly BORDER_RADIUS_LARGE = 12;
  static readonly BORDER_RADIUS_ROUND = 20;

  // 间距常量
  static readonly PADDING_SMALL = 8;
  static readonly PADDING_MEDIUM = 12;
  static readonly PADDING_LARGE = 16;
  static readonly PADDING_EXTRA_LARGE = 20;

  // 字体大小常量
  static readonly FONT_SIZE_SMALL = 12;
  static readonly FONT_SIZE_MEDIUM = 14;
  static readonly FONT_SIZE_LARGE = 16;
  static readonly FONT_SIZE_EXTRA_LARGE = 18;
  static readonly FONT_SIZE_TITLE = 20;
  static readonly FONT_SIZE_HEADING = 24;

  // 组件高度常量
  static readonly BUTTON_HEIGHT = 48;
  static readonly INPUT_HEIGHT = 48;
  static readonly NAVBAR_HEIGHT = 56;
  static readonly TAB_HEIGHT = 44;

  // 业务常量
  static readonly MAX_VISITOR_COUNT = 6;
  static readonly MIN_VISITOR_COUNT = 1;
  static readonly BOOKING_ADVANCE_DAYS = 30;
  static readonly DEFAULT_TIME_SLOTS = [
    '09:00-10:00',
    '10:00-11:00', 
    '11:00-12:00',
    '14:00-15:00',
    '15:00-16:00',
    '16:00-17:00'
  ];

  // 存储键名
  static readonly STORAGE_USER_KEY = 'currentUser';
  static readonly STORAGE_LOGIN_KEY = 'isLoggedIn';
  static readonly STORAGE_BOOKINGS_KEY = 'userBookings';
  static readonly STORAGE_FAVORITES_KEY = 'userFavorites';

  // 预约状态
  static readonly BOOKING_STATUS = {
    CONFIRMED: 'confirmed',
    CANCELLED: 'cancelled', 
    COMPLETED: 'completed'
  };

  // 博物馆分类
  static readonly MUSEUM_CATEGORIES = [
    '全部',
    '历史',
    '艺术', 
    '科技',
    '免费'
  ];
}