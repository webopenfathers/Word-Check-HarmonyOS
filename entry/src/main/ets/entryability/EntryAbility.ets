import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  // 当UIAblitity实例创建完成时被调⽤，可在该函数中进⾏应⽤的初始化操作，例如定义全局变量
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  // 当UIAblitity实例销毁时被调⽤，可在该函数中释放系统资源，保存数据等
  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  // 当WindowStage实例创建时被调⽤，可在该函数中设置应⽤加载的初始⻚⾯
  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // 指定应⽤初始⻚⾯
    // 修改 entry/src/main/ets/entryability/EntryAbility.ts ⽂件中的如下内容，指定应⽤初始⻚⾯位欢迎⻚
    windowStage.loadContent('pages/SplashPage', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  // 当WindowStage实例销毁时被调⽤
  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  // 当UIAblitity实例切换⾄前台时被调⽤，可在该函数中加载所需的系统资源
  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  // 当UIAblitity实例切换⾄后台时被调⽤，可在函数中释放系统资源，以节省系统资源的消耗
  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}