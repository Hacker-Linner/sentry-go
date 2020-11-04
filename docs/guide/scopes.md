# Scopes and Hubs

捕获事件并将其发送到 Sentry 后，SDK 会将事件数据与当前作用域中的额外信息合并。
SDK 通常会在框架集成中为您自动管理范围，而您无需考虑它们。
但是，您应该知道什么是范围以及如何利用它来发挥自己的优势。

## 什么是 Scope，什么是 Hub

你可以把 hub 看作中心点，我们的 SDK 使用它来将事件路由到 Sentry。
当您调用 `init()` 时，将创建一个 hub，并在其上创建一个 client 和一个 `blank scope`。
然后，该中心与当前线程相关联，并将在内部持有一个作用域堆栈。

范围将包含应与事件一起发送的有用信息。
例如，上下文或面包屑存储在 scope 上。
当推入作用域时，它将继承父作用域的所有数据，
并且当其弹出时，所有修改都将还原。

默认的 SDK 集成将智能地推送和弹出作用域。
例如，Web 框架集成将在您的路由或控制器周围创建和销毁作用域。

## Scope 和 Hub 如何工作

在开始使用 SDK 时，将自动为您创建开箱即用的 Scope 和 Hub。
除非您正在编写集成或希望创建或销毁作用域，否则您不太可能与 Hub 直接交互。
另一方面，范围更面向用户。
您可以在任何时候调用 `configure-scope` 来修改存储在该 Scope 上的数据。
例如，它用于[修改上下文](https://docs.sentry.io/platforms/go/enriching-events/scopes/)。

在内部调用全局函数(如 `capture_event` )时，Sentry 会发现当前 Hub 并要求它捕获一个事件。
然后，hub 将在内部将事件与最顶层 Scope 的数据合并。

## 配置 Scope

在使用作用域时，最有用的操作是 `configure-scope` 函数。
它可用于重新配置当前范围。
例如，这可以用来添加自定义标记或通知 sentry 关于当前经过身份验证的用户。

```go
sentry.ConfigureScope(func(scope *sentry.Scope) {
	scope.SetTag("my-tag", "my value")
	scope.SetUser(sentry.User{
		ID: "42",
		Email: "john.doe@example.com",
	})
})
```

这也可以应用在注销时取消设置用户:

要了解哪些有用的信息可以与作用域关联，请参阅[上下文文档](https://docs.sentry.io/platforms/go/enriching-events/context/)。

## 局部作用域

我们还支持一次性推送和配置 scope。
这通常被称为 `with-scope` 或 `push-scope`，
如果您只想用一个特定事件发送数据，这也非常有用。
在下面的示例中，我们使用该函数仅为一个特定的错误附加一个级别和一个标签:

```go
sentry.WithScope(func(scope *sentry.Scope) {
	scope.SetTag("my-tag", "my value");
	scope.SetLevel(sentry.LevelWarning);
	// will be tagged with my-tag="my value"
	sentry.CaptureException(errors.New("my error"))
})

// will not be tagged with my-tag
sentry.CaptureException(errors.New("my error"))
```

虽然这个示例看起来与 `configure-scope` 类似，但它有很大的不同，
因为 `configure-scope` 实际上更改了当前活动的作用域，
所以对 `configure-scope` 的所有后续调用将保留这些更改。

而另一方面，使用with-scope创建当前作用域的克隆，并将保持隔离，直到函数调用完成。因此，通过调用作用域上的clear，您可以在这里设置不想放在其他地方的上下文信息，或者根本不附加任何上下文信息，而“全局”作用域保持不变。