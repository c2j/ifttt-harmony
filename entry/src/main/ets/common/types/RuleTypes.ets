/**
 * 规则状态枚举
 */
export enum RuleStatus {
  ENABLED = 'enabled',
  DISABLED = 'disabled',
  ERROR = 'error'
}

/**
 * 触发器类型枚举
 */
export enum TriggerType {
  TIME = 'time',
  BATTERY = 'battery',
  WIFI = 'wifi',
  LOCATION = 'location',
  WEATHER = 'weather',
  DEVICE = 'device',
  MANUAL = 'manual',
  CUSTOM = 'custom'
}

/**
 * 条件操作符枚举
 */
export enum ConditionOperator {
  EQUALS = 'equals',
  NOT_EQUALS = 'not_equals',
  GREATER_THAN = 'greater_than',
  LESS_THAN = 'less_than',
  GREATER_EQUAL = 'greater_equal',
  LESS_EQUAL = 'less_equal',
  CONTAINS = 'contains',
  NOT_CONTAINS = 'not_contains',
  STARTS_WITH = 'starts_with',
  ENDS_WITH = 'ends_with',
  IN_RANGE = 'in_range',
  NOT_IN_RANGE = 'not_in_range'
}

/**
 * 动作类型枚举
 */
export enum ActionType {
  NOTIFICATION = 'notification',
  HTTP_REQUEST = 'http_request',
  EMAIL = 'email',
  SMS = 'sms',
  WEBHOOK = 'webhook',
  DEVICE_CONTROL = 'device_control',
  CUSTOM = 'custom'
}

/**
 * 规则基础信息
 */
export interface RuleInfo {
  id: string;
  name: string;
  description?: string;
  enabled: boolean;
  status: RuleStatus;
  createdAt: number;
  updatedAt: number;
  lastExecuted?: number;
  executionCount: number;
  successCount: number;
  failureCount: number;
}

/**
 * 规则触发器
 */
export interface RuleTrigger {
  id: string;
  type: TriggerType;
  pluginId: string;
  pluginName: string;
  name: string;
  description?: string;
  config: Record<string, string | number | boolean>;
  enabled: boolean;
}

/**
 * 规则条件
 */
export interface RuleCondition {
  id: string;
  type: string;
  pluginId?: string;
  pluginName?: string;
  name: string;
  description?: string;
  operator: ConditionOperator;
  value: string | number | boolean;
  config: Record<string, string | number | boolean>;
  enabled: boolean;
}

/**
 * 规则动作
 */
export interface RuleAction {
  id: string;
  type: ActionType;
  pluginId: string;
  pluginName: string;
  name: string;
  description?: string;
  config: Record<string, string | number | boolean>;
  delay?: number;
  enabled: boolean;
  order: number;
}

/**
 * 完整规则定义
 */
export interface Rule extends RuleInfo {
  trigger: RuleTrigger;
  conditions: RuleCondition[];
  actions: RuleAction[];
}

/**
 * 规则执行日志
 */
export interface RuleExecutionLog {
  id: string;
  ruleId: string;
  ruleName: string;
  executedAt: number;
  success: boolean;
  duration: number;
  triggerData?: Record<string, string | number | boolean>;
  conditionResults: ConditionResult[];
  actionResults: ActionResult[];
  errorMessage?: string;
}

/**
 * 条件执行结果
 */
export interface ConditionResult {
  conditionId: string;
  conditionName: string;
  passed: boolean;
  actualValue: string | number | boolean;
  expectedValue: string | number | boolean;
  operator: ConditionOperator;
  errorMessage?: string;
}

/**
 * 动作执行结果
 */
export interface ActionResult {
  actionId: string;
  actionName: string;
  success: boolean;
  duration: number;
  response?: Record<string, string | number | boolean> | string;
  errorMessage?: string;
}

/**
 * 规则统计信息
 */
export interface RuleStatistics {
  totalRules: number;
  enabledRules: number;
  disabledRules: number;
  errorRules: number;
  totalExecutions: number;
  successfulExecutions: number;
  failedExecutions: number;
  averageExecutionTime: number;
  mostActiveRules: RuleInfo[];
  recentExecutions: RuleExecutionLog[];
}

/**
 * 规则模板
 */
export interface RuleTemplate {
  id: string;
  name: string;
  description: string;
  category: string;
  icon?: string;
  trigger: Partial<RuleTrigger>;
  conditions: Partial<RuleCondition>[];
  actions: Partial<RuleAction>[];
  requiredPlugins: string[];
  difficulty: 'easy' | 'medium' | 'hard';
  popularity: number;
}

/**
 * 插件能力定义
 */
export interface PluginCapability {
  pluginId: string;
  pluginName: string;
  version: string;
  triggers: TriggerCapability[];
  conditions: ConditionCapability[];
  actions: ActionCapability[];
}

/**
 * 触发器能力
 */
export interface TriggerCapability {
  type: TriggerType;
  name: string;
  description: string;
  configSchema: ConfigSchema;
  examples: Record<string, string | number | boolean>[];
}

/**
 * 条件能力
 */
export interface ConditionCapability {
  type: string;
  name: string;
  description: string;
  supportedOperators: ConditionOperator[];
  valueType: 'string' | 'number' | 'boolean' | 'object' | 'array';
  configSchema: ConfigSchema;
  examples: Record<string, string | number | boolean>[];
}

/**
 * 动作能力
 */
export interface ActionCapability {
  type: ActionType;
  name: string;
  description: string;
  configSchema: ConfigSchema;
  examples: Record<string, string | number | boolean>[];
  async: boolean;
  timeout?: number;
}

/**
 * 配置模式定义
 */
export interface ConfigSchema {
  type: 'object';
  properties: Record<string, ConfigProperty>;
  required?: string[];
}

/**
 * 配置属性
 */
export interface ConfigProperty {
  type: 'string' | 'number' | 'boolean' | 'array' | 'object';
  title: string;
  description?: string;
  default?: string | number | boolean;
  enum?: (string | number | boolean)[];
  minimum?: number;
  maximum?: number;
  pattern?: string;
  format?: string;
  items?: ConfigProperty;
  properties?: Record<string, ConfigProperty>;
}

/**
 * 规则验证结果
 */
export interface RuleValidationResult {
  valid: boolean;
  errors: ValidationError[];
  warnings: ValidationWarning[];
}

/**
 * 验证错误
 */
export interface ValidationError {
  field: string;
  message: string;
  code: string;
}

/**
 * 验证警告
 */
export interface ValidationWarning {
  field: string;
  message: string;
  code: string;
}

/**
 * 规则导入导出格式
 */
export interface RuleExport {
  version: string;
  exportedAt: number;
  rules: Rule[];
  plugins: PluginCapability[];
}

/**
 * 规则搜索参数
 */
export interface RuleSearchParams {
  keyword?: string;
  status?: RuleStatus;
  triggerType?: TriggerType;
  pluginId?: string;
  enabled?: boolean;
  sortBy?: 'name' | 'createdAt' | 'updatedAt' | 'executionCount';
  sortOrder?: 'asc' | 'desc';
  page?: number;
  size?: number;
}
