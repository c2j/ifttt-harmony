import { AppState, ErrorInfo, NetworkStatus, SyncStatus, DeviceInfo } from '../types/ApiTypes';

/**
 * 应用全局状态管理
 */
export class AppStore {
  private static instance: AppStore;
  private state: AppState;
  private listeners: Set<(state: AppState) => void> = new Set();

  private constructor() {
    this.state = {
      isLoading: false,
      networkStatus: {
        connected: true,
        type: 'wifi',
        strength: 100
      },
      syncStatus: {
        inProgress: false,
        totalItems: 0,
        syncedItems: 0,
        failedItems: 0,
        errors: []
      }
    };
  }

  /**
   * 获取单例实例
   */
  static getInstance(): AppStore {
    if (!AppStore.instance) {
      AppStore.instance = new AppStore();
    }
    return AppStore.instance;
  }

  /**
   * 获取当前状态
   */
  getState(): AppState {
    return this.cloneAppState(this.state);
  }

  /**
   * 订阅状态变化
   */
  subscribe(listener: (state: AppState) => void): () => void {
    this.listeners.add(listener);
    return () => {
      this.listeners.delete(listener);
    };
  }

  /**
   * 更新状态
   */
  private setState(newState: Partial<AppState>): void {
    this.state = this.mergeAppState(this.state, newState);
    this.notifyListeners();
  }

  /**
   * 通知所有监听器
   */
  private notifyListeners(): void {
    this.listeners.forEach(listener => {
      try {
        listener(this.getState());
      } catch (error) {
        console.error('Error in state listener:', error);
      }
    });
  }

  /**
   * 克隆应用状态
   */
  private cloneAppState(state: AppState): AppState {
    return {
      isLoading: state.isLoading,
      error: state.error,
      currentUser: state.currentUser,
      syncStatus: this.cloneSyncStatus(state.syncStatus),
      networkStatus: this.cloneNetworkStatus(state.networkStatus)
    };
  }

  /**
   * 克隆同步状态
   */
  private cloneSyncStatus(syncStatus: SyncStatus): SyncStatus {
    return {
      inProgress: syncStatus.inProgress,
      lastSyncTime: syncStatus.lastSyncTime,
      totalItems: syncStatus.totalItems,
      syncedItems: syncStatus.syncedItems,
      failedItems: syncStatus.failedItems,
      errors: syncStatus.errors ? this.cloneStringArray(syncStatus.errors) : []
    };
  }

  /**
   * 克隆网络状态
   */
  private cloneNetworkStatus(networkStatus: NetworkStatus): NetworkStatus {
    return {
      connected: networkStatus.connected,
      type: networkStatus.type,
      strength: networkStatus.strength
    };
  }

  /**
   * 克隆字符串数组
   */
  private cloneStringArray(arr: string[]): string[] {
    const result: string[] = [];
    for (let i = 0; i < arr.length; i++) {
      result.push(arr[i]);
    }
    return result;
  }

  /**
   * 合并应用状态
   */
  private mergeAppState(current: AppState, updates: Partial<AppState>): AppState {
    const result: AppState = this.cloneAppState(current);

    if (updates.isLoading !== undefined) result.isLoading = updates.isLoading;
    if (updates.error !== undefined) result.error = updates.error;
    if (updates.currentUser !== undefined) result.currentUser = updates.currentUser;
    if (updates.syncStatus !== undefined) result.syncStatus = updates.syncStatus;
    if (updates.networkStatus !== undefined) result.networkStatus = updates.networkStatus;

    return result;
  }

  /**
   * 合并同步状态
   */
  private mergeSyncStatus(current: SyncStatus, updates: Partial<SyncStatus>): SyncStatus {
    const result: SyncStatus = this.cloneSyncStatus(current);

    if (updates.inProgress !== undefined) result.inProgress = updates.inProgress;
    if (updates.lastSyncTime !== undefined) result.lastSyncTime = updates.lastSyncTime;
    if (updates.totalItems !== undefined) result.totalItems = updates.totalItems;
    if (updates.syncedItems !== undefined) result.syncedItems = updates.syncedItems;
    if (updates.failedItems !== undefined) result.failedItems = updates.failedItems;
    if (updates.errors !== undefined) result.errors = updates.errors;

    return result;
  }

  /**
   * 设置加载状态
   */
  setLoading(isLoading: boolean): void {
    this.setState({ isLoading });
  }

  /**
   * 设置错误信息
   */
  setError(error: ErrorInfo | null): void {
    this.setState({ error: error || undefined });
  }

  /**
   * 清除错误
   */
  clearError(): void {
    this.setState({ error: undefined });
  }

  /**
   * 更新网络状态
   */
  updateNetworkStatus(networkStatus: NetworkStatus): void {
    this.setState({ networkStatus });
  }

  /**
   * 更新同步状态
   */
  updateSyncStatus(syncStatus: Partial<SyncStatus>): void {
    const currentSyncStatus = this.state.syncStatus;
    const newSyncStatus: SyncStatus = this.mergeSyncStatus(currentSyncStatus, syncStatus);
    this.setState({
      syncStatus: newSyncStatus
    });
  }

  /**
   * 开始同步
   */
  startSync(totalItems: number = 0): void {
    this.updateSyncStatus({
      inProgress: true,
      totalItems,
      syncedItems: 0,
      failedItems: 0,
      errors: []
    });
  }

  /**
   * 更新同步进度
   */
  updateSyncProgress(syncedItems: number, failedItems: number = 0, errors: string[] = []): void {
    this.updateSyncStatus({
      syncedItems,
      failedItems,
      errors
    });
  }

  /**
   * 完成同步
   */
  finishSync(): void {
    this.updateSyncStatus({
      inProgress: false,
      lastSyncTime: Date.now()
    });
  }

  /**
   * 设置当前用户
   */
  setCurrentUser(user: DeviceInfo): void {
    this.setState({ currentUser: user });
  }

  /**
   * 清除当前用户
   */
  clearCurrentUser(): void {
    this.setState({ currentUser: undefined });
  }
}

/**
 * 全局状态管理实例
 */
export const appStore = AppStore.getInstance();

/**
 * React式状态Hook（用于组件中）
 */
export function useAppState(): [AppState, (newState: Partial<AppState>) => void] {
  const store = AppStore.getInstance();
  
  return [
    store.getState(),
    (newState: Partial<AppState>) => {
      // 这里可以添加状态更新逻辑
      console.info('State update requested:', newState);
    }
  ];
}

/**
 * 加载状态Hook
 */
export function useLoading(): [boolean, (loading: boolean) => void] {
  const store = AppStore.getInstance();
  
  return [
    store.getState().isLoading,
    (loading: boolean) => store.setLoading(loading)
  ];
}

/**
 * 错误状态Hook
 */
export function useError(): [ErrorInfo | undefined, (error: ErrorInfo | null) => void, () => void] {
  const store = AppStore.getInstance();
  
  return [
    store.getState().error,
    (error: ErrorInfo | null) => store.setError(error),
    () => store.clearError()
  ];
}

/**
 * 网络状态Hook
 */
export function useNetworkStatus(): [NetworkStatus, (status: NetworkStatus) => void] {
  const store = AppStore.getInstance();
  
  return [
    store.getState().networkStatus,
    (status: NetworkStatus) => store.updateNetworkStatus(status)
  ];
}

/**
 * 同步操作接口
 */
interface SyncOperations {
  start: (totalItems?: number) => void;
  updateProgress: (synced: number, failed?: number, errors?: string[]) => void;
  finish: () => void;
}

/**
 * 同步状态Hook
 */
export function useSyncStatus(): [SyncStatus, SyncOperations] {
  const store = AppStore.getInstance();
  
  const operations: SyncOperations = {
    start: (totalItems?: number) => store.startSync(totalItems),
    updateProgress: (synced: number, failed?: number, errors?: string[]) =>
      store.updateSyncProgress(synced, failed, errors),
    finish: () => store.finishSync()
  };

  return [store.getState().syncStatus, operations];
}
