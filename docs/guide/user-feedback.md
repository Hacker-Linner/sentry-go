# 用户反馈

当用户遇到错误时，Sentry 可以收集其他反馈。当您通常可以呈现简单的错误页面（经典的 `500.html`）时，这种类型的反馈很有用。

要收集反馈，请使用可嵌入的 JavaScript 小部件，该小部件将请求并收集用户的姓名，电子邮件地址以及发生的情况的描述。
提供反馈后，Sentry 会将反馈与原始事件配对，从而使您对问题有更多见解。

下面的屏幕截图提供了“用户反馈”小部件的示例，尽管您的个性化可能因您的自定义而有所不同：

![](/user_feedback_widget.png)

## 收集反馈

要集成小部件，您需要运行 2.1 版或更高版本的 JavaScript SDK。
该小部件将使用您的公共 DSN 进行身份验证，然后传入在您的后端生成的事件 ID。

如果您希望使用窗口小部件的替代产品，或者没有 JavaScript 前端，则可以使用[用户反馈API](https://docs.sentry.io/api/projects/submit-user-feedback/)。

确保您有可用的 JavaScript SDK：

```html
<script
  src="https://browser.sentry-cdn.com/5.27.2/bundle.min.js"
  integrity="sha384-+69fdGw+g5z0JJXjw46U9Ls/d9Y4Zi6KUlCcub+qIWsUoIlyimCujtv+EnTTHPTD"
  crossorigin="anonymous"
></script>
```

然后，您需要调用 `showReportDialog` 并传递生成的事件 ID。
从所有对 `CaptureEvent` 和 `CaptureException` 的调用都返回此事件 ID。
还有一个名为 `LastEventId` 的函数，该函数返回最近发送的事件的 ID。

```html
<script>
  Sentry.init({ dsn: "https://examplePublicKey@o0.ingest.sentry.io/0" });
  Sentry.showReportDialog({
    eventId: "{{ event_id }}",
  });
</script>
```

## 自定义小部件

您可以根据组织的需要自定义窗口小部件，尤其是为了本地化目的。
所有选项都可以通过 `showReportDialog` 调用传递。

Sentry 的自动语言检测(例如 `lang=de`)的覆盖

| Param         | Default       |
| ------------- |:-------------:|
| eventId	      | 手动设置事件的ID。|
| dsn   | 手动设置要报告的dsn。|
| user | 手动设置用户数据[上面列出了键的对象]。|
| user.email | 用户的电子邮件地址。|
| user.name | 用户的名称。|
| lang | [automatic] – 覆盖 Sentry 的语言代码|
| title | 看来我们有问题了。|
| subtitle | 我们的团队已收到通知。|
| subtitle2 | 如果您想提供帮助，请告诉我们下面发生的情况。– 在小屏幕分辨率下不可见 |
| labelName | 名称|
| labelEmail | 邮箱|
| labelComments | 发生了什么？|
| labelClose | 关闭|
| labelSubmit | 提交|
| errorGeneric | 提交报告时发生未知错误。 请再试一次。|
| errorFormEntry | 一些字段无效。请改正错误，再试一次。|
| successMessage | 您的反馈已发送。 谢谢！|
| onLoad | n/a|
