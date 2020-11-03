# 自定义标签

标签是既可索引又可搜索的 `key/value` 字符串对。
标签具有强大的 UI 功能，例如过滤器和标签分布图。
标签还可以帮助您快速访问相关事件，并查看一组事件的标签分布。
标签的常见用法包括主机名，平台版本和用户语言。

我们将自动为一个事件的所有标签建立索引，以及 Sentry 看到标签的频率和最后一次。
我们还将跟踪不同标签的数量，并可以帮助您确定各种问题的热点。

定义标签很容易，并将它们绑定到[当前范围](https://docs.sentry.io/platforms/go/enriching-events/scopes/)，确保范围内的所有未来事件都包含相同的标签：

```go
sentry.ConfigureScope(func(scope *sentry.Scope) {
	scope.SetTag("page.locale", "de-at");
})
```

某些标签由 Sentry 自动设置。强烈建议您不要覆盖这些标签，而应使用自己的名称命名。

一旦开始发送标记的数据，您将在Sentry Web UI中看到它：“项目”页面侧栏中的过滤器，在事件内进行汇总以及在聚合事件的“标签”页面上。

![](/tags.png)