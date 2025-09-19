import { AppStore } from '../../common/store/AppStore'
import { ApiService } from '../../common/services/ApiService'
import { Plugin, ApiResponse, PageResponse, SearchParams } from '../../common/types/ApiTypes'
import { LoadingComponent } from '../../common/components/LoadingComponent'

@Entry
@Component
export struct PluginsPage {
  @StorageLink('appStore') appStore: AppStore = AppStore.getInstance()
  @State plugins: Plugin[] = []
  @State isLoading: boolean = false
  @State searchText: string = ''
  @State selectedCategory: string = 'all'
  
  private apiService = new ApiService()
  
  aboutToAppear() {
    this.loadPlugins()
  }
  
  /**
   * 创建搜索参数
   */
  private createSearchParams(): SearchParams {
    const params: SearchParams = {
      page: 1,
      size: 20
    };

    if (this.searchText) {
      params.keyword = this.searchText;
    }

    if (this.selectedCategory !== 'all') {
      params.category = this.selectedCategory;
    }

    return params;
  }

  async loadPlugins() {
    this.isLoading = true
    try {
      const searchParams = this.createSearchParams();
      const response: ApiResponse<PageResponse<Plugin>> = await ApiService.getPlugins(searchParams);
      this.plugins = response.data.content
    } catch (error) {
      console.error('加载插件失败:', error)
    } finally {
      this.isLoading = false
    }
  }
  
  async onSearch() {
    await this.loadPlugins()
  }
  
  async onCategoryChange(category: string) {
    this.selectedCategory = category
    await this.loadPlugins()
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('插件市场')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .flexGrow(1)
        
        Button('刷新')
          .fontSize(14)
          .backgroundColor('#007AFF')
          .borderRadius(6)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .onClick(() => this.loadPlugins())
      }
      .width('100%')
      .margin({ bottom: 16 })
      
      // 搜索栏
      Row() {
        TextInput({ placeholder: '搜索插件...', text: this.searchText })
          .flexGrow(1)
          .onChange((value: string) => {
            this.searchText = value
          })
          .onSubmit(() => this.onSearch())
        
        Button('搜索')
          .fontSize(14)
          .backgroundColor('#007AFF')
          .borderRadius(6)
          .margin({ left: 8 })
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .onClick(() => this.onSearch())
      }
      .width('100%')
      .margin({ bottom: 16 })
      
      // 分类筛选
      Row() {
        Text('分类:')
          .fontSize(14)
          .fontColor('#666666')
          .margin({ right: 8 })
        
        Button('全部')
          .fontSize(12)
          .backgroundColor(this.selectedCategory === 'all' ? '#007AFF' : '#F0F0F0')
          .fontColor(this.selectedCategory === 'all' ? Color.White : '#333333')
          .borderRadius(4)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .margin({ right: 8 })
          .onClick(() => this.onCategoryChange('all'))
        
        Button('触发器')
          .fontSize(12)
          .backgroundColor(this.selectedCategory === 'trigger' ? '#007AFF' : '#F0F0F0')
          .fontColor(this.selectedCategory === 'trigger' ? Color.White : '#333333')
          .borderRadius(4)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .margin({ right: 8 })
          .onClick(() => this.onCategoryChange('trigger'))
        
        Button('动作')
          .fontSize(12)
          .backgroundColor(this.selectedCategory === 'action' ? '#007AFF' : '#F0F0F0')
          .fontColor(this.selectedCategory === 'action' ? Color.White : '#333333')
          .borderRadius(4)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .onClick(() => this.onCategoryChange('action'))
      }
      .width('100%')
      .margin({ bottom: 16 })
      
      // 插件列表
      if (this.isLoading) {
        LoadingComponent()
      } else {
        List() {
          ForEach(this.plugins, (plugin: Plugin) => {
            ListItem() {
              this.PluginCard(plugin)
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
  PluginCard(plugin: Plugin) {
    Column() {
      Row() {
        // 插件图标
        Image(plugin.iconUrl || $r('app.media.startIcon'))
          .width(48)
          .height(48)
          .borderRadius(8)
          .margin({ right: 12 })
        
        // 插件信息
        Column() {
          Text(plugin.name)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          
          Text(plugin.description)
            .fontSize(14)
            .fontColor('#666666')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 4 })
          
          Row() {
            Text(`v${plugin.latestVersion}`)
              .fontSize(12)
              .fontColor('#999999')
            
            Text(`下载: ${plugin.downloadCount}`)
              .fontSize(12)
              .fontColor('#999999')
              .margin({ left: 16 })
          }
          .margin({ top: 8 })
        }
        .alignItems(HorizontalAlign.Start)
        .flexGrow(1)
        
        // 下载按钮
        Button('下载')
          .fontSize(14)
          .backgroundColor('#007AFF')
          .borderRadius(6)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .onClick(() => this.downloadPlugin(plugin))
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
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
  
  async downloadPlugin(plugin: Plugin) {
    try {
      console.log('开始下载插件:', plugin.pluginId)

      // 模拟下载过程
      await new Promise<void>(resolve => setTimeout(resolve, 1000));

      console.log('插件下载成功:', plugin.name)
      // TODO: 实现实际的插件下载逻辑
      // 这里应该调用 ApiService.downloadPlugin() 方法

    } catch (error) {
      console.error('下载插件失败:', error)
    }
  }
}
