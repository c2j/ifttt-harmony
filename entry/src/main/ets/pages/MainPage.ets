import { LoadingComponent } from '../common/components/LoadingComponent';
import { appStore } from '../common/store/AppStore';
import { RouteUtils } from '../common/router/Router';
import { RulesPage } from './rules/RulesPage'
import { PluginsPage } from './plugins/PluginsPage'
import { LogsPage } from './logs/LogsPage'
import { ProfilePage } from './profile/ProfilePage';

/**
 * 主页面 - 使用TabBar导航
 */
@Component
export struct MainPage {
  @State currentTabIndex: number = 0;
  @State isLoading: boolean = false;
  @State showNavigationSplitView: boolean = false;

  // Tab标签数据
  private tabsData: TabItem[] = [
    {
      index: 0,
      title: '规则',
      iconText: '⚙️'
    },
    {
      index: 1,
      title: '插件',
      iconText: '🧩'
    },
    {
      index: 2,
      title: '日志',
      iconText: '📋'
    },
    {
      index: 3,
      title: '我的',
      iconText: '👤'
    }
  ];

  aboutToAppear() {
    this.initializeApp();
    this.checkScreenSize();
  }

  /**
   * 初始化应用
   */
  private async initializeApp() {
    this.isLoading = true;
    
    try {
      // 初始化应用状态
      console.info('[MainPage] Initializing app...');
      
      // 这里可以添加初始化逻辑，比如：
      // - 检查网络状态
      // - 加载用户配置
      // - 同步数据等
      
      await this.delay(1000); // 模拟初始化时间
      
    } catch (error) {
      console.error('[MainPage] Failed to initialize app:', error);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 检查屏幕尺寸，决定是否使用NavigationSplitView
   */
  private checkScreenSize() {
    // 这里可以根据屏幕尺寸决定布局
    // 暂时使用TabBar布局
    this.showNavigationSplitView = false;
  }

  /**
   * 延迟函数
   */
  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  build() {
    Stack() {
      if (this.showNavigationSplitView) {
        // 大屏幕使用NavigationSplitView
        this.buildNavigationSplitView();
      } else {
        // 小屏幕使用TabBar
        this.buildTabBarView();
      }

      // 全局加载组件
      LoadingComponent({
        visible: this.isLoading,
        message: '初始化中...'
      })
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 构建TabBar视图
   */
  @Builder
  buildTabBarView() {
    Tabs({
      barPosition: BarPosition.End,
      index: this.currentTabIndex
    }) {
      ForEach(this.tabsData, (item: TabItem) => {
        TabContent() {
          this.buildTabContent(item.index)
        }
        .tabBar(this.buildTabBar(item))
      })
    }
    .width('100%')
    .height('100%')
    .barBackgroundColor(Color.White)
    .onChange((index: number) => {
      this.currentTabIndex = index;
      console.info(`[MainPage] Tab changed to: ${index}`);
    })
  }

  /**
   * 构建NavigationSplitView（大屏幕）
   */
  @Builder
  buildNavigationSplitView() {
    Row() {
      // 侧边栏
      Column({ space: 8 }) {
        ForEach(this.tabsData, (item: TabItem) => {
          this.buildSideBarItem(item)
        })
      }
      .width(200)
      .height('100%')
      .padding(16)
      .backgroundColor('#F5F5F5')

      // 主内容区
      Column() {
        this.buildTabContent(this.currentTabIndex)
      }
      .layoutWeight(1)
      .height('100%')
      .backgroundColor(Color.White)
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 构建Tab标签
   */
  @Builder
  buildTabBar(item: TabItem) {
    Column({ space: 4 }) {
      Text(item.iconText)
        .fontSize(20)
        .fontColor(this.currentTabIndex === item.index ? Color.Blue : Color.Gray)

      Text(item.title)
        .fontSize(12)
        .fontColor(this.currentTabIndex === item.index ? Color.Blue : Color.Gray)
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  /**
   * 构建侧边栏项目
   */
  @Builder
  buildSideBarItem(item: TabItem) {
    Row({ space: 12 }) {
      Text(item.iconText)
        .fontSize(18)
        .fontColor(this.currentTabIndex === item.index ? Color.Blue : Color.Gray)

      Text(item.title)
        .fontSize(16)
        .fontColor(this.currentTabIndex === item.index ? Color.Blue : Color.Black)
        .fontWeight(this.currentTabIndex === item.index ? FontWeight.Medium : FontWeight.Normal)
    }
    .width('100%')
    .height(48)
    .padding({ left: 16, right: 16 })
    .borderRadius(8)
    .backgroundColor(this.currentTabIndex === item.index ? '#E3F2FD' : Color.Transparent)
    .onClick(() => {
      this.currentTabIndex = item.index;
    })
  }

  /**
   * 构建Tab内容
   */
  @Builder
  buildTabContent(index: number) {
    if (index === 0) {
      this.buildRulesPage();
    } else if (index === 1) {
      this.buildPluginsPage();
    } else if (index === 2) {
      this.buildLogsPage();
    } else if (index === 3) {
      this.buildProfilePage();
    } else {
      this.buildDefaultPage();
    }
  }

  /**
   * 规则页面
   */
  @Builder
  buildRulesPage() {
    RulesPage()
  }

  /**
   * 插件页面
   */
  @Builder
  buildPluginsPage() {
    Column() {
      PluginsPage()
    }
  }

  /**
   * 日志页面
   */
  @Builder
  buildLogsPage() {
    Column() {
      LogsPage()
    }
  }

  /**
   * 个人中心页面
   */
  @Builder
  buildProfilePage() {
    Column() {
      ProfilePage()
    }
  }

  /**
   * 默认页面
   */
  @Builder
  buildDefaultPage() {
    Column() {
      Text('页面开发中...')
        .fontSize(16)
        .fontColor(Color.Gray)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#F8F9FA')
  }
}

/**
 * Tab项目接口
 */
interface TabItem {
  index: number;
  title: string;
  iconText: string;
}
