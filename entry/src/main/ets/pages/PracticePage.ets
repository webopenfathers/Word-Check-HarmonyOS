import { AnswerStatus } from '../enums/AnswerStatus'
import { PracticeStatus } from '../enums/PracticeStatus'
import { getRandomQuestions, Question } from '../model/Question'
import { promptAction } from '@kit.ArkUI'
import { OptionStatus } from '../enums/OptionStatus'

@Entry
@Component
struct PracticePage {
  @State practiceStatus: PracticeStatus = PracticeStatus.Stopped // 练习状态
  @State questions: Question[] = getRandomQuestions(10) // 题目数组
  @State currentIndex: number = 0 // 当前题目的索引
  @State answerStatus: AnswerStatus = AnswerStatus.Answering // 是否作答
  @State selectedOption: string = '' // 用户点击的某个选项

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
        Text(this.questions[this.currentIndex].word).wordStyle()
        Text(this.questions[this.currentIndex].sentence).sentenceStyle()
      }

      // 选项
      Column({ space: 10 }) {
        ForEach(this.questions[this.currentIndex].options, (option: string) => {
          OptionButton({
            option: option,
            answerStatus: this.answerStatus,
            answer: this.questions[this.currentIndex].answer,
            selectedOption: this.selectedOption
          })
            .enabled(this.answerStatus === AnswerStatus.Answering)// 500ms以内点击后不可点击
            .onClick(() => {
              // 判断练习状态
              if (this.practiceStatus !== PracticeStatus.Running) {
                return promptAction.showToast({
                  message: '请先点击开始测试'
                })
              }

              // todo:判断正误
              this.selectedOption = option
              // todo:更新统计信息

              // 切换题目
              this.answerStatus = AnswerStatus.Answered
              if (this.currentIndex < this.questions.length - 1) {
                setTimeout(() => {
                  this.currentIndex++
                  this.answerStatus = AnswerStatus.Answering
                }, 500)
              } else {
                this.stopPractice()
              }
            })
        }, (option: string) => this.questions[this.currentIndex].word + '-' + option)
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


// 自定义选项Button组件样式
@Component
struct OptionButton {
  option: string = '' // 选项
  answer: string = '' // 每个题目的正确答案
  @State optionStatus: OptionStatus = OptionStatus.Default // 定义按钮状态
  @Prop selectedOption: string = '' // 父组件选中的数据传递给子组件判断
  @Prop @Watch('onAnswerStatusChange') answerStatus: AnswerStatus // 按钮状态改变

  // 监听按钮点击
  // 修改按钮状态(颜色)
  onAnswerStatusChange() {
    if (this.option === this.answer) { // 是正确答案
      this.optionStatus = OptionStatus.Right
    } else {
      // 判断是不是被选择的答案
      if (this.option === this.selectedOption) {
        this.optionStatus = OptionStatus.Wrong
      } else {
        this.optionStatus = OptionStatus.Default
      }
    }
  }

  // 定义不同状态按钮的颜色
  getBgColor() {
    switch (this.optionStatus) {
      case OptionStatus.Right:
        return '#1DBF7B'
      case OptionStatus.Wrong:
        return '#FA635F'
      default:
        return Color.White
    }
  }

  build() {
    Stack() {
      Button(this.option).optionButtonStyle({
        bg: this.getBgColor(),
        font: this.optionStatus === OptionStatus.Default ? Color.Black : Color.White
      })

      if (this.optionStatus === OptionStatus.Right) {
        Image($r('app.media.ic_right'))
          .width(22)
          .height(22)
          .offset({ x: 10 })
      } else if (this.optionStatus === OptionStatus.Wrong) {
        Image($r('app.media.ic_wrong'))
          .width(22)
          .height(22)
          .offset({ x: 10 })
      }
    }.alignContent(Alignment.Start)
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