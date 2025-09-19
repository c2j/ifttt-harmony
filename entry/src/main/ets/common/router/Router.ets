import router from '@ohos.router';

/**
 * 路由路径接口
 */
interface RoutePathsInterface {
  MAIN: string;
  RULES: string;
  RULE_DETAIL: string;
  RULE_EDIT: string;
  RULE_CREATE: string;
  PLUGINS: string;
  PLUGIN_DETAIL: string;
  PLUGIN_SEARCH: string;
  LOGS: string;
  LOG_DETAIL: string;
  PROFILE: string;
  SETTINGS: string;
  BACKUP: string;
  ABOUT: string;
  WELCOME: string;
  ERROR: string;
}

/**
 * 路由路径常量
 */
export const RoutePaths: RoutePathsInterface = {
  // 主页面
  MAIN: 'pages/MainPage',
  
  // 规则管理
  RULES: 'pages/rules/RulesPage',
  RULE_DETAIL: 'pages/rules/RuleDetailPage',
  RULE_EDIT: 'pages/rules/RuleEditPage',
  RULE_CREATE: 'pages/rules/RuleCreatePage',
  
  // 插件市场
  PLUGINS: 'pages/plugins/PluginsPage',
  PLUGIN_DETAIL: 'pages/plugins/PluginDetailPage',
  PLUGIN_SEARCH: 'pages/plugins/PluginSearchPage',
  
  // 日志中心
  LOGS: 'pages/logs/LogsPage',
  LOG_DETAIL: 'pages/logs/LogDetailPage',
  
  // 个人中心
  PROFILE: 'pages/profile/ProfilePage',
  SETTINGS: 'pages/profile/SettingsPage',
  BACKUP: 'pages/profile/BackupPage',
  ABOUT: 'pages/profile/AboutPage',
  
  // 其他页面
  WELCOME: 'pages/WelcomePage',
  ERROR: 'pages/ErrorPage'
};

/**
 * 路由参数接口
 */
export class RouteParams {
  private params: Map<string, string | number | boolean> = new Map();

  set(key: string, value: string | number | boolean): void {
    this.params.set(key, value);
  }

  get(key: string): string | number | boolean | undefined {
    return this.params.get(key);
  }

  has(key: string): boolean {
    return this.params.has(key);
  }

  toObject(): Record<string, string | number | boolean> {
    const obj: Record<string, string | number | boolean> = {};
    this.params.forEach((value, key) => {
      obj[key] = value;
    });
    return obj;
  }
}

/**
 * 路由选项
 */
export interface RouteOptions {
  url: string;
  params?: RouteParams;
}

/**
 * 路由管理器
 */
export class RouterManager {
  private static instance: RouterManager;
  private navigationStack: string[] = [];

  private constructor() {}

  static getInstance(): RouterManager {
    if (!RouterManager.instance) {
      RouterManager.instance = new RouterManager();
    }
    return RouterManager.instance;
  }

  /**
   * 导航到指定页面
   */
  async pushUrl(url: string, params?: RouteParams): Promise<void> {
    try {
      console.info(`[Router] 尝试导航到: ${url}`);
      const options: router.RouterOptions = {
        url: url,
        params: params ? params.toObject() : undefined
      };

      console.info(`[Router] 路由选项:`, JSON.stringify(options));
      await router.pushUrl(options);
      this.navigationStack.push(url);
      console.info(`[Router] 成功导航到: ${url}`);
    } catch (error) {
      console.error(`[Router] 导航失败 ${url}:`, error);
      throw new Error(`Navigation failed: ${error}`);
    }
  }

  /**
   * 替换当前页面
   */
  async replaceUrl(url: string, params?: RouteParams): Promise<void> {
    try {
      const options: router.RouterOptions = {
        url: url,
        params: params ? params.toObject() : undefined
      };

      await router.replaceUrl(options);

      // 更新导航栈
      if (this.navigationStack.length > 0) {
        this.navigationStack[this.navigationStack.length - 1] = url;
      } else {
        this.navigationStack.push(url);
      }

      console.info(`[Router] Replaced with: ${url}`);
    } catch (error) {
      console.error(`[Router] Failed to replace with ${url}:`, error);
      throw new Error(`Replace failed: ${error}`);
    }
  }

  /**
   * 返回上一页
   */
  async back(): Promise<void> {
    try {
      await router.back();
      
      // 更新导航栈
      if (this.navigationStack.length > 0) {
        this.navigationStack.pop();
      }
      
      console.info('[Router] Navigated back');
    } catch (error) {
      console.error('[Router] Failed to go back:', error);
      throw new Error(`Back navigation failed: ${error}`);
    }
  }

  /**
   * 清空导航栈并导航到指定页面
   */
  async clear(): Promise<void> {
    try {
      await router.clear();
      this.navigationStack = [];
      console.info('[Router] Navigation stack cleared');
    } catch (error) {
      console.error('[Router] Failed to clear navigation stack:', error);
      throw new Error(`Clear navigation failed: ${error}`);
    }
  }

  /**
   * 获取当前页面参数
   */
  getParams(): RouteParams {
    try {
      const params = router.getParams() as Record<string, string | number | boolean>;
      const result = new RouteParams();
      if (params) {
        Object.keys(params).forEach(key => {
          result.set(key, params[key]);
        });
      }
      return result;
    } catch (error) {
      console.error('[Router] Failed to get params:', error);
      return new RouteParams();
    }
  }

  /**
   * 获取导航栈长度
   */
  getStackLength(): number {
    return this.navigationStack.length;
  }

  /**
   * 获取当前页面URL
   */
  getCurrentUrl(): string {
    return this.navigationStack.length > 0 
      ? this.navigationStack[this.navigationStack.length - 1] 
      : '';
  }

  /**
   * 检查是否可以返回
   */
  canGoBack(): boolean {
    return this.navigationStack.length > 1;
  }
}

/**
 * 路由工具类
 */
export class RouteUtils {
  
  /**
   * 导航到主页
   */
  static async toMain(params?: RouteParams): Promise<void> {
    return RouterManager.getInstance().pushUrl(RoutePaths.MAIN, params);
  }

  /**
   * 导航到规则列表
   */
  static async toRules(params?: RouteParams): Promise<void> {
    return RouterManager.getInstance().pushUrl(RoutePaths.RULES, params);
  }

  /**
   * 导航到规则详情
   */
  static async toRuleDetail(ruleId: string, params?: RouteParams): Promise<void> {
    const allParams = new RouteParams();
    allParams.set('ruleId', ruleId);
    if (params) {
      const paramsObj = params.toObject();
      Object.keys(paramsObj).forEach(key => {
        allParams.set(key, paramsObj[key]);
      });
    }
    return RouterManager.getInstance().pushUrl(RoutePaths.RULE_DETAIL, allParams);
  }

  /**
   * 导航到规则编辑
   */
  static async toRuleEdit(ruleId: string, params?: RouteParams): Promise<void> {
    const allParams = new RouteParams();
    allParams.set('ruleId', ruleId);
    if (params) {
      const paramsObj = params.toObject();
      Object.keys(paramsObj).forEach(key => {
        allParams.set(key, paramsObj[key]);
      });
    }
    return RouterManager.getInstance().pushUrl(RoutePaths.RULE_EDIT, allParams);
  }

  /**
   * 导航到创建规则
   */
  static async toRuleCreate(params?: RouteParams): Promise<void> {
    return RouterManager.getInstance().pushUrl(RoutePaths.RULE_CREATE, params);
  }

  /**
   * 导航到插件市场
   */
  static async toPlugins(params?: RouteParams): Promise<void> {
    return RouterManager.getInstance().pushUrl(RoutePaths.PLUGINS, params);
  }

  /**
   * 导航到插件详情
   */
  static async toPluginDetail(pluginId: string, params?: RouteParams): Promise<void> {
    const allParams = new RouteParams();
    allParams.set('pluginId', pluginId);
    if (params) {
      const paramsObj = params.toObject();
      Object.keys(paramsObj).forEach(key => {
        allParams.set(key, paramsObj[key]);
      });
    }
    return RouterManager.getInstance().pushUrl(RoutePaths.PLUGIN_DETAIL, allParams);
  }

  /**
   * 导航到插件搜索
   */
  static async toPluginSearch(keyword?: string, params?: RouteParams): Promise<void> {
    const allParams = new RouteParams();
    if (keyword) {
      allParams.set('keyword', keyword);
    }
    if (params) {
      const paramsObj = params.toObject();
      Object.keys(paramsObj).forEach(key => {
        allParams.set(key, paramsObj[key]);
      });
    }
    return RouterManager.getInstance().pushUrl(RoutePaths.PLUGIN_SEARCH, allParams);
  }

  /**
   * 导航到日志中心
   */
  static async toLogs(params?: RouteParams): Promise<void> {
    return RouterManager.getInstance().pushUrl(RoutePaths.LOGS, params);
  }

  /**
   * 导航到日志详情
   */
  static async toLogDetail(logId: string, params?: RouteParams): Promise<void> {
    const allParams = new RouteParams();
    allParams.set('logId', logId);
    if (params) {
      const paramsObj = params.toObject();
      Object.keys(paramsObj).forEach(key => {
        allParams.set(key, paramsObj[key]);
      });
    }
    return RouterManager.getInstance().pushUrl(RoutePaths.LOG_DETAIL, allParams);
  }

  /**
   * 导航到个人中心
   */
  static async toProfile(params?: RouteParams): Promise<void> {
    return RouterManager.getInstance().pushUrl(RoutePaths.PROFILE, params);
  }

  /**
   * 导航到设置页面
   */
  static async toSettings(params?: RouteParams): Promise<void> {
    return RouterManager.getInstance().pushUrl(RoutePaths.SETTINGS, params);
  }

  /**
   * 导航到备份页面
   */
  static async toBackup(params?: RouteParams): Promise<void> {
    return RouterManager.getInstance().pushUrl(RoutePaths.BACKUP, params);
  }

  /**
   * 导航到关于页面
   */
  static async toAbout(params?: RouteParams): Promise<void> {
    return RouterManager.getInstance().pushUrl(RoutePaths.ABOUT, params);
  }

  /**
   * 返回上一页
   */
  static async back(): Promise<void> {
    return RouterManager.getInstance().back();
  }

  /**
   * 获取当前页面参数
   */
  static getParams(): RouteParams {
    return RouterManager.getInstance().getParams();
  }

  /**
   * 检查是否可以返回
   */
  static canGoBack(): boolean {
    return RouterManager.getInstance().canGoBack();
  }
}

/**
 * 全局路由管理器实例
 */
export const routerManager = RouterManager.getInstance();
