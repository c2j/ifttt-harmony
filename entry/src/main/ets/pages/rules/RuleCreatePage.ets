import { Rule, RuleStatus, RuleTrigger, RuleCondition, RuleAction, TriggerType, ActionType } from '../../common/types/RuleTypes';
import { ruleService } from '../../common/services/RuleService';
import { RouteUtils } from '../../common/router/Router';
import { LoadingComponent } from '../../common/components/LoadingComponent';

/**
 * 创建规则页面
 */
@Entry
@Component
export struct RuleCreatePage {
  @State ruleName: string = '';
  @State ruleDescription: string = '';
  @State isLoading: boolean = false;
  @State selectedTrigger: string = '';
  @State selectedAction: string = '';

  // 可用的触发器和动作选项
  private triggerOptions: string[] = ['时间触发', '位置触发', '设备状态', '网络请求'];
  private actionOptions: string[] = ['发送通知', '执行命令', '调用API', '记录日志'];

  /**
   * 创建规则
   */
  private async createRule(): Promise<void> {
    if (!this.ruleName.trim()) {
      console.warn('规则名称不能为空');
      return;
    }

    if (!this.selectedTrigger || !this.selectedAction) {
      console.warn('请选择触发器和动作');
      return;
    }

    this.isLoading = true;
    
    try {
      const newRule: Rule = {
        id: `rule_${Date.now()}`,
        name: this.ruleName.trim(),
        description: this.ruleDescription.trim(),
        status: RuleStatus.ENABLED,
        enabled: true,
        createdAt: Date.now(),
        updatedAt: Date.now(),
        lastExecuted: undefined,
        executionCount: 0,
        successCount: 0,
        failureCount: 0,
        trigger: this.createTrigger(),
        conditions: [],
        actions: [this.createAction()]
      };

      const success = await ruleService.createRule(newRule);
      if (success) {
        console.info('规则创建成功');
        RouteUtils.back();
      }
    } catch (error) {
      console.error('创建规则失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 创建触发器
   */
  private createTrigger(): RuleTrigger {
    return {
      id: `trigger_${Date.now()}`,
      type: TriggerType.MANUAL,
      pluginId: 'system',
      pluginName: '系统',
      name: this.selectedTrigger,
      config: {},
      enabled: true
    };
  }

  /**
   * 创建动作
   */
  private createAction(): RuleAction {
    return {
      id: `action_${Date.now()}`,
      type: ActionType.NOTIFICATION,
      pluginId: 'system',
      pluginName: '系统',
      name: this.selectedAction,
      config: {},
      enabled: true,
      order: 1
    };
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Button('返回')
          .fontSize(16)
          .backgroundColor(Color.Transparent)
          .fontColor(Color.Blue)
          .onClick(() => {
            RouteUtils.back();
          })

        Text('创建规则')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button('保存')
          .fontSize(16)
          .backgroundColor(Color.Blue)
          .fontColor(Color.White)
          .borderRadius(8)
          .enabled(!this.isLoading)
          .onClick(() => {
            this.createRule();
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)

      Scroll() {
        Column() {
          // 基本信息
          Column() {
            Text('基本信息')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 12 })

            TextInput({ placeholder: '请输入规则名称', text: this.ruleName })
              .width('100%')
              .height(40)
              .margin({ bottom: 12 })
              .onChange((value: string) => {
                this.ruleName = value;
              })

            TextArea({ placeholder: '请输入规则描述（可选）', text: this.ruleDescription })
              .width('100%')
              .height(80)
              .onChange((value: string) => {
                this.ruleDescription = value;
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .margin({ bottom: 16 })

          // 触发器选择
          Column() {
            Text('选择触发器')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 12 })

            ForEach(this.triggerOptions, (option: string) => {
              Row() {
                Radio({ value: option, group: 'trigger' })
                  .checked(this.selectedTrigger === option)
                  .onChange((isChecked: boolean) => {
                    if (isChecked) {
                      this.selectedTrigger = option;
                    }
                  })

                Text(option)
                  .fontSize(14)
                  .margin({ left: 8 })
                  .layoutWeight(1)
              }
              .width('100%')
              .height(40)
              .onClick(() => {
                this.selectedTrigger = option;
              })
            })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .margin({ bottom: 16 })

          // 动作选择
          Column() {
            Text('选择动作')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 12 })

            ForEach(this.actionOptions, (option: string) => {
              Row() {
                Radio({ value: option, group: 'action' })
                  .checked(this.selectedAction === option)
                  .onChange((isChecked: boolean) => {
                    if (isChecked) {
                      this.selectedAction = option;
                    }
                  })

                Text(option)
                  .fontSize(14)
                  .margin({ left: 8 })
                  .layoutWeight(1)
              }
              .width('100%')
              .height(40)
              .onClick(() => {
                this.selectedAction = option;
              })
            })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .margin({ bottom: 16 })
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')

      // 加载状态
      if (this.isLoading) {
        LoadingComponent({ loadingSize: 40 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
