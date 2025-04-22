import { CirclePage } from './CirclePage'
import { MinePage } from './MinePage'
import { PracticePage } from './PracticePage'

@Entry
@Component
struct Index {
  @StorageLink('currentTabIndex') currentTabIndex: number = 0

  build() {
    Tabs({ index: this.currentTabIndex }) {
      TabContent() {
        PracticePage()
      }.tabBar(this.barBuilder(0, $r('app.media.ic_practice'), $r('app.media.ic_practice_selected'), '答题'))

      TabContent() {
        CirclePage()
      }.tabBar(this.barBuilder(1, $r('app.media.ic_circle'), $r('app.media.ic_circle_selected'), '圈子'))


      TabContent() {
        MinePage()
      }.tabBar(this.barBuilder(2, $r('app.media.ic_mine'), $r('app.media.ic_mine_selected'), '我的'))
    }
    .barPosition(BarPosition.End)
    .onChange((index) => {
      this.currentTabIndex = index
    })
  }

  // 自定义tabBar
  @Builder
  barBuilder(index: number, icon: Resource, selectedIcon: Resource, title: string) {
    Column() {
      Image(index === this.currentTabIndex ? selectedIcon : icon).width(25).height(25)
      Text(title).tabTitleStyle(index === this.currentTabIndex ? Color.Black : '#959595')
    }
  }
}


@Extend(Text)
function tabTitleStyle(color: ResourceColor) {
  .fontSize(10)
  .fontWeight(FontWeight.Medium)
  .fontColor(color) //Color.Black
  .margin({ bottom: 2 })
}