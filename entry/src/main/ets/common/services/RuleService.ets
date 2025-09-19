import {
  Rule,
  RuleInfo,
  RuleTrigger,
  RuleCondition,
  RuleAction,
  RuleExecutionLog,
  RuleStatistics,
  RuleTemplate,
  PluginCapability,
  RuleValidationResult,
  RuleSearchParams,
  RuleStatus,
  TriggerType,
  ActionType,
  ConditionResult,
  ActionResult,
  ValidationError,
  ValidationWarning,
  ConditionOperator
} from '../types/RuleTypes';

/**
 * 规则配置接口
 */
interface RuleConfig {
  threshold: number;
}

/**
 * 触发器配置数据接口
 */
interface TriggerConfigData extends Record<string, string | number | boolean> {
  threshold: number;
  operator: string;
}

/**
 * 动作配置数据接口
 */
interface ActionConfigData extends Record<string, string | number | boolean> {
  title: string;
  message: string;
  priority: string;
}

/**
 * 动作响应数据接口
 */
interface ActionResponseData extends Record<string, string | number | boolean> {
  status: string;
}

/**
 * 触发器配置接口
 */
interface TriggerConfig {
  threshold: number;
}

/**
 * 动作配置接口
 */
interface ActionConfig {
  title: string;
  message: string;
  priority: string;
}

/**
 * 模板触发器接口
 */
interface TemplateTrigger {
  type: TriggerType;
  pluginId: string;
  name: string;
}

/**
 * 模板动作接口
 */
interface TemplateAction {
  type: ActionType;
  pluginId: string;
  name: string;
}

/**
 * 创建规则输入接口
 */
interface CreateRuleInput {
  name: string;
  description?: string;
  enabled: boolean;
  status: RuleStatus;
  lastExecuted?: number;
  trigger: RuleTrigger;
  conditions: RuleCondition[];
  actions: RuleAction[];
}

/**
 * 规则服务 - 管理规则的CRUD操作和执行
 */
export class RuleService {
  private static instance: RuleService;
  private rules: Map<string, Rule> = new Map();
  private executionLogs: RuleExecutionLog[] = [];
  private templates: RuleTemplate[] = [];
  private pluginCapabilities: Map<string, PluginCapability> = new Map();

  private constructor() {
    this.initializeTestData();
  }

  static getInstance(): RuleService {
    if (!RuleService.instance) {
      RuleService.instance = new RuleService();
    }
    return RuleService.instance;
  }

  /**
   * 创建触发器配置
   */
  private createTriggerConfig(threshold: number, operator: string): TriggerConfigData {
    return {
      threshold: threshold,
      operator: operator
    };
  }

  /**
   * 创建动作配置
   */
  private createActionConfig(title: string, message: string, priority: string): ActionConfigData {
    return {
      title: title,
      message: message,
      priority: priority
    };
  }

  /**
   * 创建模板触发器
   */
  private createTemplateTrigger(type: TriggerType, pluginId: string, name: string): TemplateTrigger {
    return {
      type: type,
      pluginId: pluginId,
      name: name
    };
  }

  /**
   * 创建模板动作
   */
  private createTemplateAction(type: ActionType, pluginId: string, name: string): TemplateAction {
    return {
      type: type,
      pluginId: pluginId,
      name: name
    };
  }

  /**
   * 合并规则更新
   */
  private mergeRuleUpdates(existing: Rule, updates: Partial<Rule>): Rule {
    return {
      id: existing.id, // 确保ID不被修改
      name: updates.name !== undefined ? updates.name : existing.name,
      description: updates.description !== undefined ? updates.description : existing.description,
      enabled: updates.enabled !== undefined ? updates.enabled : existing.enabled,
      status: updates.status !== undefined ? updates.status : existing.status,
      createdAt: existing.createdAt,
      updatedAt: Date.now(),
      lastExecuted: updates.lastExecuted !== undefined ? updates.lastExecuted : existing.lastExecuted,
      executionCount: updates.executionCount !== undefined ? updates.executionCount : existing.executionCount,
      successCount: updates.successCount !== undefined ? updates.successCount : existing.successCount,
      failureCount: updates.failureCount !== undefined ? updates.failureCount : existing.failureCount,
      trigger: updates.trigger !== undefined ? updates.trigger : existing.trigger,
      conditions: updates.conditions !== undefined ? updates.conditions : existing.conditions,
      actions: updates.actions !== undefined ? updates.actions : existing.actions
    };
  }

  /**
   * 创建动作响应
   */
  private createActionResponse(status: string): ActionResponseData {
    return {
      status: status
    };
  }

  /**
   * 创建空的触发器数据
   */
  private createEmptyTriggerData(): Record<string, string | number | boolean> {
    return {};
  }

  /**
   * 初始化测试数据
   */
  private initializeTestData(): void {
    // 创建示例规则
    const sampleRule: Rule = {
      id: 'rule_001',
      name: '低电量提醒',
      description: '当电量低于20%时发送通知',
      enabled: true,
      status: RuleStatus.ENABLED,
      createdAt: Date.now() - 86400000,
      updatedAt: Date.now() - 3600000,
      lastExecuted: Date.now() - 1800000,
      executionCount: 15,
      successCount: 14,
      failureCount: 1,
      trigger: {
        id: 'trigger_001',
        type: 'battery' as TriggerType,
        pluginId: 'battery',
        pluginName: '电池插件',
        name: '电量变化',
        description: '监控设备电量变化',
        config: this.createTriggerConfig(20, 'less_than'),
        enabled: true
      },
      conditions: [],
      actions: [
        {
          id: 'action_001',
          type: 'notification' as ActionType,
          pluginId: 'notification',
          pluginName: '通知插件',
          name: '发送通知',
          description: '发送系统通知',
          config: this.createActionConfig('电量不足', '设备电量已低于20%，请及时充电', 'high'),
          enabled: true,
          order: 1
        }
      ]
    };

    this.rules.set(sampleRule.id, sampleRule);

    // 创建示例模板
    const sampleTemplate: RuleTemplate = {
      id: 'template_001',
      name: '低电量提醒模板',
      description: '当设备电量低于指定值时发送通知提醒',
      category: '设备管理',
      trigger: this.createTemplateTrigger('battery' as TriggerType, 'battery', '电量变化'),
      conditions: [],
      actions: [
        this.createTemplateAction('notification' as ActionType, 'notification', '发送通知')
      ],
      requiredPlugins: ['battery', 'notification'],
      difficulty: 'easy',
      popularity: 85
    };

    this.templates.push(sampleTemplate);
  }

  /**
   * 获取所有规则
   */
  async getRules(params?: RuleSearchParams): Promise<Rule[]> {
    let rules = Array.from(this.rules.values());

    // 应用搜索过滤
    if (params) {
      if (params.keyword) {
        const keyword = params.keyword.toLowerCase();
        rules = rules.filter(rule => 
          rule.name.toLowerCase().includes(keyword) ||
          (rule.description && rule.description.toLowerCase().includes(keyword))
        );
      }

      if (params.status) {
        rules = rules.filter(rule => rule.status === params.status);
      }

      if (params.enabled !== undefined) {
        rules = rules.filter(rule => rule.enabled === params.enabled);
      }

      if (params.triggerType) {
        rules = rules.filter(rule => rule.trigger.type === params.triggerType);
      }

      if (params.pluginId) {
        rules = rules.filter(rule => 
          rule.trigger.pluginId === params.pluginId ||
          rule.actions.some(action => action.pluginId === params.pluginId)
        );
      }

      // 排序
      if (params.sortBy) {
        rules.sort((a, b) => {
          let aValue: string | number | boolean, bValue: string | number | boolean;
          
          switch (params.sortBy) {
            case 'name':
              aValue = a.name;
              bValue = b.name;
              break;
            case 'createdAt':
              aValue = a.createdAt;
              bValue = b.createdAt;
              break;
            case 'updatedAt':
              aValue = a.updatedAt;
              bValue = b.updatedAt;
              break;
            case 'executionCount':
              aValue = a.executionCount;
              bValue = b.executionCount;
              break;
            default:
              return 0;
          }

          if (params.sortOrder === 'desc') {
            return bValue > aValue ? 1 : -1;
          } else {
            return aValue > bValue ? 1 : -1;
          }
        });
      }

      // 分页
      if (params.page !== undefined && params.size !== undefined) {
        const start = params.page * params.size;
        const end = start + params.size;
        rules = rules.slice(start, end);
      }
    }

    return rules;
  }

  /**
   * 根据ID获取规则
   */
  async getRule(id: string): Promise<Rule | null> {
    return this.rules.get(id) || null;
  }

  /**
   * 创建新规则
   */
  async createRule(rule: CreateRuleInput): Promise<Rule> {
    const newRule: Rule = {
      id: this.generateId(),
      name: rule.name,
      description: rule.description,
      enabled: rule.enabled,
      status: rule.status,
      createdAt: Date.now(),
      updatedAt: Date.now(),
      lastExecuted: rule.lastExecuted,
      executionCount: 0,
      successCount: 0,
      failureCount: 0,
      trigger: rule.trigger,
      conditions: rule.conditions,
      actions: rule.actions
    };

    this.rules.set(newRule.id, newRule);
    console.info(`[RuleService] Created rule: ${newRule.name}`);
    return newRule;
  }

  /**
   * 简单创建规则方法
   */
  async createSimpleRule(name: string, description: string, triggerName: string, actionName: string): Promise<Rule> {
    const trigger: RuleTrigger = {
      id: `trigger_${Date.now()}`,
      type: TriggerType.MANUAL,
      pluginId: 'system',
      pluginName: '系统',
      name: triggerName,
      config: {},
      enabled: true
    };

    const action: RuleAction = {
      id: `action_${Date.now()}`,
      type: ActionType.NOTIFICATION,
      pluginId: 'system',
      pluginName: '系统',
      name: actionName,
      config: {},
      enabled: true,
      order: 1
    };

    const newRule: Rule = {
      id: this.generateId(),
      name: name,
      description: description,
      enabled: true,
      status: RuleStatus.ENABLED,
      createdAt: Date.now(),
      updatedAt: Date.now(),
      lastExecuted: undefined,
      executionCount: 0,
      successCount: 0,
      failureCount: 0,
      trigger: trigger,
      conditions: [],
      actions: [action]
    };

    this.rules.set(newRule.id, newRule);
    console.info(`[RuleService] Created simple rule: ${newRule.name}`);
    return newRule;
  }

  /**
   * 创建新规则（从完整Rule对象）
   */
  async createRuleFromObject(rule: Rule): Promise<boolean> {
    const newRule: Rule = {
      id: rule.id || this.generateId(),
      name: rule.name,
      description: rule.description,
      enabled: rule.enabled,
      status: rule.status,
      createdAt: rule.createdAt || Date.now(),
      updatedAt: Date.now(),
      lastExecuted: rule.lastExecuted,
      executionCount: rule.executionCount || 0,
      successCount: rule.successCount || 0,
      failureCount: rule.failureCount || 0,
      trigger: rule.trigger,
      conditions: rule.conditions,
      actions: rule.actions
    };

    this.rules.set(newRule.id, newRule);
    console.info(`[RuleService] Created rule: ${newRule.name}`);
    return true;
  }

  /**
   * 根据ID获取规则
   */
  async getRuleById(id: string): Promise<Rule | null> {
    return this.rules.get(id) || null;
  }

  /**
   * 更新规则
   */
  async updateRule(rule: Rule): Promise<boolean>;
  async updateRule(id: string, updates: Partial<Rule>): Promise<Rule | null>;
  async updateRule(ruleOrId: Rule | string, updates?: Partial<Rule>): Promise<boolean | Rule | null> {
    if (typeof ruleOrId === 'string') {
      // 原有的方法签名
      const existingRule = this.rules.get(ruleOrId);
      if (!existingRule) {
        return null;
      }

      const updatedRule: Rule = this.mergeRuleUpdates(existingRule, updates!);
      this.rules.set(ruleOrId, updatedRule);
      console.info(`[RuleService] Updated rule: ${updatedRule.name}`);
      return updatedRule;
    } else {
      // 新的方法签名，用于页面
      if (!this.rules.has(ruleOrId.id)) {
        return false;
      }

      const updatedRule: Rule = {
        id: ruleOrId.id,
        name: ruleOrId.name,
        description: ruleOrId.description,
        enabled: ruleOrId.enabled,
        status: ruleOrId.status,
        createdAt: ruleOrId.createdAt,
        updatedAt: Date.now(),
        lastExecuted: ruleOrId.lastExecuted,
        executionCount: ruleOrId.executionCount,
        successCount: ruleOrId.successCount,
        failureCount: ruleOrId.failureCount,
        trigger: ruleOrId.trigger,
        conditions: ruleOrId.conditions,
        actions: ruleOrId.actions
      };

      this.rules.set(ruleOrId.id, updatedRule);
      console.info(`[RuleService] Updated rule: ${updatedRule.name}`);
      return true;
    }
  }

  /**
   * 更新规则状态
   */
  async updateRuleStatus(id: string, status: RuleStatus): Promise<boolean> {
    const existingRule = this.rules.get(id);
    if (!existingRule) {
      return false;
    }

    const updatedRule: Rule = {
      id: existingRule.id,
      name: existingRule.name,
      description: existingRule.description,
      enabled: status === RuleStatus.ENABLED,
      status: status,
      createdAt: existingRule.createdAt,
      updatedAt: Date.now(),
      lastExecuted: existingRule.lastExecuted,
      executionCount: existingRule.executionCount,
      successCount: existingRule.successCount,
      failureCount: existingRule.failureCount,
      trigger: existingRule.trigger,
      conditions: existingRule.conditions,
      actions: existingRule.actions
    };

    this.rules.set(id, updatedRule);
    console.info(`[RuleService] Updated rule status: ${id} -> ${status}`);
    return true;
  }

  /**
   * 删除规则
   */
  async deleteRule(id: string): Promise<boolean> {
    const deleted = this.rules.delete(id);
    if (deleted) {
      console.info(`[RuleService] Deleted rule: ${id}`);
    }
    return deleted;
  }

  /**
   * 启用/禁用规则
   */
  async toggleRule(id: string, enabled: boolean): Promise<Rule | null> {
    const rule = this.rules.get(id);
    if (!rule) {
      return null;
    }

    rule.enabled = enabled;
    rule.status = enabled ? RuleStatus.ENABLED : RuleStatus.DISABLED;
    rule.updatedAt = Date.now();

    console.info(`[RuleService] ${enabled ? 'Enabled' : 'Disabled'} rule: ${rule.name}`);
    
    return rule;
  }

  /**
   * 执行规则
   */
  async executeRule(id: string, triggerData?: Record<string, string | number | boolean>): Promise<RuleExecutionLog> {
    const rule = this.rules.get(id);
    if (!rule) {
      throw new Error(`Rule not found: ${id}`);
    }

    const startTime = Date.now();
    const log: RuleExecutionLog = {
      id: this.generateId(),
      ruleId: id,
      ruleName: rule.name,
      executedAt: startTime,
      success: false,
      duration: 0,
      triggerData,
      conditionResults: [],
      actionResults: []
    };

    try {
      // 检查条件
      let allConditionsPassed = true;
      for (const condition of rule.conditions) {
        const result = await this.evaluateCondition(condition, triggerData || this.createEmptyTriggerData());
        log.conditionResults.push(result);
        if (!result.passed) {
          allConditionsPassed = false;
        }
      }

      if (!allConditionsPassed) {
        log.success = false;
        log.errorMessage = 'Conditions not met';
      } else {
        // 执行动作
        for (const action of rule.actions) {
          if (action.enabled) {
            const result = await this.executeAction(action, triggerData || this.createEmptyTriggerData());
            log.actionResults.push(result);
          }
        }

        log.success = log.actionResults.every(result => result.success);
      }

      // 更新规则统计
      rule.executionCount++;
      rule.lastExecuted = startTime;
      if (log.success) {
        rule.successCount++;
      } else {
        rule.failureCount++;
      }

    } catch (error) {
      log.success = false;
      log.errorMessage = error.message;
      rule.failureCount++;
    } finally {
      log.duration = Date.now() - startTime;
      this.executionLogs.push(log);
      
      // 保持日志数量在合理范围内
      if (this.executionLogs.length > 1000) {
        this.executionLogs = this.executionLogs.slice(-500);
      }
    }

    console.info(`[RuleService] Executed rule: ${rule.name}, success: ${log.success}`);
    
    return log;
  }

  /**
   * 获取规则执行日志
   */
  async getExecutionLogs(ruleId?: string, limit: number = 50): Promise<RuleExecutionLog[]> {
    let logs = this.executionLogs;
    
    if (ruleId) {
      logs = logs.filter(log => log.ruleId === ruleId);
    }

    return logs
      .sort((a, b) => b.executedAt - a.executedAt)
      .slice(0, limit);
  }

  /**
   * 获取规则统计信息
   */
  async getStatistics(): Promise<RuleStatistics> {
    const rules = Array.from(this.rules.values());
    const enabledRules = rules.filter(rule => rule.enabled);
    const disabledRules = rules.filter(rule => !rule.enabled);
    const errorRules = rules.filter(rule => rule.status === RuleStatus.ERROR);

    const totalExecutions = rules.reduce((sum, rule) => sum + rule.executionCount, 0);
    const successfulExecutions = rules.reduce((sum, rule) => sum + rule.successCount, 0);
    const failedExecutions = rules.reduce((sum, rule) => sum + rule.failureCount, 0);

    const recentLogs = this.executionLogs
      .sort((a, b) => b.executedAt - a.executedAt)
      .slice(0, 10);

    const averageExecutionTime = recentLogs.length > 0
      ? recentLogs.reduce((sum, log) => sum + log.duration, 0) / recentLogs.length
      : 0;

    const mostActiveRules = rules
      .sort((a, b) => b.executionCount - a.executionCount)
      .slice(0, 5);

    return {
      totalRules: rules.length,
      enabledRules: enabledRules.length,
      disabledRules: disabledRules.length,
      errorRules: errorRules.length,
      totalExecutions,
      successfulExecutions,
      failedExecutions,
      averageExecutionTime,
      mostActiveRules,
      recentExecutions: recentLogs
    };
  }

  /**
   * 获取规则模板
   */
  async getTemplates(): Promise<RuleTemplate[]> {
    return Array.from(this.templates);
  }

  /**
   * 验证规则
   */
  async validateRule(rule: Partial<Rule>): Promise<RuleValidationResult> {
    const errors: ValidationError[] = [];
    const warnings: ValidationWarning[] = [];

    // 基本验证
    if (!rule.name || rule.name.trim().length === 0) {
      errors.push({
        field: 'name',
        message: '规则名称不能为空',
        code: 'REQUIRED'
      });
    }

    if (!rule.trigger) {
      errors.push({
        field: 'trigger',
        message: '必须设置触发器',
        code: 'REQUIRED'
      });
    }

    if (!rule.actions || rule.actions.length === 0) {
      errors.push({
        field: 'actions',
        message: '至少需要一个动作',
        code: 'REQUIRED'
      });
    }

    return {
      valid: errors.length === 0,
      errors,
      warnings
    };
  }

  /**
   * 生成唯一ID
   */
  private generateId(): string {
    return 'rule_' + Date.now().toString(36) + Math.random().toString(36).substr(2);
  }

  /**
   * 评估条件
   */
  private async evaluateCondition(condition: RuleCondition, triggerData: Record<string, string | number | boolean>): Promise<ConditionResult> {
    // 这里应该根据条件类型和操作符进行实际的条件评估
    // 暂时返回模拟结果
    return {
      conditionId: condition.id,
      conditionName: condition.name,
      passed: Math.random() > 0.2, // 80%的成功率
      actualValue: JSON.stringify(triggerData),
      expectedValue: condition.value || '',
      operator: condition.operator || ConditionOperator.EQUALS
    };
  }

  /**
   * 执行动作
   */
  private async executeAction(action: RuleAction, triggerData: Record<string, string | number | boolean>): Promise<ActionResult> {
    // 这里应该根据动作类型执行实际的动作
    // 暂时返回模拟结果
    const startTime = Date.now();
    
    // 模拟异步执行
    await new Promise<void>(resolve => setTimeout(resolve, Math.random() * 1000));
    
    return {
      actionId: action.id,
      actionName: action.name,
      success: Math.random() > 0.1, // 90%的成功率
      duration: Date.now() - startTime,
      response: JSON.stringify(this.createActionResponse('completed'))
    };
  }
}

/**
 * 全局规则服务实例
 */
export const ruleService = RuleService.getInstance();
