// 指定应⽤初始⻚⾯
// 修改 entry/src/main/ets/entryability/EntryAbility.ts ⽂件中的如下内容，指定应⽤初始⻚⾯位欢迎⻚

import { router } from '@kit.ArkUI'

// 启动页面
@Entry
@Component
struct SplashPage {
  @State flag: boolean = false

  // ⻚⾯出现时⾃动触发动画效果
  onPageShow() {
    animateTo({
      duration: 1000,
      onFinish: () => { // 动画完成后触发函数
        setTimeout(() => {
          router.replaceUrl({ url: 'pages/Index' })
        }, 200)
      }
    }, () => {
      this.flag = true
    })
  }

  build() {
    Column() {
      if (this.flag) {
        Image($r('app.media.ic_logo'))
          .logoStyle()
          .transition({
            type: TransitionType.Insert, // 声明动画效果⽤于组件出现时
            opacity: 0, // 出现动画时的起始状态
            translate: { x: -150 }
          })

        Text('快速单词记忆神器')
          .titleStyle()
          .transition({
            type: TransitionType.Insert, // 声明动画效果⽤于组件出现时
            opacity: 0, // 出现动画时的起始状态
            translate: { x: 150 }
          })
      }
      Blank()
      Text('Atguigu Harmony Project')
        .footerStyle()
    }.bgStyle()
  }
}


@Styles
function bgStyle() {
  .width('100%')
  .height('100%')
  .backgroundImage($r('app.media.img_splash_bg'))
  .backgroundImageSize({
    width:
    '100%', height: '100%'
  })
}


@Extend(Image)
function logoStyle() {
  .width(90)
  .height(90)
  .margin({ top: 120 })
}

@Extend(Text)
function titleStyle() {
  .fontSize(21)
  .fontColor(Color.White)
  .fontWeight(FontWeight.Bold)
  .margin({ top: 15 })
}


@Extend(Text)
function footerStyle() {
  .fontSize(12)
  .fontColor('#546B9D')
  .fontWeight(FontWeight.Bold)
  .margin({ bottom: 30 })
}