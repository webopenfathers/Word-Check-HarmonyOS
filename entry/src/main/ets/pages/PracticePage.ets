import { AnswerStatus } from '../enums/AnswerStatus'
import { PracticeStatus } from '../enums/PracticeStatus'
import { getRandomQuestions, Question } from '../model/Question'
import { promptAction, router } from '@kit.ArkUI'
import { OptionStatus } from '../enums/OptionStatus'
import { convertMillisecondsToTime } from '../utils/DateUtil'
import { createPost } from '../http/Api'

@Component
export struct PracticePage {
  @State practiceStatus: PracticeStatus = PracticeStatus.Stopped // 练习状态
  @State totalCount: number = 10 // 题目总数
  @State questions: Question[] = getRandomQuestions(this.totalCount) // 题目数组
  @State currentIndex: number = 0 // 当前题目的索引
  @State answerStatus: AnswerStatus = AnswerStatus.Answering // 是否作答
  @State selectedOption: string = '' // 用户点击的某个选项
  @State answeredCount: number = 0 // 本轮测试已作答个数
  @State rightCount: number = 0 // 表示正确个数
  timerController: TextTimerController = new TextTimerController(); //controller声明
  timeUsed: number = 0 // 记录答题用时
  dialogController: CustomDialogController = new CustomDialogController({
    // 控制弹框
    builder: ResultDialog({
      answeredCount: this.answeredCount,
      rightCount: this.rightCount,
      timeUsed: this.timeUsed,
      resetPractice: () => { // 回调函数---重置统计信息
        this.questions = getRandomQuestions(this.totalCount) // 重置题目
        this.currentIndex = 0 // 重置索引
        this.answeredCount = 0
        this.rightCount = 0
        this.timeUsed = 0
        this.timerController.reset() // 重置计时器
        this.answerStatus = AnswerStatus.Answering
      },
      startPractice: () => { // 回调函数---开始测试
        this.startPractice()
      }
    }),
    customStyle: true, // 默认情况下所有弹窗都使⽤默认的样式，如需使⽤⾃定义样式，需要为CustomDialogController配置 customStyle:true 参数。
    autoCancel: false // 禁止点击遮罩关闭弹框
  })

  // 写函数的位置
  // 开始测试
  startPractice() {
    this.practiceStatus = PracticeStatus.Running
    // 启动计时器
    this.timerController.start()
  }

  // 暂停测试
  pausePractice() {
    this.practiceStatus = PracticeStatus.Paused
    // 停止计时器
    this.timerController.pause()
  }

  // 停止测试
  stopPractice() {
    this.practiceStatus = PracticeStatus.Stopped
    // 停止计时器
    this.timerController.pause()
    // 弹窗
    this.dialogController.open()
  }

  build() {
    Column() {
      // todo:统计面板
      Column() {
        // 准确率
        StatItem({
          icon: $r('app.media.ic_accuracy'),
          name: '准确率',
          fontColor: Color.Black
        }) {
          Text(this.answeredCount === 0 ? '0%' : ((this.rightCount / this.answeredCount * 100).toFixed() + '%'))
            .width(100)
            .textAlign(TextAlign.Center)
        }

        // 进度
        StatItem({
          icon: $r('app.media.ic_progress'),
          name: '进度',
          fontColor: Color.Black
        }) {
          Progress({ value: this.answeredCount, total: this.totalCount }).width(100)
        }

        // 个数
        StatItem({
          icon: $r('app.media.ic_count'),
          name: '个数',
          fontColor: Color.Black
        }) {
          Button(this.totalCount.toString())
            .width(100)
            .height(25)
            .backgroundColor('#EBEBEB')
            .fontColor(Color.Black)
            .enabled(this.practiceStatus === PracticeStatus.Stopped)// 只有在停止状态才可以点击
            .onClick(() => {
              // 文本选择器
              TextPickerDialog.show({
                range: ['5', '10', '15', '20'],
                value: this.totalCount.toString(),
                alignment: DialogAlignment.Bottom,
                onAccept: (result) => {
                  this.totalCount = parseInt(result.value as string)
                  this.questions = getRandomQuestions(this.totalCount)
                }
              })
            })
        }

        // 用时
        StatItem({
          icon: $r('app.media.ic_timer'),
          name: '用时',
          fontColor: Color.Black
        }) {
          Row() {
            TextTimer({ controller: this.timerController })
              .onTimer((_utc, elapsedTime) => {
                this.timeUsed = elapsedTime
              })
          }
          .width(100)
          .justifyContent(FlexAlign.Center)
        }
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

              // 判断正误
              this.selectedOption = option
              // 更新统计信息
              this.answeredCount++
              if (option === this.questions[this.currentIndex].answer) {
                this.rightCount++
              }

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

// 弹框组件
@CustomDialog
struct ResultDialog {
  answeredCount: number = 0; // 已作答个数
  rightCount: number = 0; // 答对个数
  timeUsed: number = 0 // 用时
  resetPractice: () => void = () => { // 重置统计信息
  }
  startPractice: () => void = () => { // 开始测试
  }
  controller: CustomDialogController = new CustomDialogController({
    builder: ResultDialog()
  })
  @StorageProp('token') token: string = ''
  @StorageLink('currentTabIndex') currentTabIndex: number = 0

  build() {
    Column({ space: 10 }) {
      Image($r('app.media.ic_close'))
        .width(25)
        .height(25)
        .alignSelf(ItemAlign.End)
        .onClick(() => {
          this.controller.close() // 关闭弹框
          this.resetPractice() // 重置统计信息
        })

      Column({ space: 10 }) {
        Image($r('app.media.img_post'))
          .width('100%')
          .borderRadius(10)

        // 用时
        StatItem({
          icon: $r('app.media.ic_timer'),
          name: '用时',
          fontColor: Color.Black
        }) {
          Text(convertMillisecondsToTime(this.timeUsed))
        }

        // 准确率
        StatItem({
          icon: $r('app.media.ic_accuracy'),
          name: '准确率',
          fontColor: Color.Black
        }) {
          Text((this.answeredCount === 0 ? 0 : this.rightCount / this.answeredCount * 100).toFixed() + '%')
        }


        // 个数
        StatItem({
          icon: $r('app.media.ic_count'),
          name: '个数',
          fontColor: Color.Black
        }) {
          Text(this.answeredCount.toString())
        }

        Divider()

        Row({ space: 30 }) {
          Button('再来一局')
            .controlButtonStyle({
              bg: Color.Transparent,
              border: Color.Black,
              font: Color.Black
            })
            .onClick(() => {
              this.controller.close() // 关闭弹框
              this.resetPractice() // 重置统计信息
              this.startPractice() // 开始测试
            })
          Button(this.token ? '立即打卡' : '登录打卡')
            .controlButtonStyle({
              bg: Color.Black,
              border: Color.Black,
              font: Color.White
            })
            .onClick(async () => {
              this.controller.close() // 关闭弹框
              this.resetPractice() // 重置统计信息
              if (this.token) {
                // 发送打卡请求
                await createPost({
                  rightCount: this.rightCount,
                  answeredCount: this.answeredCount,
                  timeUsed: this.timeUsed
                })
                promptAction.showToast({ message: '打卡成功' })
                // 跳转到打卡圈
                this.currentTabIndex = 1
              } else {
                // 跳转到登录页面
                router.pushUrl({
                  url: 'pages/LoginPage', params: {
                    rightCount: this.rightCount,
                    answeredCount: this.answeredCount,
                    timeUsed: this.timeUsed
                  }
                })
              }
            })
        }
      }
      .backgroundColor(Color.White)
      .width('100%')
      .padding(20)
      .borderRadius(10)

    }
    .backgroundColor(Color.Transparent)
    .width('80%')
  }
}


@Builder
function builderFunction(): void {
}


@Component
struct StatItem {
  icon: Resource = $r('app.media.ic_accuracy');
  name: string = '';
  // 定义传入的UI组件
  @BuilderParam statComp: () => void = builderFunction
  fontColor: Color = Color.Black;

  build() {
    Row({ space: 10 }) {
      Image(this.icon)
        .height(14)
        .width(14)
      Text(this.name)
        .fontWeight(FontWeight.Medium)
        .fontSize(14)
        .fontColor(this.fontColor)
      Blank()
      this.statComp()
    }.width('100%')
    .height(30)
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