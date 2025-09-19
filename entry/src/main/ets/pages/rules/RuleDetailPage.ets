import { Rule, RuleStatus, RuleAction } from '../../common/types/RuleTypes';
import { ruleService } from '../../common/services/RuleService';
import { RouteUtils } from '../../common/router/Router';
import { LoadingComponent } from '../../common/components/LoadingComponent';
import router from '@ohos.router';

/**
 * 规则详情页面
 */
@Entry
@Component
export struct RuleDetailPage {
  @State rule: Rule | null = null;
  @State isLoading: boolean = true;
  @State ruleId: string = '';

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
    } catch (error) {
      console.error('加载规则详情失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 切换规则状态
   */
  private async toggleRuleStatus(): Promise<void> {
    if (!this.rule) return;

    try {
      const newStatus = this.rule.status === RuleStatus.ENABLED ? RuleStatus.DISABLED : RuleStatus.ENABLED;
      const success = await ruleService.updateRuleStatus(this.rule.id, newStatus);
      if (success && this.rule) {
        this.rule.status = newStatus;
      }
    } catch (error) {
      console.error('切换规则状态失败:', error);
    }
  }

  /**
   * 删除规则
   */
  private async deleteRule(): Promise<void> {
    if (!this.rule) return;

    try {
      const success = await ruleService.deleteRule(this.rule.id);
      if (success) {
        console.info('规则删除成功');
        RouteUtils.back();
      }
    } catch (error) {
      console.error('删除规则失败:', error);
    }
  }

  /**
   * 格式化时间
   */
  private formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')} ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
  }

  /**
   * 获取状态文本
   */
  private getStatusText(status: RuleStatus): string {
    switch (status) {
      case RuleStatus.ENABLED:
        return '已启用';
      case RuleStatus.DISABLED:
        return '已禁用';
      case RuleStatus.ERROR:
        return '错误';
      default:
        return '未知';
    }
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

        Text('规则详情')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button('编辑')
          .fontSize(16)
          .backgroundColor(Color.Blue)
          .fontColor(Color.White)
          .borderRadius(8)
          .onClick(() => {
            if (this.rule) {
              RouteUtils.toRuleEdit(this.rule.id);
            }
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
            // 基本信息
            Column() {
              Row() {
                Text(this.rule.name)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .layoutWeight(1)

                Text(this.getStatusText(this.rule.status))
                  .fontSize(14)
                  .fontColor(this.getStatusColor(this.rule.status))
                  .backgroundColor('#F0F0F0')
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .borderRadius(4)
              }
              .width('100%')
              .margin({ bottom: 12 })

              if (this.rule.description) {
                Text(this.rule.description)
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ bottom: 12 })
              }

              Row() {
                Text(`创建时间: ${this.formatTime(this.rule.createdAt)}`)
                  .fontSize(12)
                  .fontColor('#999999')
                  .layoutWeight(1)

                Text(`更新时间: ${this.formatTime(this.rule.updatedAt)}`)
                  .fontSize(12)
                  .fontColor('#999999')
              }
              .width('100%')
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(8)
            .margin({ bottom: 16 })

            // 触发器信息
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

            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(8)
            .margin({ bottom: 16 })

            // 动作信息
            Column() {
              Text('动作')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 12 })

              ForEach(this.rule.actions, (action: RuleAction) => {
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

            // 操作按钮
            Row() {
              Button(this.rule.status === RuleStatus.ENABLED ? '禁用规则' : '启用规则')
                .fontSize(14)
                .backgroundColor(this.rule.status === RuleStatus.ENABLED ? Color.Orange : Color.Green)
                .borderRadius(8)
                .layoutWeight(1)
                .margin({ right: 8 })
                .onClick(() => {
                  this.toggleRuleStatus();
                })

              Button('删除规则')
                .fontSize(14)
                .backgroundColor(Color.Red)
                .borderRadius(8)
                .layoutWeight(1)
                .margin({ left: 8 })
                .onClick(() => {
                  this.deleteRule();
                })
            }
            .width('100%')
            .padding(16)
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
    }
    .width('100%')
    .height('100%')
  }
}
