# 处理 Panics

在 Go SDK 中捕获未处理的紧急情况（panics）的方法是通过 `Recover` 方法。它可以直接通过 `defer` 关键字使用，也可以作为实现的一部分使用。

## 用法

如下所示，直接使用 Sentry 时，它将从紧急状态中恢复，并根据收到的输入类型在内部决定是使用 `CaptureException` 还是 `CaptureMessage` 方法。
由于出现字符串 panic 并不常见，建议在 SDK 初始化期间使用 `AttachStacktrace` 选项，该选项还将尝试为消息提供有用的堆栈跟踪。

```go
func() {
	defer sentry.Recover()
	// do all of the scary things here(在这里做所有可怕的事情)^_^
}()
```

默认情况下，Sentry Go SDK 使用异步传输，在下面的代码示例中，需要使用 `sentry.Flush` 方法显式等待事件传递完成。
这是必要的，因为否则程序将不会等待异步 HTTP 调用返回响应，并在到达 `main` 函数末尾时立即退出进程。
在正在运行的 goroutine 中或使用 `HTTPSyncTransport`（在 `Transports` 部分中可以了解到）时，不需要它。

如果要控制单个 `defer` 调用的传递，或在捕获之前执行其他操作，则必须直接在 `Hub` 实例上使用 `Recovery` 方法，因为它可以接受 `err` 本身。

```go
func() {
	defer func() {
		err := recover()

		if err != nil {
			sentry.CurrentHub().Recover(err)
			sentry.Flush(time.Second * 5)
		}
	}()

	// do all of the scary things here
}()
```

## 使用 Context

除了常规的 `Recover` 方法外，还有一种可用于紧急情况的方法，即 `RecoverWithContext`。
它允许传递 `context.Context` 的实例作为第一个参数。这为我们提供了两个附加功能。

第一个是从上下文(context)提取 `Hub` 实例并使用它而不是全局实例 —— 这用于每个 http/server 包集成，因为它允许执行上下文分离。您可以在我们的 `http` 集成[源代码](https://github.com/getsentry/sentry-go/blob/383614eaf2e038cf3a6d2022c56fb206589efe11/http/sentryhttp.go#L50-L91)中看到它的作用。

第二个功能是对 `beforeSend` 方法内部的 `context.Context` 本身的访问，可用于提取有关在 panic 下发生的情况的任何其他信息：

```go
type contextKey int
const SomeContextKey = contextKey(1)

func main() {
	sentrySyncTransport := sentry.NewHTTPSyncTransport()
	sentrySyncTransport.Timeout = time.Second * 3

	sentry.Init(sentry.ClientOptions{
		Dsn: "https://examplePublicKey@o0.ingest.sentry.io/0",
		Transport: sentrySyncTransport,
		BeforeSend: func(event *sentry.Event, hint *sentry.EventHint) *sentry.Event {
			if hint.Context != nil {
        // hint.Context.Value(SomeContextKey) 会给您存储的字符串，现在可以将其附加到事件中
			}
			return event
		},
	})

	ctx := context.WithValue(context.Background(), SomeContextKey, "some details about your panic")

	func() {
		defer sentry.RecoverWithContext(ctx)
		// do all of the scary things here
	}()
}
```