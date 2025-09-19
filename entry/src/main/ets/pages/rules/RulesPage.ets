import { Rule, RuleStatus } from '../../common/types/RuleTypes';
import { ruleService } from '../../common/services/RuleService';
import { RouteUtils } from '../../common/router/Router';
import { LoadingComponent, RefreshLoading } from '../../common/components/LoadingComponent';

/**
 * 状态选项接口
 */
interface StatusOption {
  value: string;
  label: string;
}

/**
 * 规则列表页面
 */
@Component
export struct RulesPage {
  @State rules: Rule[] = [];
  @State isLoading: boolean = false;
  @State isRefreshing: boolean = false;
  @State searchKeyword: string = '';
  @State selectedStatus: string = 'all';
  @State showSearchBar: boolean = false;

  // 状态选项
  private statusOptions: StatusOption[] = [
    this.createStatusOption('all', '全部'),
    this.createStatusOption('enabled', '已启用'),
    this.createStatusOption('disabled', '已禁用'),
    this.createStatusOption('error', '错误')
  ];

  /**
   * 创建状态选项
   */
  private createStatusOption(value: string, label: string): StatusOption {
    return {
      value: value,
      label: label
    };
  }

  /**
   * 创建搜索参数
   */
  private createSearchParams(): Record<string, string | number | boolean> {
    const params: Record<string, string | number | boolean> = {};

    if (this.searchKeyword) {
      params.keyword = this.searchKeyword;
    }

    if (this.selectedStatus !== 'all') {
      params.status = this.selectedStatus;
    }

    params.sortBy = 'updatedAt';
    params.sortOrder = 'desc';

    return params;
  }

  aboutToAppear() {
    this.loadRules();
  }

  /**
   * 加载规则列表
   */
  private async loadRules() {
    this.isLoading = true;
    
    try {
      const searchParams = this.createSearchParams();
      
      this.rules = await ruleService.getRules(searchParams);
      console.info(`[RulesPage] Loaded ${this.rules.length} rules`);
    } catch (error) {
      console.error('[RulesPage] Failed to load rules:', error);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 刷新规则列表
   */
  private async refreshRules() {
    this.isRefreshing = true;
    await this.loadRules();
    this.isRefreshing = false;
  }

  /**
   * 搜索规则
   */
  private async searchRules() {
    await this.loadRules();
  }

  /**
   * 切换规则状态
   */
  private async toggleRule(rule: Rule) {
    try {
      const updatedRule = await ruleService.toggleRule(rule.id, !rule.enabled);
      if (updatedRule) {
        // 更新本地状态
        const index = this.rules.findIndex(r => r.id === rule.id);
        if (index >= 0) {
          this.rules[index] = updatedRule;
        }
      }
    } catch (error) {
      console.error('[RulesPage] Failed to toggle rule:', error);
    }
  }

  /**
   * 删除规则
   */
  private async deleteRule(rule: Rule) {
    try {
      const success = await ruleService.deleteRule(rule.id);
      if (success) {
        this.rules = this.rules.filter(r => r.id !== rule.id);
      }
    } catch (error) {
      console.error('[RulesPage] Failed to delete rule:', error);
    }
  }

  build() {
    Column() {
      // 标题栏
      this.buildHeader()

      // 搜索栏
      if (this.showSearchBar) {
        this.buildSearchBar()
      }

      // 筛选栏
      this.buildFilterBar()

      // 刷新指示器
      RefreshLoading({
        refreshing: this.isRefreshing,
        message: '正在刷新规则列表...'
      })

      // 规则列表
      if (this.isLoading) {
        LoadingComponent({
          visible: true,
          message: '加载规则中...'
        })
      } else {
        this.buildRuleList()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }

  /**
   * 构建标题栏
   */
  @Builder
  buildHeader() {
    Row() {
      Text('规则管理')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)

      // 搜索按钮
      Button() {
        Text('🔍')
          .fontSize(16)
      }
      .width(40)
      .height(40)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        this.showSearchBar = !this.showSearchBar;
      })

      // 新建按钮
      Button('新建')
        .fontSize(14)
        .backgroundColor(Color.Blue)
        .borderRadius(16)
        .margin({ left: 8 })
        .onClick(async () => {
          console.info('[RulesPage] 新建按钮被点击');
          try {
            await RouteUtils.toRuleCreate();
            console.info('[RulesPage] 路由跳转成功');
          } catch (error) {
            console.error('[RulesPage] 路由跳转失败:', error);
          }
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
  }

  /**
   * 构建搜索栏
   */
  @Builder
  buildSearchBar() {
    Row({ space: 8 }) {
      TextInput({ placeholder: '搜索规则名称或描述' })
        .layoutWeight(1)
        .onChange((value: string) => {
          this.searchKeyword = value;
        })
        .onSubmit(() => {
          this.searchRules();
        })

      Button('搜索')
        .fontSize(14)
        .backgroundColor(Color.Blue)
        .onClick(() => {
          this.searchRules();
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
  }

  /**
   * 构建筛选栏
   */
  @Builder
  buildFilterBar() {
    Row({ space: 8 }) {
      Text('状态:')
        .fontSize(14)
        .fontColor(Color.Gray)

      ForEach(this.statusOptions, (option: StatusOption) => {
        Button(option.label)
          .fontSize(12)
          .backgroundColor(this.selectedStatus === option.value ? Color.Blue : '#E0E0E0')
          .fontColor(this.selectedStatus === option.value ? Color.White : Color.Black)
          .borderRadius(12)
          .padding({ left: 12, right: 12, top: 4, bottom: 4 })
          .onClick(() => {
            this.selectedStatus = option.value;
            this.loadRules();
          })
      })

      Blank()

      Button('刷新')
        .fontSize(12)
        .backgroundColor('#E0E0E0')
        .fontColor(Color.Black)
        .borderRadius(12)
        .padding({ left: 12, right: 12, top: 4, bottom: 4 })
        .onClick(() => {
          this.refreshRules();
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .backgroundColor(Color.White)
  }

  /**
   * 构建规则列表
   */
  @Builder
  buildRuleList() {
    if (this.rules.length === 0) {
      Column() {
        Text('📝')
          .fontSize(48)
          .margin({ bottom: 16 })

        Text('暂无规则')
          .fontSize(16)
          .fontColor(Color.Gray)
          .margin({ bottom: 8 })

        Text('点击右上角"新建"按钮创建第一个规则')
          .fontSize(14)
          .fontColor('#999999')

        Button('立即创建')
          .fontSize(14)
          .backgroundColor(Color.Blue)
          .borderRadius(16)
          .margin({ top: 20 })
          .onClick(() => {
            RouteUtils.toRuleCreate();
          })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    } else {
      List({ space: 8 }) {
        ForEach(this.rules, (rule: Rule) => {
          ListItem() {
            this.buildRuleItem(rule)
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .scrollBar(BarState.Auto)
    }
  }

  /**
   * 构建规则项
   */
  @Builder
  buildRuleItem(rule: Rule) {
    Column() {
      Row() {
        // 状态指示器
        Circle()
          .width(8)
          .height(8)
          .fill(this.getStatusColor(rule.status))
          .margin({ right: 12 })

        // 规则信息
        Column({ space: 4 }) {
          Text(rule.name)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          if (rule.description) {
            Text(rule.description)
              .fontSize(14)
              .fontColor('#666666')
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }

          Row({ space: 16 }) {
            Text(`触发器: ${rule.trigger.pluginName}`)
              .fontSize(12)
              .fontColor('#999999')

            Text(`动作: ${rule.actions.length}个`)
              .fontSize(12)
              .fontColor('#999999')

            Text(`执行: ${rule.executionCount}次`)
              .fontSize(12)
              .fontColor('#999999')
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        // 开关
        Toggle({ type: ToggleType.Switch, isOn: rule.enabled })
          .onChange((isOn: boolean) => {
            this.toggleRule(rule);
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      // 操作按钮
      Row({ space: 8 }) {
        Button('详情')
          .fontSize(12)
          .backgroundColor('#E3F2FD')
          .fontColor(Color.Blue)
          .borderRadius(8)
          .onClick(() => {
            RouteUtils.toRuleDetail(rule.id);
          })

        Button('编辑')
          .fontSize(12)
          .backgroundColor('#E8F5E8')
          .fontColor('#4CAF50')
          .borderRadius(8)
          .onClick(() => {
            RouteUtils.toRuleEdit(rule.id);
          })

        Button('删除')
          .fontSize(12)
          .backgroundColor('#FFEBEE')
          .fontColor('#F44336')
          .borderRadius(8)
          .onClick(() => {
            this.deleteRule(rule);
          })

        Blank()

        Text(this.formatTime(rule.updatedAt))
          .fontSize(12)
          .fontColor('#999999')
      }
      .width('100%')
      .margin({ top: 8 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .shadow({
      radius: 4,
      color: '#00000010',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      RouteUtils.toRuleDetail(rule.id);
    })
  }

  /**
   * 获取状态颜色
   */
  private getStatusColor(status: RuleStatus): Color {
    switch (status) {
      case RuleStatus.ENABLED:
        return Color.Green;
      case RuleStatus.DISABLED:
        return Color.Gray;
      case RuleStatus.ERROR:
        return Color.Red;
      default:
        return Color.Gray;
    }
  }

  /**
   * 格式化时间
   */
  private formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    const now = new Date();
    const diff = now.getTime() - date.getTime();

    if (diff < 60000) { // 1分钟内
      return '刚刚';
    } else if (diff < 3600000) { // 1小时内
      return `${Math.floor(diff / 60000)}分钟前`;
    } else if (diff < 86400000) { // 1天内
      return `${Math.floor(diff / 3600000)}小时前`;
    } else {
      return `${date.getMonth() + 1}/${date.getDate()}`;
    }
  }
}
