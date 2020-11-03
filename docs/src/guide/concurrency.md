# 并发

并发的 Go 程序使用 goroutines（一种由 Go 运行时管理的轻量级线程形式）。 由于 goroutine 同时运行，因此每个 goroutine 必须在本地跟踪其与 Sentry 相关的数据。
否则，数据争用(data races)会在您的程序中引入细微的错误，其后果从明显的变化到意外的崩溃，甚至更糟的是，意外地将 `Scope` 中存储的数据混合在一起。
在 [Scopes and Hubs](https://docs.sentry.io/platforms/go/enriching-events/scopes/) 部分中对此有更多的了解。

处理这个问题最简单的方法是为您启动的每个 goroutine 创建一个新的 `Hub`，但是这需要您重新绑定当前 `Client` 并自己处理 `Scope`。
这就是为什么我们提供了一个名为 `Clone` 的辅助方法。它负责创建集线器、克隆现有 `Scope` 并将其与 `Client` 一起重新分配给新创建的实例。

克隆后，`Hub` 将完全隔离，可以在并发调用中安全使用。但是，不应使用在全局上公开的方法，而应在 `Hub` 上直接调用它们。

这是两个示例：

* 建议对 `Hub` 进行安全的确定性调用

```go
// Example of __CORRECT__ use of scopes inside a Goroutine
// 正确使用

go func(localHub *sentry.Hub) {
	// as goroutine argument
	localHub.ConfigureScope(func(scope *sentry.Scope) {
		scope.SetTag("secretTag", "go#1")
	})
	localHub.CaptureMessage("Hello from Goroutine! #1")
}(sentry.CurrentHub().Clone())

go func() {
	// or created locally
	localHub := sentry.CurrentHub().Clone()
	localHub.ConfigureScope(func(scope *sentry.Scope) {
		scope.SetTag("secretTag", "go#2")
	})
	localHub.CaptureMessage("Hello from Goroutine! #2")
}()
```

* 阻止在 `Hub` 上进行的不确定性调用，该调用会泄漏线程之间的信息

```go
// Example of __INCORRECT__ use of scopes inside a Goroutine - DON'T USE IT!
// 不正确使用

go func() {
	sentry.ConfigureScope(func(scope *sentry.Scope) {
		scope.SetTag("secretTag", "go#1")
	})
	sentry.CaptureMessage("Hello from Goroutine! #1")
}()

go func() {
	sentry.ConfigureScope(func(scope *sentry.Scope) {
		scope.SetTag("secretTag", "go#2")
	})
	sentry.CaptureMessage("Hello from Goroutine! #2")
}()

// 此时，两个事件都可以具有 `go#1` 标签或 `go#2` 标签。我们永远不会知道。
```