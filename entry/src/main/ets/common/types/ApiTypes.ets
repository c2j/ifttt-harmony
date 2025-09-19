/**
 * 标准API响应格式
 */
export interface ApiResponse<T> {
  success: boolean;
  code: number;
  message: string;
  data: T;
  timestamp: number;
}

/**
 * 分页响应
 */
export interface PageResponse<T> {
  content: T[];
  totalElements: number;
  totalPages: number;
  size: number;
  number: number;
  first: boolean;
  last: boolean;
}

/**
 * 插件信息
 */
export interface Plugin {
  id: number;
  pluginId: string;
  name: string;
  description: string;
  author: string;
  iconUrl?: string;
  homepage?: string;
  downloadCount: number;
  latestVersion: string;
  createdAt: number;
  updatedAt: number;
}

/**
 * 插件版本信息
 */
export interface PluginVersion {
  id: number;
  pluginId: string;
  version: string;
  fileSha256: string;
  fileSize: number;
  downloadUrl: string;
  downloadCount: number;
  releaseNote?: string;
  createdAt: number;
}

/**
 * 插件详情（包含版本列表）
 */
export interface PluginDetail extends Plugin {
  versions: PluginVersion[];
}

/**
 * 下载日志
 */
export interface DownloadLog {
  id: number;
  pluginId: string;
  version: string;
  deviceId: string;
  userAgent: string;
  ipAddress: string;
  downloadTime: number;
  fileSize: number;
  downloadDuration: number;
  success: boolean;
  errorMessage?: string;
}

/**
 * 备份信息
 */
export interface Backup {
  id: number;
  deviceId: string;
  backupName: string;
  description?: string;
  dataSize: number;
  fileSha256: string;
  createdAt: number;
  updatedAt: number;
}

/**
 * 备份详情
 */
export interface BackupDetail extends Backup {
  rules: Rule[];
  plugins: string[];
}

/**
 * 规则信息
 */
export interface Rule {
  id: string;
  name: string;
  description?: string;
  enabled: boolean;
  trigger: RuleTrigger;
  conditions: RuleCondition[];
  actions: RuleAction[];
  createdAt: number;
  updatedAt: number;
  lastExecuted?: number;
  executionCount: number;
}

/**
 * 规则触发器
 */
export interface RuleTrigger {
  type: string;
  pluginId: string;
  config: Record<string, string | number | boolean>;
}

/**
 * 规则条件
 */
export interface RuleCondition {
  type: string;
  pluginId?: string;
  operator: 'equals' | 'not_equals' | 'greater_than' | 'less_than' | 'contains' | 'not_contains';
  value: string | number | boolean;
  config: Record<string, string | number | boolean>;
}

/**
 * 规则动作
 */
export interface RuleAction {
  type: string;
  pluginId: string;
  config: Record<string, string | number | boolean>;
  delay?: number;
}

/**
 * 统计信息
 */
export interface Statistics {
  totalPlugins: number;
  totalDownloads: number;
  totalRules: number;
  activeRules: number;
  totalExecutions: number;
  todayExecutions: number;
  popularPlugins: PluginStats[];
  recentDownloads: DownloadStats[];
}

/**
 * 插件统计
 */
export interface PluginStats {
  pluginId: string;
  name: string;
  downloadCount: number;
  usageCount: number;
}

/**
 * 下载统计
 */
export interface DownloadStats {
  date: string;
  count: number;
  size: number;
}

/**
 * 搜索参数
 */
export interface SearchParams {
  keyword?: string;
  author?: string;
  category?: string;
  sortBy?: 'name' | 'downloadCount' | 'createdAt' | 'updatedAt';
  sortOrder?: 'asc' | 'desc';
  page?: number;
  size?: number;
}

/**
 * 文件上传响应
 */
export interface FileUploadResponse {
  pluginId: string;
  version: string;
  fileName: string;
  fileSize: number;
  sha256: string;
  downloadUrl: string;
}

/**
 * 文件信息
 */
export interface FileInfo {
  fileName: string;
  fileSize: number;
  sha256: string;
  lastModified: number;
  downloadUrl: string;
  downloadCount: number;
}

/**
 * 错误信息
 */
export interface ErrorInfo {
  code: number;
  message: string;
  details?: string;
  timestamp: number;
}

/**
 * 设备信息
 */
export interface DeviceInfo {
  deviceId: string;
  deviceName: string;
  osVersion: string;
  appVersion: string;
  lastSyncTime?: number;
}

/**
 * 同步状态
 */
export interface SyncStatus {
  inProgress: boolean;
  lastSyncTime?: number;
  totalItems: number;
  syncedItems: number;
  failedItems: number;
  errors: string[];
}

/**
 * 应用配置
 */
export interface AppConfig {
  serverUrl: string;
  autoSync: boolean;
  syncInterval: number;
  downloadPath: string;
  maxCacheSize: number;
  enableNotifications: boolean;
  theme: 'light' | 'dark' | 'auto';
  language: string;
}

/**
 * 用户偏好设置
 */
export interface UserPreferences {
  theme: 'light' | 'dark' | 'auto';
  language: string;
  autoSync: boolean;
  syncInterval: number;
  enableNotifications: boolean;
  downloadOnWifiOnly: boolean;
  maxCacheSize: number;
}

/**
 * 网络状态
 */
export interface NetworkStatus {
  connected: boolean;
  type: 'wifi' | 'cellular' | 'unknown';
  strength: number;
}

/**
 * 应用状态
 */
export interface AppState {
  isLoading: boolean;
  error?: ErrorInfo;
  networkStatus: NetworkStatus;
  syncStatus: SyncStatus;
  currentUser?: DeviceInfo;
}
