import { AppStore } from '../../common/store/AppStore'
import { LoadingComponent } from '../../common/components/LoadingComponent'

/**
 * 菜单项接口
 */
interface MenuItem {
  title: string;
  icon: string;
  action: () => void;
}

/**
 * 用户信息接口
 */
interface UserInfo {
  name: string;
  nickname: string;
  email: string;
  phone: string;
  avatar: string;
  deviceId: string;
  version: string;
  rulesCount: number;
  pluginsCount: number;
  executionsCount: number;
}

@Entry
@Component
export struct ProfilePage {
  @StorageLink('appStore') appStore: AppStore = AppStore.getInstance()
  @State userInfo: UserInfo | null = null
  @State isLoading: boolean = false
  
  aboutToAppear() {
    this.loadUserInfo()
  }
  
  async loadUserInfo() {
    this.isLoading = true
    try {
      // TODO: 调用 API 获取用户信息
      // 模拟数据
      this.userInfo = {
        name: '用户123456',
        nickname: '用户123456',
        avatar: '',
        email: 'user@example.com',
        phone: '138****8888',
        deviceId: 'device123',
        version: '1.0.0',
        rulesCount: 12,
        pluginsCount: 8,
        executionsCount: 156
      }
    } catch (error) {
      console.error('加载用户信息失败:', error)
    } finally {
      this.isLoading = false
    }
  }

  build() {
    Column() {
      if (this.isLoading) {
        LoadingComponent()
      } else {
        // 用户信息卡片
        Column() {
          Row() {
            // 头像
            Image(this.userInfo?.avatar || $r('app.media.startIcon'))
              .width(60)
              .height(60)
              .borderRadius(30)
              .margin({ right: 16 })
            
            // 用户信息
            Column() {
              Text(this.userInfo?.nickname || '未登录')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
              
              Text(this.userInfo?.email || '')
                .fontSize(14)
                .fontColor('#666666')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .flexGrow(1)
            
            // 编辑按钮
            Button('编辑')
              .fontSize(14)
              .backgroundColor('#F0F0F0')
              .fontColor('#333333')
              .borderRadius(6)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .onClick(() => this.editProfile())
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
          
          // 统计信息
          Row() {
            Column() {
              Text(this.userInfo?.rulesCount?.toString() || '0')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#007AFF')
              Text('规则数')
                .fontSize(12)
                .fontColor('#666666')
                .margin({ top: 4 })
            }
            .flexGrow(1)
            
            Column() {
              Text(this.userInfo?.pluginsCount?.toString() || '0')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#52C41A')
              Text('插件数')
                .fontSize(12)
                .fontColor('#666666')
                .margin({ top: 4 })
            }
            .flexGrow(1)
            
            Column() {
              Text(this.userInfo?.executionsCount?.toString() || '0')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FF6B35')
              Text('执行次数')
                .fontSize(12)
                .fontColor('#666666')
                .margin({ top: 4 })
            }
            .flexGrow(1)
          }
          .width('100%')
          .margin({ top: 20 })
        }
        .width('100%')
        .backgroundColor(Color.White)
        .borderRadius(12)
        .padding(20)
        .margin({ bottom: 20 })
        .shadow({
          radius: 8,
          color: '#00000010',
          offsetX: 0,
          offsetY: 2
        })
        
        // 功能菜单
        Column() {
          this.MenuSection('账户设置', this.createAccountMenuItems())
          
          this.MenuSection('数据管理', this.createDataMenuItems())
          
          this.MenuSection('其他', this.createOtherMenuItems())
          
          // 退出登录按钮
          Button('退出登录')
            .width('100%')
            .height(48)
            .fontSize(16)
            .backgroundColor('#FF4D4F')
            .borderRadius(8)
            .margin({ top: 20 })
            .onClick(() => this.logout())
        }
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#F5F5F5')
  }
  
  @Builder
  MenuSection(title: string, items: MenuItem[]) {
    Column() {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 12 })
        .alignSelf(ItemAlign.Start)
      
      Column() {
        ForEach(items, (item: MenuItem, index: number) => {
          Row() {
            Text(item.icon)
              .fontSize(20)
              .margin({ right: 12 })
            
            Text(item.title)
              .fontSize(16)
              .flexGrow(1)
            
            Text('>')
              .fontSize(16)
              .fontColor('#CCCCCC')
          }
          .width('100%')
          .height(48)
          .padding({ left: 16, right: 16 })
          .onClick(item.action)
          
          if (index < items.length - 1) {
            Divider()
              .color('#F0F0F0')
              .margin({ left: 48 })
          }
        })
      }
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius(8)
    }
    .width('100%')
    .margin({ bottom: 20 })
  }

  /**
   * 创建账户设置菜单项
   */
  private createAccountMenuItems(): MenuItem[] {
    return [
      this.createMenuItem('个人信息', '👤', () => this.editProfile()),
      this.createMenuItem('安全设置', '🔒', () => this.securitySettings()),
      this.createMenuItem('通知设置', '🔔', () => this.notificationSettings())
    ];
  }

  /**
   * 创建数据管理菜单项
   */
  private createDataMenuItems(): MenuItem[] {
    return [
      this.createMenuItem('备份数据', '☁️', () => this.backupData()),
      this.createMenuItem('恢复数据', '📥', () => this.restoreData()),
      this.createMenuItem('清除缓存', '🗑️', () => this.clearCache())
    ];
  }

  /**
   * 创建其他菜单项
   */
  private createOtherMenuItems(): MenuItem[] {
    return [
      this.createMenuItem('帮助中心', '❓', () => this.helpCenter()),
      this.createMenuItem('意见反馈', '💬', () => this.feedback()),
      this.createMenuItem('关于应用', 'ℹ️', () => this.aboutApp())
    ];
  }

  /**
   * 创建菜单项
   */
  private createMenuItem(title: string, icon: string, action: () => void): MenuItem {
    return {
      title: title,
      icon: icon,
      action: action
    };
  }

  editProfile(): void {
    console.log('编辑个人信息')
    // TODO: 跳转到编辑页面
  }

  securitySettings(): void {
    console.log('安全设置')
    // TODO: 跳转到安全设置页面
  }

  notificationSettings(): void {
    console.log('通知设置')
    // TODO: 跳转到通知设置页面
  }

  backupData(): void {
    console.log('备份数据')
    // TODO: 实现数据备份
  }

  restoreData(): void {
    console.log('恢复数据')
    // TODO: 实现数据恢复
  }

  clearCache(): void {
    console.log('清除缓存')
    // TODO: 实现清除缓存
  }

  helpCenter(): void {
    console.log('帮助中心')
    // TODO: 跳转到帮助中心
  }

  feedback(): void {
    console.log('意见反馈')
    // TODO: 跳转到反馈页面
  }

  aboutApp(): void {
    console.log('关于应用')
    // TODO: 显示应用信息
  }
  
  logout() {
    console.log('退出登录')
    // TODO: 实现退出登录
  }
}
