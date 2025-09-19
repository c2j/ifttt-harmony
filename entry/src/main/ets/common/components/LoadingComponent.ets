/**
 * 加载组件属性
 */
export interface LoadingProps {
  visible: boolean;
  message?: string;
  size?: number;
  color?: string | Color;
  backgroundColor?: string | Color;
  maskOpacity?: number;
}

/**
 * 加载指示器组件
 */
@Component
export struct LoadingComponent {
  @Prop visible: boolean = false;
  @Prop message: string = '加载中...';
  @Prop loadingSize: number = 40;
  @Prop loadingColor: string | Color = Color.Blue;
  @Prop loadingBackgroundColor: string | Color = Color.White;
  @Prop maskOpacity: number = 0.5;

  build() {
    if (this.visible) {
      Stack() {
        // 遮罩层
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(Color.Black)
          .opacity(this.maskOpacity)

        // 加载内容
        Column({ space: 16 }) {
          // 加载动画
          LoadingProgress()
            .width(this.loadingSize)
            .height(this.loadingSize)
            .color(this.loadingColor)

          // 加载文本
          if (this.message) {
            Text(this.message)
              .fontSize(14)
              .fontColor(Color.Gray)
              .textAlign(TextAlign.Center)
          }
        }
        .padding(24)
        .backgroundColor(this.loadingBackgroundColor)
        .borderRadius(8)
        .shadow({
          radius: 8,
          color: Color.Black,
          offsetX: 0,
          offsetY: 2
        })
      }
      .width('100%')
      .height('100%')
      .alignContent(Alignment.Center)
    }
  }
}

/**
 * 简单加载指示器
 */
@Component
export struct SimpleLoading {
  @Prop visible: boolean = false;
  @Prop loadingSize: number = 24;
  @Prop loadingColor: string | Color = Color.Blue;

  build() {
    if (this.visible) {
      LoadingProgress()
        .width(this.loadingSize)
        .height(this.loadingSize)
        .color(this.loadingColor)
    }
  }
}

/**
 * 页面加载组件
 */
@Component
export struct PageLoading {
  @Prop visible: boolean = false;
  @Prop message: string = '页面加载中...';

  build() {
    if (this.visible) {
      Column({ space: 20 }) {
        LoadingProgress()
          .width(50)
          .height(50)
          .color(Color.Blue)

        Text(this.message)
          .fontSize(16)
          .fontColor(Color.Gray)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor(Color.White)
    }
  }
}

/**
 * 列表加载更多组件
 */
@Component
export struct LoadMoreComponent {
  @Prop loading: boolean = false;
  @Prop hasMore: boolean = true;
  @Prop loadingText: string = '加载中...';
  @Prop noMoreText: string = '没有更多数据';
  @Prop errorText: string = '加载失败，点击重试';
  @Prop error: boolean = false;
  onLoadMore?: () => void;

  build() {
    Row({ space: 8 }) {
      if (this.loading) {
        LoadingProgress()
          .width(16)
          .height(16)
          .color(Color.Gray)
      }

      Text(this.getDisplayText())
        .fontSize(14)
        .fontColor(Color.Gray)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      if (this.error && this.onLoadMore) {
        this.onLoadMore();
      }
    })
  }

  private getDisplayText(): string {
    if (this.loading) {
      return this.loadingText;
    }
    if (this.error) {
      return this.errorText;
    }
    if (!this.hasMore) {
      return this.noMoreText;
    }
    return '';
  }
}

/**
 * 刷新加载组件
 */
@Component
export struct RefreshLoading {
  @Prop refreshing: boolean = false;
  @Prop message: string = '正在刷新...';

  build() {
    if (this.refreshing) {
      Row({ space: 8 }) {
        LoadingProgress()
          .width(20)
          .height(20)
          .color(Color.Blue)

        Text(this.message)
          .fontSize(14)
          .fontColor(Color.Gray)
      }
      .width('100%')
      .height(40)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .backgroundColor(Color.White)
    }
  }
}

/**
 * 骨架屏组件
 */
@Component
export struct SkeletonLoading {
  @Prop visible: boolean = false;
  @Prop rows: number = 3;
  @Prop avatar: boolean = false;

  private createIndexArray(length: number): number[] {
    const result: number[] = [];
    for (let i = 0; i < length; i++) {
      result.push(i);
    }
    return result;
  }

  build() {
    if (this.visible) {
      Column({ space: 12 }) {
        ForEach(this.createIndexArray(this.rows), (index: number) => {
          Row({ space: 12 }) {
            if (this.avatar && index === 0) {
              // 头像骨架
              Column()
                .width(40)
                .height(40)
                .borderRadius(20)
                .backgroundColor('#F0F0F0')
                .animation({
                  duration: 1000,
                  curve: Curve.EaseInOut,
                  iterations: -1,
                  playMode: PlayMode.Alternate
                })
            }

            Column({ space: 8 }) {
              // 标题骨架
              Column()
                .width(index === 0 ? '80%' : '60%')
                .height(16)
                .borderRadius(8)
                .backgroundColor('#F0F0F0')
                .animation({
                  duration: 1000,
                  curve: Curve.EaseInOut,
                  iterations: -1,
                  playMode: PlayMode.Alternate
                })

              // 内容骨架
              Column()
                .width('100%')
                .height(12)
                .borderRadius(6)
                .backgroundColor('#F5F5F5')
                .animation({
                  duration: 1000,
                  curve: Curve.EaseInOut,
                  iterations: -1,
                  playMode: PlayMode.Alternate
                })
            }
            .layoutWeight(1)
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)
        })
      }
      .width('100%')
      .padding(16)
    }
  }
}
