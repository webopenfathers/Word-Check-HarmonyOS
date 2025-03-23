import { PracticeStatus } from '../enums/PracticeStatus'

@Entry
@Component
struct PracticePage {
  @State practiceStatus: PracticeStatus = PracticeStatus.Stopped

  // 写函数的位置

  // 开始测试
  startPractice() {
    this.practiceStatus = PracticeStatus.Running
    // todo:启动计时器
  }

  // 暂停测试
  pausePractice() {
    this.practiceStatus = PracticeStatus.Paused
    // todo:停止计时器
  }

  // 停止测试
  stopPractice() {
    this.practiceStatus = PracticeStatus.Stopped
    // todo:停止计时器
    // todo:弹窗
  }

  build() {
    Column() {
      // todo:统计面板
      Column() {
        Text('统计信息')
        Text('统计信息')
        Text('统计信息')
        Text('统计信息')
      }.statBgStyle()

      // 题目
      Column() {
        Text('单词').wordStyle()
        Text('例句').sentenceStyle()
      }

      // 选项
      Column({ space: 10 }) {
        ForEach([1, 2, 3, 4], (option: number) => {
          Button(option.toString()).optionButtonStyle({
            bg: Color.White,
            font: Color.Black
          })
        })
      }

      // 控制按钮
      Row({ space: 50 }) {
        Button('停止测试')
          .controlButtonStyle({
            bg: Color.Transparent,
            border: this.practiceStatus === PracticeStatus.Stopped ? Color.Gray : Color.Black,
            font: this.practiceStatus === PracticeStatus.Stopped ? Color.Gray : Color.Black
          })
          .enabled(this.practiceStatus !== PracticeStatus.Stopped)// 控制按钮是否可用 true可用  false不可用
          .onClick(() => {
            this.stopPractice()
          })


        Button(this.practiceStatus === PracticeStatus.Running ? '暂停测试' : '开始测试')
          .controlButtonStyle({
            bg: this.practiceStatus === PracticeStatus.Running ? '#555555' : Color.Black,
            border: this.practiceStatus === PracticeStatus.Running ? '#555555' : Color.Black,
            font: Color.White
          })
          .stateEffect(false)// 设置是否开启按压态显示效果。
          .onClick(() => {
            if (this.practiceStatus === PracticeStatus.Running) {
              this.pausePractice()
            } else {
              this.startPractice()
            }
          })
      }
    }
    .practiceBgStyle()
  }
}


@Extend(Column)
function practiceBgStyle() {
  .width('100%')
  .height('100%')
  .backgroundImage($r('app.media.img_practice_bg'))
  .backgroundImageSize({ width: '100%', height: '100%' })
  .justifyContent(FlexAlign.SpaceEvenly)
}

@Styles
function statBgStyle() {
  .backgroundColor(Color.White)
  .width('90%')
  .borderRadius(10)
  .padding(20)
}

@Extend(Text)
function wordStyle() {
  .fontSize(50)
  .fontWeight(FontWeight.Bold)
}

@Extend(Text)
function sentenceStyle() {
  .height(40)
  .fontSize(16)
  .fontColor('#9BA1A5')
  .fontWeight(FontWeight.Medium)
  .width('80%')
  .textAlign(TextAlign.Center)
}

interface OptionButtonInterface {
  bg: ResourceColor;
  font: ResourceColor;
}

@Extend(Button)
function optionButtonStyle(color: OptionButtonInterface) {
  .width(240)
  .height(48)
  .fontSize(16)
  .type(ButtonType.Normal)
  .fontWeight(FontWeight.Medium)
  .borderRadius(8)
  .backgroundColor(color.bg)
  .fontColor(color.font)
}

interface ControlButtonInterface {
  bg: ResourceColor;
  border: ResourceColor;
  font: ResourceColor;
}

@Extend(Button)
function controlButtonStyle(color: ControlButtonInterface) {
  .fontSize(16)
  .borderWidth(1)
  .backgroundColor(color.bg)
  .borderColor(color.border)
  .fontColor(color.font)
}