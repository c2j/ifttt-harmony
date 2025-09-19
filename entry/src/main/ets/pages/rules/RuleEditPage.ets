import { Rule, RuleStatus } from '../../common/types/RuleTypes';
import { ruleService } from '../../common/services/RuleService';
import { RouteUtils } from '../../common/router/Router';
import { LoadingComponent } from '../../common/components/LoadingComponent';
import router from '@ohos.router';

/**
 * 编辑规则页面
 */
@Entry
@Component
export struct RuleEditPage {
  @State rule: Rule | null = null;
  @State isLoading: boolean = true;
  @State isSaving: boolean = false;
  @State ruleId: string = '';
  @State ruleName: string = '';
  @State ruleDescription: string = '';

  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as Record<string, string>;
    if (params && params.ruleId) {
      this.ruleId = params.ruleId;
      this.loadRuleDetail();
    }
  }

  /**
   * 加载规则详情
   */
  private async loadRuleDetail(): Promise<void> {
    this.isLoading = true;
    
    try {
      this.rule = await ruleService.getRuleById(this.ruleId);
      if (this.rule) {
        this.ruleName = this.rule.name;
        this.ruleDescription = this.rule.description || '';
      }
    } catch (error) {
      console.error('加载规则详情失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 保存规则
   */
  private async saveRule(): Promise<void> {
    if (!this.rule || !this.ruleName.trim()) {
      console.warn('规则名称不能为空');
      return;
    }

    this.isSaving = true;
    
    try {
      const updatedRule: Rule = {
        id: this.rule.id,
        name: this.ruleName.trim(),
        description: this.ruleDescription.trim(),
        enabled: this.rule.enabled,
        status: this.rule.status,
        createdAt: this.rule.createdAt,
        updatedAt: Date.now(),
        lastExecuted: this.rule.lastExecuted,
        executionCount: this.rule.executionCount,
        successCount: this.rule.successCount,
        failureCount: this.rule.failureCount,
        trigger: this.rule.trigger,
        conditions: this.rule.conditions,
        actions: this.rule.actions
      };

      const success = await ruleService.updateRule(updatedRule);
      if (success) {
        console.info('规则更新成功');
        RouteUtils.back();
      }
    } catch (error) {
      console.error('保存规则失败:', error);
    } finally {
      this.isSaving = false;
    }
  }

  /**
   * 格式化时间
   */
  private formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')} ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Button('取消')
          .fontSize(16)
          .backgroundColor(Color.Transparent)
          .fontColor(Color.Blue)
          .onClick(() => {
            RouteUtils.back();
          })

        Text('编辑规则')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button('保存')
          .fontSize(16)
          .backgroundColor(Color.Blue)
          .fontColor(Color.White)
          .borderRadius(8)
          .enabled(!this.isSaving)
          .onClick(() => {
            this.saveRule();
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)

      if (this.isLoading) {
        LoadingComponent({ loadingSize: 40 })
          .layoutWeight(1)
      } else if (this.rule) {
        Scroll() {
          Column() {
            // 基本信息编辑
            Column() {
              Text('基本信息')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 12 })

              Text('规则名称')
                .fontSize(14)
                .fontColor('#666666')
                .alignSelf(ItemAlign.Start)
                .margin({ bottom: 8 })

              TextInput({ placeholder: '请输入规则名称', text: this.ruleName })
                .width('100%')
                .height(40)
                .margin({ bottom: 16 })
                .onChange((value: string) => {
                  this.ruleName = value;
                })

              Text('规则描述')
                .fontSize(14)
                .fontColor('#666666')
                .alignSelf(ItemAlign.Start)
                .margin({ bottom: 8 })

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

            // 规则信息（只读）
            Column() {
              Text('规则信息')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 12 })

              Row() {
                Text('规则ID:')
                  .fontSize(14)
                  .fontColor('#666666')
                  .width(80)

                Text(this.rule.id)
                  .fontSize(14)
                  .layoutWeight(1)
              }
              .width('100%')
              .margin({ bottom: 8 })

              Row() {
                Text('状态:')
                  .fontSize(14)
                  .fontColor('#666666')
                  .width(80)

                Text(this.rule.status === RuleStatus.ENABLED ? '已启用' : 
                     this.rule.status === RuleStatus.DISABLED ? '已禁用' : '错误')
                  .fontSize(14)
                  .fontColor(this.rule.status === RuleStatus.ENABLED ? Color.Green : 
                           this.rule.status === RuleStatus.DISABLED ? Color.Gray : Color.Red)
                  .layoutWeight(1)
              }
              .width('100%')
              .margin({ bottom: 8 })

              Row() {
                Text('创建时间:')
                  .fontSize(14)
                  .fontColor('#666666')
                  .width(80)

                Text(this.formatTime(this.rule.createdAt))
                  .fontSize(14)
                  .layoutWeight(1)
              }
              .width('100%')
              .margin({ bottom: 8 })

              Row() {
                Text('更新时间:')
                  .fontSize(14)
                  .fontColor('#666666')
                  .width(80)

                Text(this.formatTime(this.rule.updatedAt))
                  .fontSize(14)
                  .layoutWeight(1)
              }
              .width('100%')
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(8)
            .margin({ bottom: 16 })

            // 触发器信息（只读）
            Column() {
              Text('触发器')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 12 })

              Column() {
                Row() {
                  Text(this.rule.trigger.name)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .layoutWeight(1)

                  Text(this.rule.trigger.enabled ? '启用' : '禁用')
                    .fontSize(12)
                    .fontColor(this.rule.trigger.enabled ? Color.Green : Color.Gray)
                }
                .width('100%')
                .margin({ bottom: 8 })

                Text(`类型: ${this.rule.trigger.type}`)
                  .fontSize(12)
                  .fontColor('#666666')
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#F8F8F8')
              .borderRadius(6)
              .margin({ bottom: 8 })

              Text('注意：触发器和动作的详细配置需要在高级编辑模式中修改')
                .fontSize(12)
                .fontColor('#999999')
                .margin({ top: 8 })
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(8)
            .margin({ bottom: 16 })

            // 动作信息（只读）
            Column() {
              Text('动作')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 12 })

              ForEach(this.rule.actions, (action) => {
                Column() {
                  Row() {
                    Text(action.name)
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .layoutWeight(1)

                    Text(action.enabled ? '启用' : '禁用')
                      .fontSize(12)
                      .fontColor(action.enabled ? Color.Green : Color.Gray)
                  }
                  .width('100%')
                  .margin({ bottom: 8 })

                  Text(`类型: ${action.type}`)
                    .fontSize(12)
                    .fontColor('#666666')
                }
                .width('100%')
                .padding(12)
                .backgroundColor('#F8F8F8')
                .borderRadius(6)
                .margin({ bottom: 8 })
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
      } else {
        Column() {
          Text('规则不存在')
            .fontSize(16)
            .fontColor('#666666')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }

      // 保存状态
      if (this.isSaving) {
        LoadingComponent({ loadingSize: 30 })
          .margin({ bottom: 16 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
