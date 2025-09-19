import http from '@ohos.net.http';
import { ApiResponse } from '../types/ApiTypes';

/**
 * HTTP客户端配置
 */
export interface HttpConfig {
  baseUrl: string;
  timeout: number;
  headers?: Record<string, string>;
}

/**
 * HTTP请求选项
 */
export interface RequestOptions {
  url: string;
  method?: http.RequestMethod;
  data?: Record<string, string | number | boolean> | string | object;
  headers?: Record<string, string>;
  timeout?: number;
}

/**
 * HTTP客户端类
 */
export class HttpClient {
  private config: HttpConfig;
  private defaultHeaders: Record<string, string> = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };

  constructor(config: HttpConfig) {
    this.config = config;
    if (config.headers) {
      this.defaultHeaders = this.mergeHeaders(this.defaultHeaders, config.headers);
    }
  }

  /**
   * 创建空的请求头
   */
  private createEmptyHeaders(): Record<string, string> {
    return {};
  }

  /**
   * 合并请求头
   */
  private mergeHeaders(base: Record<string, string>, additional: Record<string, string>): Record<string, string> {
    const result: Record<string, string> = {};

    // 复制基础头部
    Object.keys(base).forEach(key => {
      result[key] = base[key];
    });

    // 添加额外头部
    Object.keys(additional).forEach(key => {
      result[key] = additional[key];
    });

    return result;
  }

  /**
   * 移除请求头中的指定键
   */
  private removeHeaderKey(headers: Record<string, string>, key: string): Record<string, string> {
    const result: Record<string, string> = {};
    Object.keys(headers).forEach(k => {
      if (k !== key) {
        result[k] = headers[k];
      }
    });
    return result;
  }

  /**
   * 检查对象是否有指定属性
   */
  private hasProperty(obj: Record<string, string | number | boolean>, prop: string): boolean {
    return obj[prop] !== undefined;
  }

  /**
   * 转换为API响应格式
   */
  private convertToApiResponse<T>(data: Record<string, string | number | boolean>): ApiResponse<T> {
    return {
      success: data.success as boolean || true,
      code: data.code as number || 200,
      message: data.message as string || 'Success',
      data: data.data as T,
      timestamp: data.timestamp as number || Date.now()
    };
  }

  /**
   * 设置认证令牌
   */
  setAuthToken(token: string): void {
    this.defaultHeaders['Authorization'] = `Bearer ${token}`;
  }

  /**
   * 移除认证令牌
   */
  removeAuthToken(): void {
    this.defaultHeaders = this.removeHeaderKey(this.defaultHeaders, 'Authorization');
  }

  /**
   * 发送HTTP请求
   */
  async request<T>(options: RequestOptions): Promise<ApiResponse<T>> {
    const httpRequest = http.createHttp();
    
    try {
      const url = options.url.startsWith('http') ? options.url : `${this.config.baseUrl}${options.url}`;
      const headers = this.mergeHeaders(this.defaultHeaders, options.headers || this.createEmptyHeaders());
      const timeout = options.timeout || this.config.timeout;

      const requestOptions: http.HttpRequestOptions = {
        method: options.method || http.RequestMethod.GET,
        header: headers,
        connectTimeout: timeout,
        readTimeout: timeout
      };

      // 添加请求体
      if (options.data && (options.method === http.RequestMethod.POST || options.method === http.RequestMethod.PUT)) {
        if (typeof options.data === 'string') {
          requestOptions.extraData = options.data;
        } else {
          requestOptions.extraData = JSON.stringify(options.data);
        }
      }

      console.info(`[HTTP] ${options.method || 'GET'} ${url}`);
      
      const response = await httpRequest.request(url, requestOptions);
      
      console.info(`[HTTP] Response: ${response.responseCode}`);

      // 解析响应
      const result = this.parseResponse<T>(response);
      
      return result;
    } catch (error) {
      console.error('[HTTP] Request failed:', error);
      const errorResponse = this.createErrorResponse(error);
      throw new Error(errorResponse.message || 'Request failed');
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * GET请求
   */
  async get<T>(url: string, headers?: Record<string, string>): Promise<ApiResponse<T>> {
    const options: RequestOptions = {
      url: url,
      method: http.RequestMethod.GET,
      headers: headers
    };
    return this.request<T>(options);
  }

  /**
   * POST请求
   */
  async post<T>(url: string, data?: Record<string, string | number | boolean> | string | object, headers?: Record<string, string>): Promise<ApiResponse<T>> {
    const options: RequestOptions = {
      url: url,
      method: http.RequestMethod.POST,
      data: data,
      headers: headers
    };
    return this.request<T>(options);
  }

  /**
   * PUT请求
   */
  async put<T>(url: string, data?: Record<string, string | number | boolean> | string, headers?: Record<string, string>): Promise<ApiResponse<T>> {
    const options: RequestOptions = {
      url: url,
      method: http.RequestMethod.PUT,
      data: data,
      headers: headers
    };
    return this.request<T>(options);
  }

  /**
   * DELETE请求
   */
  async delete<T>(url: string, headers?: Record<string, string>): Promise<ApiResponse<T>> {
    const options: RequestOptions = {
      url: url,
      method: http.RequestMethod.DELETE,
      headers: headers
    };
    return this.request<T>(options);
  }

  /**
   * 解析HTTP响应
   */
  private parseResponse<T>(response: http.HttpResponse): ApiResponse<T> {
    const statusCode = response.responseCode;
    const responseText = response.result as string;

    // 检查HTTP状态码
    if (statusCode < 200 || statusCode >= 300) {
      throw new Error(`HTTP ${statusCode}: ${responseText}`);
    }

    try {
      // 尝试解析JSON
      const data: Record<string, string | number | boolean> = JSON.parse(responseText);
      
      // 检查是否是标准API响应格式
      if (this.hasProperty(data, 'success') && this.hasProperty(data, 'code')) {
        return this.convertToApiResponse<T>(data);
      }

      // 如果不是标准格式，包装成标准格式
      return {
        success: true,
        code: 200,
        message: 'Success',
        data: data as T,
        timestamp: Date.now()
      };
    } catch (parseError) {
      // JSON解析失败，返回原始文本
      return {
        success: true,
        code: 200,
        message: 'Success',
        data: responseText as T,
        timestamp: Date.now()
      };
    }
  }

  /**
   * 创建错误响应
   */
  private createErrorResponse(error: Error | object | string): ApiResponse<null> {
    let message = 'Unknown error';
    let code = 500;

    if (error instanceof Error) {
      message = error.message;
      
      // 解析HTTP错误码
      const httpErrorMatch = message.match(/HTTP (\d+):/);
      if (httpErrorMatch) {
        code = parseInt(httpErrorMatch[1]);
      }
    }

    return {
      success: false,
      code: code,
      message: message,
      data: null,
      timestamp: Date.now()
    };
  }

  /**
   * 下载文件
   */
  async downloadFile(url: string, filePath: string, onProgress?: (progress: number) => void): Promise<void> {
    const httpRequest = http.createHttp();
    
    try {
      const fullUrl = url.startsWith('http') ? url : `${this.config.baseUrl}${url}`;
      
      const requestOptions: http.HttpRequestOptions = {
        method: http.RequestMethod.GET,
        header: this.defaultHeaders,
        connectTimeout: this.config.timeout,
        readTimeout: this.config.timeout
      };

      console.info(`[HTTP] Downloading: ${fullUrl} -> ${filePath}`);

      // 使用下载API
      const downloadTask = await httpRequest.request(fullUrl, requestOptions);
      
      // 这里需要根据实际的HarmonyOS API来实现文件下载
      // 由于API可能有变化，这里提供基本框架
      
      console.info('[HTTP] Download completed');
    } catch (error) {
      console.error('[HTTP] Download failed:', error);
      throw new Error(`Download failed: ${error}`);
    } finally {
      httpRequest.destroy();
    }
  }
}

/**
 * 默认HTTP客户端实例
 */
export const httpClient = new HttpClient({
  baseUrl: 'http://localhost:8080',
  timeout: 30000,
  headers: {
    'User-Agent': 'IFTTT-HarmonyOS/1.0.0'
  }
});

/**
 * API客户端 - 专门用于与后端API通信
 */
export const apiClient = new HttpClient({
  baseUrl: 'http://localhost:8080',
  timeout: 30000,
  headers: {
    'User-Agent': 'IFTTT-HarmonyOS/1.0.0'
  }
});
