/**
 * 表单验证工具类
 */
export class ValidationUtils {
  
  /**
   * 验证手机号格式
   */
  static validatePhone(phone: string): boolean {
    const phoneRegex = /^1[3-9]\d{9}$/;
    return phoneRegex.test(phone);
  }

  /**
   * 验证邮箱格式
   */
  static validateEmail(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  /**
   * 验证身份证号格式
   */
  static validateIdCard(idCard: string): boolean {
    const idCardRegex = /^\d{17}[\dXx]$/;
    return idCardRegex.test(idCard);
  }

  /**
   * 验证用户名格式（2-20个字符，支持中英文数字下划线）
   */
  static validateUsername(username: string): boolean {
    if (!username || username.length < 2 || username.length > 20) {
      return false;
    }
    const usernameRegex = /^[\u4e00-\u9fa5a-zA-Z0-9_]+$/;
    return usernameRegex.test(username);
  }

  /**
   * 验证密码强度（至少6位，包含字母和数字）
   */
  static validatePassword(password: string): boolean {
    if (!password || password.length < 6) {
      return false;
    }
    const hasLetter = /[a-zA-Z]/.test(password);
    const hasNumber = /\d/.test(password);
    return hasLetter && hasNumber;
  }

  /**
   * 验证姓名格式（2-10个中文字符或英文字符）
   */
  static validateName(name: string): boolean {
    if (!name || name.length < 2 || name.length > 10) {
      return false;
    }
    const nameRegex = /^[\u4e00-\u9fa5a-zA-Z\s]+$/;
    return nameRegex.test(name);
  }

  /**
   * 验证参观人数
   */
  static validateVisitorCount(count: number): boolean {
    return count >= 1 && count <= 6;
  }

  /**
   * 获取验证错误信息
   */
  static getValidationMessage(field: string, value: string): string {
    switch (field) {
      case 'username':
        if (!value.trim()) return '请输入用户名';
        if (!this.validateUsername(value)) return '用户名格式不正确（2-20个字符）';
        break;
      case 'email':
        if (!value.trim()) return '请输入邮箱地址';
        if (!this.validateEmail(value)) return '请输入有效的邮箱地址';
        break;
      case 'phone':
        if (!value.trim()) return '请输入手机号码';
        if (!this.validatePhone(value)) return '请输入有效的手机号码';
        break;
      case 'password':
        if (!value.trim()) return '请输入密码';
        if (!this.validatePassword(value)) return '密码至少6位，包含字母和数字';
        break;
      case 'name':
        if (!value.trim()) return '请输入姓名';
        if (!this.validateName(value)) return '请输入有效的姓名';
        break;
      case 'idCard':
        if (!value.trim()) return '请输入身份证号码';
        if (!this.validateIdCard(value)) return '请输入有效的身份证号码';
        break;
      default:
        return '输入格式不正确';
    }
    return '';
  }

  /**
   * 批量验证表单字段
   */
  static validateForm(fields: Record<string, string>): { isValid: boolean; errors: Record<string, string> } {
    const errors: Record<string, string> = {};
    let isValid = true;

    for (const [field, value] of Object.entries(fields)) {
      const error = this.getValidationMessage(field, value);
      if (error) {
        errors[field] = error;
        isValid = false;
      }
    }

    return { isValid, errors };
  }
}