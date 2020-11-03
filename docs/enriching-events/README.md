# 添加 Context

自定义上下文允许您将任意数据附加到事件。您无法搜索这些，但可以在问题页面上查看它们：

![](/additional_data.png)

如果需要能够搜索自定义数据，则需要使用[标签](https://docs.sentry.io/platforms/go/enriching-events/tags/)。

要配置附加上下文:

```go
sentry.ConfigureScope(func(scope *sentry.Scope) {
	scope.SetExtra("character.name", "Mighty Fighter")
})
```

注意，上下文的外部值必须是一个 dictionary/map/object，而内部值可以是任意的。

发送上下文时，请注意最大有效负载大小，尤其是如果您希望将整个应用程序状态作为额外数据发送时。Sentry不建议使用此方法，因为应用程序状态可能非常大，并且很容易超过 Sentry 在单个事件有效负载上的最大200kB。发生这种情况时，您会收到`HTTP Error 413 Payload Too Large` 消息，作为服务器响应，或者（当您将 `keepalive: true` 设置为 `fetch` 参数时），该请求将永远处于待处理状态（例如，在 Google Chrome 中）。

Sentry 将尽力容纳您发送的数据，但 Sentry 会修剪较大的上下文有效负载或完全截断这些有效负载。

有关更多详细信息，请参阅有关[SDK数据处理的开发人员文档](https://develop.sentry.dev/sdk/data-handling/)。

**Extra Data, Additional Data(额外数据)**

如果遇到 “extra”（在代码中为 `SetExtra` ）或 “Additional Data”（在用户界面中）的任何用法，请在头脑上将其替换为上下文。
大多数 SDK 不推荐使用 Extra，而是使用上下文。

