import { PostInfo, PostType } from "../model/PostInfo"
import { promptAction, router } from "@kit.ArkUI"
import { StatItem } from "./PracticePage"
import { convertMillisecondsToTime } from "../utils/DateUtil"
import { cancelLike, getAllPost, like } from "../http/Api"
import { AxiosResponse } from "@ohos/axios"
import { emitter } from "@kit.BasicServicesKit"


@Component
export struct CirclePage {
  @State postInfoList: PostInfo[] = []
  @StorageProp('token') @Watch('onTokenChange') token: string = ''
  // 避免 List 组件首次加载触发 onReachEnd 事件
  initLoad: boolean = false
  total: number = 0
  page: number = 1
  @State isLoading: boolean = false
  scroller: Scroller = new Scroller()

  // 加载数据的逻辑
  async getPostInfoPage() {
    let response: AxiosResponse = await getAllPost(this.page, 10)
    response.data.data.records.forEach((post: PostType) => this.postInfoList.push(new PostInfo(post)))
    this.total = response.data.data.total
    this.page++
    this.initLoad = true
  }

  // 刷新页面的逻辑
  async refresh() {
    this.isLoading = true
    this.postInfoList = []
    this.page = 1
    this.total = 0
    await this.getPostInfoPage()
    this.isLoading = false
  }

  // 如果已经登录--加载第一页数据
  aboutToAppear() {
    if (this.token) {
      this.getPostInfoPage()
    }

    emitter.on({ eventId: 1 }, () => {
      this.refresh()
    })
  }

  // 监听token变化
  // 如果启动应用时不是登录状态
  // 等到用户登录成功之后加载第一页数据(token从无到有--登录成功加载第一页数据)
  onTokenChange() {
    if (this.token) {
      this.getPostInfoPage()
    } else {
      // token从有到无清除缓存
      this.postInfoList = []
      this.total = 0
      this.page = 1
    }
  }

  build() {
    Column() {
      Text('英语打卡圈')
        .fontSize(18)
        .margin({ top: 45 })
        .fontWeight(FontWeight.Bold)
      Divider()
        .color(Color.Black)
        .margin({ left: 20, right: 20, top: 10 })

      if (this.token) {
        if (this.isLoading) {
          this.loadingBuilder()
        } else {
          //打卡列表
          this.listBuilder()
        }
      } else {
        //未登录
        this.unLoginBuilder()
      }
    }.height('100%')
    .width('100%')
  }

  // loading组件
  @Builder
  loadingBuilder() {
    Column({ space: 15 }) {
      Image($r('app.media.ic_loading'))
        .width(30)
        .height(30)
      Text('加载中...')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#7e8892')
    }.width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  unLoginBuilder() {
    Column({ space: 30 }) {
      Image($r("app.media.ic_unLogin_bg"))
        .width(177)
        .height(177)

      Text('未登录暂无数据')
        .fontSize(14)
        .fontColor('#999999')

      Button('去登录')
        .fontColor(Color.White)
        .fontSize(14)
        .width(100)
        .height(34)
        .backgroundColor('#43C6A0')
        .onClick(() => router.pushUrl({ url: 'pages/LoginPage' }))
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  listBuilder() {
    Stack() {
      List({ scroller: this.scroller }) {
        ForEach(this.postInfoList, (post: PostType) => {
          ListItem() {
            PostItem({ post: post })
          }
        })
      }.width('100%')
      .height('100%')
      .alignListItem(ListItemAlign.Center)
      .onReachEnd(() => {
        if (this.initLoad) {
          if (this.postInfoList.length < this.total) {
            this.getPostInfoPage()
          } else {
            promptAction.showToast({ message: '没有更多数据了' })
          }
        }
      })

      Column({ space: 20 }) {
        Button({ type: ButtonType.Circle }) {
          Image($r('app.media.ic_top'))
            .height(14)
            .width(14)
        }
        .height(40)
        .width(40)
        .backgroundColor(Color.Black)
        .opacity(0.5)
        .onClick(() => {
          //返回顶部
          this.scroller.scrollToIndex(0)
        })

        Button({ type: ButtonType.Circle }) {
          Image($r('app.media.ic_refresh'))
            .height(14)
            .width(14)
        }
        .height(40)
        .width(40)
        .backgroundColor(Color.Black)
        .opacity(0.5)
        .onClick(() => {
          //刷新
          this.refresh()
        })
      }
      .offset({ x: -20, y: -50 })
    }.width('100%')
    .layoutWeight(1)
    .alignContent(Alignment.BottomEnd)
  }
}


@Component
struct PostItem {
  @ObjectLink post: PostInfo;

  build() {
    Column({ space: 10 }) {
      Row({ space: 10 }) {
        Image(this.post.avatarUrl)
          .height(40)
          .width(40)
          .borderRadius(20)
        Text(this.post.nickname)
          .height(40)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
        Blank()
        Text(this.post.createTime)
          .height(40)
          .fontSize(14)
          .fontColor('#999999')
          .fontWeight(FontWeight.Medium)
      }.width('100%')

      Text(this.post.postText)
        .width('100%')

      Row() {
        Column() {
          StatItem({
            icon: $r('app.media.ic_timer_white'),
            name: '用时',
            fontColor: Color.White
          }) {
            Text(convertMillisecondsToTime(this.post.timeUsed))
              .statTextStyle()
          }

          StatItem({
            icon: $r('app.media.ic_accuracy_white'),
            name: '准确率',
            fontColor: Color.White
          }) {
            Text((this.post.answeredCount === 0 ? 0 : this.post.rightCount / this.post.answeredCount * 100).toFixed(0) +
              '%')
              .statTextStyle()
          }

          StatItem({
            icon: $r('app.media.ic_count_white'),
            name: '个数',
            fontColor: Color.White
          }) {
            Text(this.post.answeredCount.toString())
              .statTextStyle()
          }
        }
        .padding(10)
        .borderRadius(10)
        .layoutWeight(1)
        .backgroundImage($r('app.media.img_post_bg'))
        .backgroundImageSize(ImageSize.Cover)

        Column() {
          Text(this.post.likeCount.toString())
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.post.isLike ? '#3ECBA1' : '#000000')
          Image(this.post.isLike ? $r('app.media.ic_post_like_selected') : $r('app.media.ic_post_like'))
            .width(26)
            .height(26)
            .onClick(() => {
              // 点赞/取消点赞
              if (this.post.isLike) {
                // 取消点赞
                this.post.isLike = false
                this.post.likeCount--
                cancelLike(this.post.id)
              } else {
                // 点赞
                this.post.isLike = true
                this.post.likeCount++
                like(this.post.id)
              }
            })
        }.width(50)
      }.width('100%')
      .alignItems(VerticalAlign.Bottom)
    }
    .padding(10)
    .width('90%')
    .margin({ top: 10 })
    .borderRadius(10)
    .shadow({ radius: 20 })
  }
}

@Extend(Text)
function statTextStyle() {
  .width(100)
  .fontSize(16)
  .textAlign(TextAlign.End)
  .fontWeight(FontWeight.Medium)
  .fontColor(Color.White)
}