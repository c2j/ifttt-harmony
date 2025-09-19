import { AppStore } from '../../common/store/AppStore'
import { LoadingComponent } from '../../common/components/LoadingComponent'

interface ExecutionLog {
  id: string
  ruleId: string
  ruleName: string
  status: 'success' | 'failed' | 'running'
  startTime: string
  endTime?: string
  duration?: number
  triggerData?: Record<string, string | number | boolean>
  errorMessage?: string
  steps: LogStep[]
}

interface LogStep {
  stepId: string
  stepName: string
  stepType: 'trigger' | 'condition' | 'action'
  status: 'success' | 'failed' | 'skipped'
  startTime: string
  endTime?: string
  duration?: number
  input?: Record<string, string | number | boolean>
  output?: Record<string, string | number | boolean>
  errorMessage?: string
  message?: string
}

/**
 * 触发器数据接口
 */
interface TriggerData extends Record<string, string | number | boolean> {
  batteryLevel: number;
}

@Entry
@Component
export struct LogsPage {
  @StorageLink('appStore') appStore: AppStore = AppStore.getInstance()
  @State logs: ExecutionLog[] = []
  @State isLoading: boolean = false
  @State selectedStatus: string = 'all'
  @State selectedRuleId: string = 'all'
  @State searchText: string = ''
  
  /**
   * 创建日志步骤
   */
  private createLogStep(stepId: string, stepName: string, stepType: 'trigger' | 'condition' | 'action',
                       status: 'success' | 'failed' | 'skipped', startTime: string,
                       endTime?: string, duration?: number, message?: string): LogStep {
    return {
      stepId: stepId,
      stepName: stepName,
      stepType: stepType,
      status: status,
      startTime: startTime,
      endTime: endTime,
      duration: duration,
      message: message
    };
  }

  /**
   * 创建执行日志
   */
  private createExecutionLog(id: string, ruleId: string, ruleName: string,
                           status: 'success' | 'failed' | 'running', startTime: string,
                           endTime?: string, duration?: number,
                           triggerData?: Record<string, string | number | boolean>,
                           steps: LogStep[] = []): ExecutionLog {
    return {
      id: id,
      ruleId: ruleId,
      ruleName: ruleName,
      status: status,
      startTime: startTime,
      endTime: endTime,
      duration: duration,
      triggerData: triggerData,
      steps: steps
    };
  }

  /**
   * 创建触发器数据
   */
  private createTriggerData(batteryLevel: number): TriggerData {
    return {
      batteryLevel: batteryLevel
    };
  }

  aboutToAppear() {
    this.loadLogs()
  }
  
  async loadLogs() {
    this.isLoading = true
    try {
      // TODO: 调用 API 获取执行日志
      // 模拟数据
      this.logs = [
        this.createExecutionLog(
          '1',
          'rule1',
          '电量低时发送通知',
          'success',
          '2025-09-19 05:30:00',
          '2025-09-19 05:30:02',
          2000,
          this.createTriggerData(15),
          [
            this.createLogStep('trigger1', '电池电量触发器', 'trigger', 'success',
                              '2025-09-19 05:30:00', '2025-09-19 05:30:01', 1000),
            this.createLogStep('action1', '发送钉钉通知', 'action', 'success',
                              '2025-09-19 05:30:01', '2025-09-19 05:30:02', 1000)
          ]
        ),
        this.createExecutionLog(
          '2',
          'rule2',
          'WiFi连接时同步数据',
          'failed',
          '2025-09-19 05:25:00',
          '2025-09-19 05:25:05',
          5000,
          undefined,
          [
            this.createLogStep('trigger2', 'WiFi连接触发器', 'trigger', 'success',
                              '2025-09-19 05:25:00', '2025-09-19 05:25:01', 1000),
            this.createLogStep('action2', '同步云端数据', 'action', 'failed',
                              '2025-09-19 05:25:01', '2025-09-19 05:25:05', 4000, '网络连接超时')
          ]
        )
      ]
    } catch (error) {
      console.error('加载日志失败:', error)
    } finally {
      this.isLoading = false
    }
  }
  
  getStatusColor(status: string): string {
    switch (status) {
      case 'success':
        return '#52C41A'
      case 'failed':
        return '#FF4D4F'
      case 'running':
        return '#1890FF'
      default:
        return '#666666'
    }
  }
  
  getStatusText(status: string): string {
    switch (status) {
      case 'success':
        return '成功'
      case 'failed':
        return '失败'
      case 'running':
        return '运行中'
      default:
        return '未知'
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('执行日志')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .flexGrow(1)
        
        Button('刷新')
          .fontSize(14)
          .backgroundColor('#007AFF')
          .borderRadius(6)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .onClick(() => this.loadLogs())
      }
      .width('100%')
      .margin({ bottom: 16 })
      
      // 筛选栏
      Row() {
        Text('状态:')
          .fontSize(14)
          .fontColor('#666666')
          .margin({ right: 8 })
        
        Button('全部')
          .fontSize(12)
          .backgroundColor(this.selectedStatus === 'all' ? '#007AFF' : '#F0F0F0')
          .fontColor(this.selectedStatus === 'all' ? Color.White : '#333333')
          .borderRadius(4)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .margin({ right: 8 })
          .onClick(() => { this.selectedStatus = 'all' })
        
        Button('成功')
          .fontSize(12)
          .backgroundColor(this.selectedStatus === 'success' ? '#007AFF' : '#F0F0F0')
          .fontColor(this.selectedStatus === 'success' ? Color.White : '#333333')
          .borderRadius(4)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .margin({ right: 8 })
          .onClick(() => { this.selectedStatus = 'success' })
        
        Button('失败')
          .fontSize(12)
          .backgroundColor(this.selectedStatus === 'failed' ? '#007AFF' : '#F0F0F0')
          .fontColor(this.selectedStatus === 'failed' ? Color.White : '#333333')
          .borderRadius(4)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .onClick(() => { this.selectedStatus = 'failed' })
      }
      .width('100%')
      .margin({ bottom: 16 })
      
      // 日志列表
      if (this.isLoading) {
        LoadingComponent()
      } else {
        List() {
          ForEach(this.logs, (log: ExecutionLog) => {
            ListItem() {
              this.LogCard(log)
            }
            .margin({ bottom: 12 })
          })
        }
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }
  
  @Builder
  LogCard(log: ExecutionLog) {
    Column() {
      // 日志头部
      Row() {
        Column() {
          Text(log.ruleName)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          
          Text(log.startTime)
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .flexGrow(1)
        
        Row() {
          Text(this.getStatusText(log.status))
            .fontSize(12)
            .fontColor(this.getStatusColor(log.status))
            .backgroundColor(this.getStatusColor(log.status) + '20')
            .borderRadius(4)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          
          if (log.duration) {
            Text(`${log.duration}ms`)
              .fontSize(12)
              .fontColor('#666666')
              .margin({ left: 8 })
          }
        }
      }
      .width('100%')
      .margin({ bottom: 12 })
      
      // 错误信息
      if (log.errorMessage) {
        Text(log.errorMessage)
          .fontSize(14)
          .fontColor('#FF4D4F')
          .backgroundColor('#FFF2F0')
          .borderRadius(4)
          .padding(8)
          .width('100%')
          .margin({ bottom: 12 })
      }
      
      // 执行步骤
      Column() {
        Text('执行步骤:')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 8 })
        
        ForEach(log.steps, (step: LogStep, index: number) => {
          Row() {
            Text(`${index + 1}.`)
              .fontSize(12)
              .fontColor('#666666')
              .width(20)
            
            Column() {
              Text(step.stepName)
                .fontSize(14)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              
              if (step.errorMessage) {
                Text(step.errorMessage)
                  .fontSize(12)
                  .fontColor('#FF4D4F')
                  .margin({ top: 2 })
              }
            }
            .alignItems(HorizontalAlign.Start)
            .flexGrow(1)
            
            Text(this.getStatusText(step.status))
              .fontSize(10)
              .fontColor(this.getStatusColor(step.status))
              .backgroundColor(this.getStatusColor(step.status) + '20')
              .borderRadius(3)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          }
          .width('100%')
          .margin({ bottom: 6 })
        })
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(8)
    .padding(16)
    .shadow({
      radius: 4,
      color: '#00000010',
      offsetX: 0,
      offsetY: 2
    })
  }
}
