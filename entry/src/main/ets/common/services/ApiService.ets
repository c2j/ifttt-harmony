import { apiClient } from '../http/HttpClient';
import { 
  ApiResponse, 
  PageResponse, 
  Plugin, 
  PluginDetail, 
  PluginVersion,
  DownloadLog,
  Backup,
  BackupDetail,
  Statistics,
  SearchParams,
  FileUploadResponse,
  FileInfo
} from '../types/ApiTypes';

/**
 * URL搜索参数类
 */
class URLSearchParams {
  private params: Map<string, string> = new Map();

  append(name: string, value: string): void {
    this.params.set(name, value);
  }

  toString(): string {
    const pairs: string[] = [];
    this.params.forEach((value, key) => {
      pairs.push(`${encodeURIComponent(key)}=${encodeURIComponent(value)}`);
    });
    return pairs.join('&');
  }
}

/**
 * 文件类
 */
class File {
  name: string;
  content: string;

  constructor(name: string, content: string) {
    this.name = name;
    this.content = content;
  }
}

/**
 * 表单数据类
 */
class FormData {
  private data: Map<string, string | File> = new Map();

  append(name: string, value: string | File): void {
    this.data.set(name, value);
  }

  toString(): string {
    // 简化实现，实际应该生成 multipart/form-data 格式
    return '';
  }
}

/**
 * 下载请求数据接口
 */
interface DownloadRequestData extends Record<string, string | number | boolean> {
  pluginId: string;
  version: string;
  deviceId: string;
  userAgent: string;
}

/**
 * 备份请求数据接口
 */
interface BackupRequestData extends Record<string, string | number | boolean> {
  name: string;
  description: string;
  data: string;
}

/**
 * 下载结果报告数据接口
 */
interface DownloadResultData extends Record<string, string | number | boolean> {
  success: boolean;
  errorMessage: string;
}

/**
 * 创建备份数据接口
 */
interface CreateBackupData extends Record<string, string | number | boolean> {
  deviceId: string;
  backupName: string;
  description: string;
  data: string;
}

/**
 * 更新备份数据接口
 */
interface UpdateBackupData extends Record<string, string | number | boolean> {
  backupName: string;
  description: string;
}

/**
 * 恢复备份数据接口
 */
interface RestoreBackupData extends Record<string, string | number | boolean> {
  deviceId: string;
}

/**
 * API服务类 - 封装所有后端API调用
 */
export class ApiService {

  /**
   * 创建 URLSearchParams 实例
   */
  private static createURLSearchParams(): URLSearchParams {
    return new URLSearchParams();
  }

  /**
   * 创建空的记录对象
   */
  private static createEmptyRecord(): Record<string, string | number | boolean> {
    return {};
  }

  /**
   * 创建下载请求数据
   */
  private static createDownloadRequestData(pluginId: string, version: string, deviceId: string): DownloadRequestData {
    return {
      pluginId: pluginId,
      version: version,
      deviceId: deviceId,
      userAgent: 'IFTTT-HarmonyOS/1.0.0'
    };
  }

  /**
   * 创建备份请求数据
   */
  private static createBackupRequestData(name: string, description: string, data: Record<string, string | number | boolean>): BackupRequestData {
    return {
      name: name,
      description: description,
      data: JSON.stringify(data)
    };
  }

  /**
   * 创建下载结果数据
   */
  private static createDownloadResultData(success: boolean, errorMessage?: string): DownloadResultData {
    return {
      success: success,
      errorMessage: errorMessage || ''
    };
  }

  /**
   * 创建备份数据
   */
  private static createBackupData(deviceId: string, backupName: string, description?: string, data?: Record<string, string | number | boolean>): CreateBackupData {
    return {
      deviceId: deviceId,
      backupName: backupName,
      description: description || '',
      data: JSON.stringify(data || ApiService.createEmptyRecord())
    };
  }

  /**
   * 创建更新备份数据
   */
  private static createUpdateBackupData(backupName?: string, description?: string): UpdateBackupData {
    return {
      backupName: backupName || '',
      description: description || ''
    };
  }

  /**
   * 创建恢复备份数据
   */
  private static createRestoreBackupData(deviceId: string): RestoreBackupData {
    return {
      deviceId: deviceId
    };
  }

  /**
   * 插件相关API
   */
  static async getPlugins(params?: SearchParams): Promise<ApiResponse<PageResponse<Plugin>>> {
    const queryParams = ApiService.createURLSearchParams();
    
    if (params) {
      if (params.keyword) queryParams.append('keyword', params.keyword);
      if (params.author) queryParams.append('author', params.author);
      if (params.category) queryParams.append('category', params.category);
      if (params.sortBy) queryParams.append('sortBy', params.sortBy);
      if (params.sortOrder) queryParams.append('sortOrder', params.sortOrder);
      if (params.page !== undefined) queryParams.append('page', params.page.toString());
      if (params.size !== undefined) queryParams.append('size', params.size.toString());
    }
    
    const url = `/v1/plugins${queryParams.toString() ? '?' + queryParams.toString() : ''}`;
    return apiClient.get<PageResponse<Plugin>>(url);
  }

  static async getPlugin(pluginId: string): Promise<ApiResponse<PluginDetail>> {
    return apiClient.get<PluginDetail>(`/v1/plugins/${pluginId}`);
  }

  static async getPluginVersions(pluginId: string): Promise<ApiResponse<PluginVersion[]>> {
    return apiClient.get<PluginVersion[]>(`/v1/plugins/${pluginId}/versions`);
  }

  static async getPopularPlugins(limit: number = 10): Promise<ApiResponse<Plugin[]>> {
    return apiClient.get<Plugin[]>(`/plugins/popular?limit=${limit}`);
  }

  static async getRecentPlugins(limit: number = 10): Promise<ApiResponse<Plugin[]>> {
    return apiClient.get<Plugin[]>(`/plugins/recent?limit=${limit}`);
  }

  static async searchPlugins(keyword: string, page: number = 0, size: number = 20): Promise<ApiResponse<PageResponse<Plugin>>> {
    return apiClient.get<PageResponse<Plugin>>(`/plugins/search?keyword=${encodeURIComponent(keyword)}&page=${page}&size=${size}`);
  }

  /**
   * 下载相关API
   */
  static async downloadPlugin(pluginId: string, version: string, deviceId: string): Promise<ApiResponse<string>> {
    const requestData: DownloadRequestData = ApiService.createDownloadRequestData(pluginId, version, deviceId);
    return apiClient.post<string>('/downloads', requestData);
  }

  static async getDownloadUrl(pluginId: string, version: string): Promise<ApiResponse<string>> {
    return apiClient.get<string>(`/downloads/${pluginId}/${version}/url`);
  }

  static async getDownloadLogs(deviceId: string, page: number = 0, size: number = 20): Promise<ApiResponse<PageResponse<DownloadLog>>> {
    return apiClient.get<PageResponse<DownloadLog>>(`/downloads/logs?deviceId=${deviceId}&page=${page}&size=${size}`);
  }

  static async reportDownloadResult(logId: number, success: boolean, errorMessage?: string): Promise<ApiResponse<void>> {
    const requestData: DownloadResultData = ApiService.createDownloadResultData(success, errorMessage);
    return apiClient.post<void>(`/downloads/logs/${logId}/result`, requestData);
  }

  /**
   * 备份相关API
   */
  static async getBackups(deviceId: string, page: number = 0, size: number = 20): Promise<ApiResponse<PageResponse<Backup>>> {
    return apiClient.get<PageResponse<Backup>>(`/backups?deviceId=${deviceId}&page=${page}&size=${size}`);
  }

  static async getBackup(backupId: number): Promise<ApiResponse<BackupDetail>> {
    return apiClient.get<BackupDetail>(`/backups/${backupId}`);
  }

  static async createBackup(deviceId: string, backupName: string, description?: string, data?: Record<string, string | number | boolean>): Promise<ApiResponse<Backup>> {
    const requestData: CreateBackupData = ApiService.createBackupData(deviceId, backupName, description, data);
    return apiClient.post<Backup>('/backups', requestData);
  }

  static async updateBackup(backupId: number, backupName?: string, description?: string): Promise<ApiResponse<Backup>> {
    const requestData: UpdateBackupData = ApiService.createUpdateBackupData(backupName, description);
    return apiClient.put<Backup>(`/backups/${backupId}`, requestData);
  }

  static async deleteBackup(backupId: number): Promise<ApiResponse<void>> {
    return apiClient.delete<void>(`/backups/${backupId}`);
  }

  static async restoreBackup(backupId: number, deviceId: string): Promise<ApiResponse<void>> {
    const requestData: RestoreBackupData = ApiService.createRestoreBackupData(deviceId);
    return apiClient.post<void>(`/backups/${backupId}/restore`, requestData);
  }

  /**
   * 统计相关API
   */
  static async getStatistics(): Promise<ApiResponse<Statistics>> {
    return apiClient.get<Statistics>('/stats');
  }

  static async getPluginStats(pluginId: string): Promise<ApiResponse<Record<string, string | number>>> {
    return apiClient.get<Record<string, string | number>>(`/stats/plugins/${pluginId}`);
  }

  static async getDownloadStats(days: number = 30): Promise<ApiResponse<Record<string, string | number>>> {
    return apiClient.get<Record<string, string | number>>(`/stats/downloads?days=${days}`);
  }

  static async getUserStats(deviceId: string): Promise<ApiResponse<Record<string, string | number>>> {
    return apiClient.get<Record<string, string | number>>(`/stats/users/${deviceId}`);
  }

  /**
   * 文件相关API
   */
  static async uploadFile(file: File, pluginId: string, version: string, releaseNote?: string): Promise<ApiResponse<FileUploadResponse>> {
    const formData: FormData = new FormData();
    formData.append('file', file);
    formData.append('pluginId', pluginId);
    formData.append('version', version);
    if (releaseNote) {
      formData.append('releaseNote', releaseNote);
    }

    return apiClient.post<FileUploadResponse>('/files/upload', formData, {
      'Content-Type': 'multipart/form-data'
    });
  }

  static async getFileInfo(pluginId: string, version: string, fileName: string): Promise<ApiResponse<FileInfo>> {
    return apiClient.get<FileInfo>(`/files/${pluginId}/${version}/${fileName}/info`);
  }

  static async deleteFile(pluginId: string, version: string, fileName: string): Promise<ApiResponse<void>> {
    return apiClient.delete<void>(`/files/${pluginId}/${version}/${fileName}`);
  }

  /**
   * 健康检查
   */
  static async healthCheck(): Promise<ApiResponse<Record<string, string | boolean>>> {
    return apiClient.get<Record<string, string | boolean>>('/actuator/health');
  }

  /**
   * 获取服务器信息
   */
  static async getServerInfo(): Promise<ApiResponse<Record<string, string | number>>> {
    return apiClient.get<Record<string, string | number>>('/actuator/info');
  }
}

/**
 * 插件服务 - 专门处理插件相关操作
 */
export class PluginService {
  
  /**
   * 获取插件列表（带缓存）
   */
  static async getPluginList(params?: SearchParams, useCache: boolean = true): Promise<Plugin[]> {
    try {
      const response = await ApiService.getPlugins(params);
      if (response.success && response.data) {
        return response.data.content;
      }
      return [];
    } catch (error) {
      console.error('Failed to get plugin list:', error);
      return [];
    }
  }

  /**
   * 搜索插件
   */
  static async searchPlugins(keyword: string): Promise<Plugin[]> {
    try {
      const response = await ApiService.searchPlugins(keyword);
      if (response.success && response.data) {
        return response.data.content;
      }
      return [];
    } catch (error) {
      console.error('Failed to search plugins:', error);
      return [];
    }
  }

  /**
   * 获取热门插件
   */
  static async getPopularPlugins(): Promise<Plugin[]> {
    try {
      const response = await ApiService.getPopularPlugins();
      if (response.success && response.data) {
        return response.data;
      }
      return [];
    } catch (error) {
      console.error('Failed to get popular plugins:', error);
      return [];
    }
  }

  /**
   * 下载插件
   */
  static async downloadPlugin(pluginId: string, version: string, deviceId: string): Promise<string | null> {
    try {
      const response = await ApiService.downloadPlugin(pluginId, version, deviceId);
      if (response.success && response.data) {
        return response.data;
      }
      return null;
    } catch (error) {
      console.error('Failed to download plugin:', error);
      return null;
    }
  }
}

/**
 * 备份服务 - 专门处理备份相关操作
 */
export class BackupService {
  
  /**
   * 获取备份列表
   */
  static async getBackupList(deviceId: string): Promise<Backup[]> {
    try {
      const response = await ApiService.getBackups(deviceId);
      if (response.success && response.data) {
        return response.data.content;
      }
      return [];
    } catch (error) {
      console.error('Failed to get backup list:', error);
      return [];
    }
  }

  /**
   * 创建备份
   */
  static async createBackup(deviceId: string, name: string, description?: string, data?: Record<string, string | number | boolean>): Promise<Backup | null> {
    try {
      const response = await ApiService.createBackup(deviceId, name, description, data);
      if (response.success && response.data) {
        return response.data;
      }
      return null;
    } catch (error) {
      console.error('Failed to create backup:', error);
      return null;
    }
  }

  /**
   * 恢复备份
   */
  static async restoreBackup(backupId: number, deviceId: string): Promise<boolean> {
    try {
      const response = await ApiService.restoreBackup(backupId, deviceId);
      return response.success;
    } catch (error) {
      console.error('Failed to restore backup:', error);
      return false;
    }
  }
}
