import router from '@ohos.router'
import { AxiosResponse } from '@ohos/axios'
import { createPost, login, sendCode } from '../http/Api'
import { promptAction } from '@kit.ArkUI'
import { emitter } from '@kit.BasicServicesKit'


interface RouterParams {
  rightCount: number,
  answeredCount: number,
  timeUsed: number
}

@Entry
@Component
struct LoginPage {
  @State phone: string = ''
  @State code: string = ''
  // 读取数据：使用注解的方式拿数据
  @StorageLink('token') token: string = ''
  @StorageLink('currentTabIndex') currentTabIndex: number = 0

  build() {
    Column() {
      Image($r('app.media.ic_back'))
        .backStyle()
        .alignSelf(ItemAlign.Start)
        .onClick(() => {
          //todo:返回上一页面
          router.back()
        })

      Blank()
      Column() {
        Text('欢迎登录')
          .titleStyle()

        Row() {
          Image($r("app.media.ic_phone"))
            .iconStyle()
          TextInput({ placeholder: '请输入手机号码', text: this.phone })
            .inputStyle()
            .onChange((value) => {
              this.phone = value;
            })
        }.margin({ top: 30 })

        Divider()
          .color(Color.Black)

        Row() {
          Image($r("app.media.ic_code"))
            .iconStyle()
          TextInput({ placeholder: '请输入验证码', text: this.code })
            .inputStyle()
            .onChange((value) => {
              this.code = value;
            })
          Button('获取验证码')
            .buttonCommonStyle(Color.White, Color.Black)
            .onClick(async () => {
              let response: AxiosResponse = await sendCode(this.phone)
              this.code = response.data.data
            })

        }.margin({ top: 20 })

        Divider()
          .margin({ right: 120 })
          .color(Color.Black)

        Button('立即登录')
          .buttonCommonStyle(Color.Black, Color.White)
          .width('100%')
          .margin({ top: 50 })
          .onClick(async () => {
            let response: AxiosResponse = await login(this.phone, this.code)
            this.token = response.data.data
            if (this.currentTabIndex == 0) {
              // todo:发送打卡请求
              let params = router.getParams() as RouterParams
              await createPost({
                rightCount: params.rightCount,
                answeredCount: params.answeredCount,
                timeUsed: params.timeUsed
              })
              promptAction.showToast({ message: '打卡成功' })
              // 通知
              emitter.emit({ eventId: 1 })
              // todo:跳转到打卡圈
              this.currentTabIndex = 1
            }
            router.back()
          })

        Row() {
          Text('登录即表示已同意')
            .fontSize(10)
            .fontColor('#546B9D')
          Text('《用户使用协议》')
            .fontSize(10)
            .fontColor('#00B3FF')
        }.margin({ top: 20 })
      }.formBgStyle()

      Row({ space: 10 }) {
        Image($r('app.media.ic_logo'))
          .width(36)
          .height(36)
        Text('快速记单词神器')
          .fontColor('#546B9D')
          .fontWeight(FontWeight.Bold)
          .fontSize(20)
      }.margin({ top: 70 })

      Text('Developed By Atguigu')
        .fontSize(12)
        .fontColor('#546B9D')
        .margin(10)

    }
    .loginBgStyle()
  }
}

@Styles
function loginBgStyle() {
  .width('100%')
  .height('100%')
  .backgroundImage($r("app.media.img_login_bg"))
  .backgroundImageSize({ width: '100%', height: '100%' })
  .padding({
    top: 30,
    bottom: 30,
    left: 20,
    right: 20
  })
}

@Styles
function backStyle() {
  .width(25)
  .height(25)
}

@Styles
function formBgStyle() {
  .backgroundColor(Color.White)
  .padding(30)
  .borderRadius(20)
}

@Extend(Text)
function titleStyle() {
  .fontWeight(FontWeight.Bold)
  .fontSize(22)
}

@Styles
function iconStyle() {
  .width(24)
  .height(24)
}

@Extend(TextInput)
function inputStyle() {
  .height(40)
  .layoutWeight(1)
  .fontSize(14)
  .backgroundColor(Color.Transparent)
}

@Extend(Button)
function buttonCommonStyle(bgColor: ResourceColor, fontColor: ResourceColor) {
  .type(ButtonType.Normal)
  .fontSize(14)
  .fontWeight(FontWeight.Medium)
  .borderWidth(1)
  .borderRadius(5)
  .backgroundColor(bgColor)
  .fontColor(fontColor)
}