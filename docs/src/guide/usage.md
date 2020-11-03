# 用法

Sentry 的 SDK 挂接到您的运行时环境中，并自动报告错误，异常和拒绝。

关键术语:
* 事件是向 Sentry 发送数据的一个实例。通常，此数据是错误或异常。
* 一个问题是一组相似的事件。
* 事件的报告称为捕获。当一个事件被捕获，它被发送到 Sentry。

捕获的最常见形式是捕获错误。可以捕获为错误的内容因平台而异。
通常，如果您有看起来像异常的东西，则可以将其捕获。
对于某些 SDK，您还可以省略 `capture_exception` 的参数，Sentry 将尝试捕获当前异常。
手动将错误或消息报告给 Sentry 也很有用。

除了捕获之外，您还可以记录导致事件的面包屑。
面包屑与事件不同：它们不会在 Sentry 中创建事件，但将被缓冲直到发送下一个事件。
在我们的[面包屑文档中](https://docs.sentry.io/platforms/go/guides/http/enriching-events/breadcrumbs/)了解有关面包屑的更多信息。


## 捕获错误

要在 Go 中捕获事件，可以将实现 `error` 接口的任何结构传递给 `CaptureException()`。
如果使用第三方库而不是原生 `errors` 包，我们将尽力提取堆栈跟踪。

SDK完全兼容(但不限于):
* github.com/pkg/errors
* github.com/go-errors/errors
* github.com/pingcap/errors

如果有无法立即使用的错误包，请告诉我们！

```go
f, err := os.Open("filename.ext")
if err != nil {
	sentry.CaptureException(err)
}
```

## 捕获消息

另一个常见的操作是捕获一条纯消息。消息是应该发送给 Sentry 的文本信息。
通常情况下，消息不会被发出，但是对于某些团队来说，它们可能是有用的。

```go
sentry.CaptureMessage("Something went wrong")
```

默认情况下，Sentry 的 Go SDK 使用异步传输。
这意味着对 `CaptureException`，`CaptureEvent` 和 `CaptureMessage` 的调用无需等待网络操作即可返回。
而是在后台 goroutine 中缓冲事件并通过网络发送事件。
调用 `sentry.Flush` 以等待事件传递，然后程序终止。
您可以使用其他传输方式（例如 `HTTPSyncTransport`）来更改默认行为。
在 [Transports](https://docs.sentry.io/platforms/go/configuration/transports/) 部分中有更多详细信息。

## 设置级别

级别 — 类似于日志级别 — 通常是基于集成默认添加的。您还可以在事件中覆盖它。

```go
sentry.ConfigureScope(func(scope *sentry.Scope) {
	scope.SetLevel(sentry.LevelWarning)
})
```
